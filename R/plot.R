#' @title Plot of experimental and simulated profile inventories
#'
#' @name plot
#'
#' @param data1 Character. Read input data in CSV format.
#' @param data2  Filtered values of data1 for the current 'id'.
#' @param dir1 directory. Temporary working directory where the '_num.txt' and '_exp.txt' files were created.
#' @param dir2 directory. Current working directory.
#' @param AxisMaxValue daximum value to determine the x axis limit. Only used if the user wants to escalate all the simulated profiles .
#' @param cell_value Unit cell size in meters.
#'
#' @description
#' The "plot" function generates two plots for each profile defined in the input data: one representing the experimental inventory and the other representing the simulated inventory. This function is automatically executed when you run RadEro_run. It creates a "results" folder in the current directory if it does not already exist.
#'
#' @returns A "results" folder in "dir2" containing "n" plots saved as PNG files, where "n" corresponds to the number of "id" entries defined in "data2". Additionally, a summary TXT file is saved in the results folder.
#'
# Declare global variables used in ggplot2 aesthetics to prevent R CMD check NOTES.
# These variables are part of the plotting function and are referenced within ggplot calls.
utils::globalVariables(c("x", "y", "depth1", "num2", "midPROF", "invCS"))

resample <- function(df1, df2)
{
		for(i in 1:nrow(df2))
		{
			z1 <- df2$z1[i]
			z2 <- df2$z2[i]
			
			cs <- 0.0
			for(j in 1:nrow(df1))
			{
				oz1 <- df1$z1[j]
				oz2 <- df1$z2[j]
				ocs <- df1$cs[j]
				
				if(z1 < oz1 && z2 > oz1 && z2 <= oz2)
				{
					cs = cs + ocs * (z2-oz1) / (oz2-oz1)
				}
				else if(z1 >= oz1 && z2 <= oz2)
				{
					cs = cs + ocs * (z2-z1) / (oz2-oz1)
				}
				else if(z1 >= oz1 && z1 <= oz2 && z2 > oz2)
				{
					cs = cs + ocs * (oz2-z1) / (oz2-oz1)
				}
				else if(z1 <= oz1 && z2 >= oz2)
				{
					cs = cs + ocs
				}
			}
			df2$cs[i] <- cs
		}
		
		df2
}

