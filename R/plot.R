#'  @title Plot of experimental and simulated profile inventories
#'
#'  @description
#'  'plot' returns two plots corresponding to the experimental and simulated inventories for each profile defined in the input data. Automatic function when you execute RadEro_run. It creates results folder in the current directory if didn't exist.
#'
#'  @details
#'  This 'plot' function performs several operations to create and save a combined plot displaying two types of inventories: one experimental and one simulated. It first creates a "results" folder within the directory specified by dir2. May delete the inner files of results folder if it already exists. delete previous  Then, it reads two text files, _num.txt and _exp.txt, from the directory specified by dir1. Next, it creates dataframes containing the necessary data for plotting. It calculates axis limits and labels using data from data1 and data2. Subsequently, it generates separate plots for the experimental and simulated inventories using ggplot2. These plots are combined into a single plot using the plot_layout() function. The combined plot is saved as a PNG file within the results folder, with a name based on the last id from data2. Finally, the combined plot is displayed in the console. This function utilizes ggplot2 and dplyr extensively for data manipulation and visualization.
#'
#'  @param data1 Dataframe of numeric vectors. Read input data in CSV format.
#'  @param data2 dataframe of numeric vectors. Filtered values of data1 for the current 'id'.
#'  @param dir1 Directory. Temporary working directory where the '_num.txt' and '_exp.txt' files were created.
#'  @param dir2 Directory. Current working directory.
#'  @param AxisMaxValue Maximum value to determine the x axis limit. Only used if the user wants to escalate all the simulated profiles .
#'  @param cell_value Unit cell size in meters.
#'
#'  @returns Results folder in dir2 with n plots saved as a PNG based on the n "id" defined in data2. Results summarized TXT file in the results folder.
#'

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
  expinv <- round(sum(data2$Cs137_invt))
  # Total simulated inventory 'siminv' to add in the results legend.
  siminv <- round(sum(plot_data$num2*cell))

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


  # Create step-plot according to experimental inventory layers and segemented plot according to simulated inventory layers.

  p_base <- ggplot(plot_data) +
    # Range and orientation of the y-axis of inventory step-plot.
    coord_flip(ylim= y_range, expand = FALSE) +
    # X Y -axis and its labels.
    scale_x_reverse(breaks = x_breaks) +
    scale_y_continuous(breaks=y_breaks, position="right")+
    # Experimental Inventory step-plot.
    geom_step(data = step_exp, aes(x = x, y = y, color="Exp. inv."),direction= "vh" ) +
    # Segmented Line: Simulated Inventory.
    geom_segment(aes(x = depth1, y = num2, xend = dplyr::lead(depth1), yend =dplyr::lead(num2), color="Sim. inv."),alpha = 0.5, na.rm = TRUE) +
    # Axis titles.
    labs(title =paste("Soil profile id:", unique(data2$id)), y = expression(" Bq m"^"-3"), x = "Depth m", color=NULL) +
    # Legend.
    scale_color_manual(values =c("Exp. inv."="blue", "Sim. inv."="red"), labels = c(bquote(Exp.Inv. == .(expinv)~"Bq m"^"-2"),bquote(Sim.Inv. == .(siminv)~"Bq m"^"-2"))) +
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
    theme(plot.margin = margin(10, 10, 10, 10),
          panel.background = element_rect(fill = "white"),
          axis.text.x = element_blank(),
          axis.text.y = element_blank(),
          axis.ticks = element_blank(),
          panel.grid.minor = element_blank())

  # Combined plots
  p <- p_base + p_text + plot_layout(ncol = 2, widths = c(4, 1))

  # Display the plot
  plot_file <- file.path(results_folder, paste0(tail(data2$id, 1),"_plot.png"))
  ggsave(filename = plot_file, plot = p , width = 4, height = 4)
  print(p)

}