plot <- function(data1, data2, dir1, dir2, AxisMaxValue, cell_value) {

  # Create results folder.
  results_folder <- file.path(dir2, "results")

  dir.create(results_folder, showWarnings = FALSE)

  # Create data2 labels for the Bq/m2 inventory in each interval.
  data2_mod <-data.frame(id = data2$id, midPROF=(data2$depth_i+((data2$depth_f-data2$depth_i)/2)), y=data2$Cs137_invt*100/(data2$depth_f*100-data2$depth_i*100), invCS=data2$Cs137_invt)

  # Create a unified data frame from the input data to easy data manipulation.
  # Read '_num.txt' in 'num_read.'
  num_read <- read.table(file.path(dir1, "_num.txt"), comment.char = "#")
  # Read total depth of the profile in 'depth'.
  depth <- tail(data2$lower_boundary, 1)
  # Cell thickness (it is used to be 0.01 m )
  cell <- cell_value
  # Create sequence every 1cm starting from the total profile depth.
  depthrow <- seq(0.01, depth, by = cell)
  # Create dataframe 'datafr_numexp', from the input '_num.txt' and the already defined 'depthrow', to store simulated data.
  datafr_numexp <- data.frame(depth1 = depthrow, num1 = num_read$V1, num2 = (num_read$V2)/cell) # Multiply by the cell size to calculate Bq/m3
  
  exp <- data.frame(data2[, c("depth_i", "depth_f", "Cs137_invt")])
  colnames(exp) <- c("z1", "z2", "cs")
  sim <- data.frame(z1 = depthrow-cell_value, z2 = depthrow, cs = num_read$V2) # Multiply by the cell size to calculate Bq/m3
  sim <- resample(sim, exp)
  data3_mod <-data.frame(id = data2$id, midPROF=(data2$depth_i+((data2$depth_f-data2$depth_i)/2)), y=data2$Cs137_invt*100/(data2$depth_f*100-data2$depth_i*100), invCS=sim$cs)

  # Read '_exp.txt' in 'exp_read.' the experimental data for unit cell.
  exp_data <- read.table(file.path(dir1, "_exp.txt"), comment.char = "#")
  exp_read <- data.frame(cs_inv = (exp_data$V1)/cell) # Multiply by the cell size to calculate Bq/m3
  # Create dataframe 'plot_data' for the plot code.
  # COLUMNS:
  # depth1 ;
  # num1 (first column from "_num.txt");
  # num2 (second column from "_num.txt");
  # cs_inv (data2$Cs137_invt for each cell);
  plot_data <- cbind(datafr_numexp, exp_read)

  # Preparation of limits, ranges and axis values. |||||||||| WARNING: PLOTS ARE ROTATED TO ADABT THE STEP-PLOT TO A VERTICAL PROFILE, defined x axis here will be y axis in the resulting plot. ||||||||||
  # Total experimental inventory 'expinv' to add in the results legend.
  expinv <- sum(data2$Cs137_invt)
  # Total simulated inventory 'siminv' to add in the results legend.
  siminv <- sum(plot_data$num2*cell)

  # Define the maximum inventory between all the profiles in 'plot_data'.
  if (is.null(AxisMaxValue)) {
    max_CSinv <- max(c(max(plot_data$num2, na.rm = TRUE), max(plot_data$cs_inv, na.rm = TRUE)))
  } else {
    max_CSinv <- AxisMaxValue
  }

  # Define the y axis range for the  inventory plot as multiples of ten
  if (is.null(AxisMaxValue)) {
    y_range <- c(0, ceiling((max_CSinv + max_CSinv/10) / 10) * 10 + max_CSinv/4)
  } else {
    y_range <- c(0, AxisMaxValue)
  }
  if (is.null(AxisMaxValue)) {
    y_range_max <- ceiling((max_CSinv + max_CSinv/10) / 10) * 10 + max_CSinv/4
  } else {
    y_range_max <- AxisMaxValue
  }

  # Calculate the size of the 'y-range'.
  range_size <- y_range[2] - y_range[1]
  # Determine the interval for y-axis tick marks based on the size of the range.
  if (range_size <= 100) {
    tick_interval <- 10
  } else if (range_size <= 200) {
    tick_interval <- 20
  } else if (range_size <= 500) {
    tick_interval <- 50
  } else if (range_size <= 1000) {
    tick_interval <- 100
  } else if (range_size <= 2000) {
    tick_interval <- 200
  } else if (range_size <= 3000) {
    tick_interval <- 500
  } else if (range_size <= 7000) {
    tick_interval <- 1000
  } else if (range_size <= 13000) {
    tick_interval <- 2000
  } else if (range_size <= 50000) {
    tick_interval <- 5000
  } else {
    tick_interval <- 10000
  }
  # Create breaks for the y-axis.
  y_breaks <- seq(y_range[1], y_range[2], by = tick_interval)
  # Create breaks for the x-axis.
  x_breaks <- seq(0, depth, by = 0.1)

  # Define the step function for the experimental inventory plot.
  inv_exp <- stepfun( x = head(plot_data[["depth1"]], -1), y = plot_data[["cs_inv"]])
  step_exp <- data.frame(x = c( plot_data[["depth1"]]))
  step_exp$y <- inv_exp(step_exp$x)


	if(nrow(exp) == 1) # bulk profile
	{
		plot_data$num2 <- plot_data$cs_inv * siminv / expinv
	}

  p_base <- ggplot(plot_data) +
    # Range and orientation of the y-axis of inventory step-plot.
    coord_flip(ylim= y_range, expand = FALSE) +
    # X Y -axis and its labels.
    scale_x_reverse(breaks = x_breaks) +
    scale_y_continuous(breaks=y_breaks, position="right")+
    # Experimental Inventory step-plot.
    geom_step(data = step_exp, aes(x = x, y = y, color="Exp. inv."),direction= "vh" ) +
    # Segmented Line: Simulated Inventory.
    #geom_segment(aes(x = depth1, y = num2, xend = dplyr::lead(depth1), yend =dplyr::lead(num2), color="Sim. inv."),alpha = 0.5, na.rm = TRUE, linetype = "dashed") +
    geom_line(aes(x = depth1, y = num2, color="Sim. inv."),alpha = 1.0, na.rm = TRUE, linetype = "longdash") +
    # Axis titles.
    labs(title =paste("Soil profile id:", unique(data2$id)), y = expression(" Bq m"^"-3"), x = "Depth m", color=NULL) +
    # Legend.
    scale_color_manual(values =c("Exp. inv."="blue", "Sim. inv."="red"), labels = c(bquote("Exp. Inv." == .(round(expinv))~"Bq m"^"-2"),bquote("Sim. Inv." == .(round(siminv))~"Bq m"^"-2"))) +
    # General aspects.
    theme(plot.margin = margin(10, 10, 10, 10),
          panel.background = element_rect(fill = "white"),
          panel.grid.major.y = element_line(color = "gray",linewidth = 0.5, linetype = 3),
          panel.grid.minor = element_blank(),
          axis.text.x = element_text(angle = 90, hjust=0.1),
          axis.line = element_line(color = "black",linewidth = 0.5, linetype = 1),
          legend.position = "bottom",
          legend.direction = "vertical")

  p_text <- ggplot(plot_data, mapping = aes(x = depth1, y = y_range)) +
    # Range and orientation of the y-axis of inventory step-plot.
    coord_flip(ylim= y_range, expand = FALSE) +
    # X Y -axis and its labels.
    scale_x_reverse() +
    scale_y_continuous(position="right")+
    # one laine to determine the y axis.
    geom_line(aes(x=depth1, y=0), color = "grey") +
    #  titles.
    labs(y= expression("Bq m"^"-2"),x = NULL  ) +
    # Text
    geom_text(data= data2_mod, aes(x=midPROF,y=y_range_max/2,label=as.character(round(invCS))), size = 3 , parse = TRUE,color="blue") +
    # General aspects.
    theme(plot.margin = margin(10, 10, 10, 0),
          panel.background = element_rect(fill = "white"),
          axis.text.x = element_blank(),
          axis.text.y = element_blank(),
          axis.ticks = element_blank(),
          panel.grid.minor = element_blank())

  p_text2 <- ggplot(plot_data, mapping = aes(x = depth1, y = y_range)) +
    # Range and orientation of the y-axis of inventory step-plot.
    coord_flip(ylim= y_range, expand = FALSE) +
    # X Y -axis and its labels.
    scale_x_reverse() +
    scale_y_continuous(position="right")+
    # one laine to determine the y axis.
    geom_line(aes(x=depth1, y=0), color = "grey") +
    #  titles.
    labs(y= expression("Bq m"^"-2"),x = NULL  ) +
    # Text
    geom_text(data= data3_mod, aes(x=midPROF,y=y_range_max/2,label=as.character(round(invCS))), size = 3 , parse = TRUE,color="red") +
    # General aspects.
    theme(plot.margin = margin(10, 0, 10, 0),
          panel.background = element_rect(fill = "white"),
          axis.text.x = element_blank(),
          axis.text.y = element_blank(),
          axis.ticks = element_blank(),
          panel.grid.minor = element_blank())

  # Combined plots
  p <- p_base + p_text + p_text2 + plot_layout(ncol = 3, widths = c(4, 0.9, 0.9))

  # Display the plot
  plot_file <- file.path(results_folder, paste0(tail(data2$id, 1),"_plot.png"))
  ggsave(filename = plot_file, plot = p , width = 4, height = 4)
  print(p)

}
