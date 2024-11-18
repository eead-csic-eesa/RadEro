#' Starts conversion model for soil redistribution
#'
#' Initiates the model based on the Cs137 inventory data from soil profiles according to the specified configuration in the working directory.
#'
#' @param data A data frame containing the Cs137 inventory data from soil profiles. It must be located in the working directory.
#' @param config A list or configuration file that defines the parameters for the model run. It must be located in the working directory.
#' @param AxisMaxValue Optional. A numeric value specifying the maximum value for the axes in the plot. Defaults to NULL.
#' @param output_dir The directory where the output files will be saved. Defaults to a temporary directory.
#'
#' @return A "results" folder containing for each analyzed profile: a) ID_plot.png: Experimental (blue) and simulated (red) inventory depth profile plots; b) ID_tempfile: Experimental inventory (Bq/kg) per cell unit in the defined profile depth; c) results.txt: Summary file with columns for ID, migration rate (e), erosion rate (m), diffusion coefficients (k and kv), total experimental inventory, and total simulated inventory; d) Additionally, a "temp" folder for advanced users is created for each profile, containing configuration and inventory files related to individual analyses.
#'
#' @import Rcpp
#' @import roxygen2
#' @import usethis
#' @import jsonlite
#' @import data.table
#' @import devtools
#' @import ggplot2
#' @import patchwork
#' @importFrom utils head read.table tail write.table globalVariables
#' @importFrom stats stepfun
#'
#' @useDynLib RadEro
#' @export
#'
#' @name RadEro_run
#'

RadEro_run <- function(data, config, AxisMaxValue = NULL, output_dir = NULL) {
  message("Starting RadEro_run...\n")

  # Detect if it's runing in `R CMD check` context.
  if (is.null(output_dir) || nzchar(Sys.getenv("R_TESTS"))) {
    output_dir <- tempdir()  # Usar el directorio temporal de `R CMD check`
  }

  #Save the current working directory
  oldwd <- getwd()
  on.exit(setwd(oldwd))
  message(oldwd)

  # Directory for output (dir2)
  dir2 <- output_dir
  message("\n Current directory:", dir2, "\n")

  # Copy of dir1 files on dir2 to do a quick check.
  dir_temp <- file.path(dir2, "temp")
  # Check if the directory already exists, and create it if not
  if (dir.exists(dir_temp)) {
    unlink(dir_temp, recursive = TRUE) # Delete the directory if it exists
    dir.create(dir_temp) # Create the directory
  }

  # Path to the model file
  model_path <- system.file( "src", "cs_model.so", package = "RadEro")
  # Read data from the specified file
  data1 <- fread(file.path(dir2, data), sep = ";", header = TRUE)
  # Read configuration from the specified file
  config_path <- file.path(dir2, config)
  config1 <- fromJSON(paste(readLines(config_path), collapse = "\n"))

  # Get unique values from the 'id' column.
  unique_ids <- unique(data1$id)

  # Create results folder and "results.txt".
  results_folder <- file.path(dir2, "results")
  results_file_path <- file.path(results_folder, "results.txt")
  dir.create(results_folder, showWarnings = FALSE) # Create results folder if it doesn't exist
  if (file.exists(results_file_path)) {
    file.remove(results_file_path) # Remove existing 'results.txt' if it exists
    #message("Removed existing 'results.txt'.\n")
  }

  # Loop through the unique values of 'id'.
  for (i in unique_ids)
  {
    # Filter values to current 'id'.
    data2 <- data1[data1$id == i, ]
	message(sprintf(" \n ---- Simulating profile: %s --------------\n", i))

    # Check in the loop if the directory already exists, delete previous one and create a new one
    if (dir.exists(dir_temp)) {
      unlink(dir_temp, recursive = TRUE) # Delete the directory if it exists
    }
    dir.create(dir_temp) # Create the directory

    dir1 <- dir_temp

    # Create "_config.js".
    tryCatch({
      resample_config(data2, config1, dir1)
      #message(sprintf(" %s specific profile configuration file created and saved in %s.\n", ,results_folder))
    }, error = function(e) {
      message("Error in config file '_config.js':", conditionMessage(e), "\n")
    })

    # Create "_exp.txt".
    tryCatch({
      resample_data(data2, dir1)
      #message(sprintf(" %s segmented mesured activity file '_exp.txt' created and saved in %s.\n", ,results_folder))
    }, error = function(e) {
      message("Error creating '_exp.txt':", conditionMessage(e), "\n")
    })

    #Change the working directory to the temporary directory
    setwd(dir1)

	# Execute the model
	tryCatch({
		rcpp_cs_model()# Replace with your actual model execution code
	  message(sprintf(" %s successfully simulated. \n",i))
	}, error = function(e) {
	  message("\n Error executing the model:", conditionMessage(e), "\n")
	})

    # Read data2 from 'resultstemp.txt'.
    resultstemp_data <- read.table(file.path(dir1, "resultstemp.txt"))
    formatted_row <-  c(id = paste("id =",i, ","),resultstemp_data)

    # To check temporal files
    list_tempfiles <- list.files(dir1)
    file.copy(file.path(dir1,list_tempfiles), dir_temp)

	# Append data2 to 'results.txt'.
	write.table(formatted_row, file = results_file_path, append = TRUE, sep = " ", col.names = FALSE, row.names = FALSE, quote = FALSE)
	message(sprintf("\n %s results saved in %s.\n" ,i,results_folder))

	# Create "id_tempFiles" folder in the results folder
    id_tempFiles_folder <- file.path(results_folder, paste0(i, "_tempFiles"))
	if (dir.exists(id_tempFiles_folder)) {
    unlink(id_tempFiles_folder, recursive = TRUE) # Delete the directory if it exists
	}
    dir.create(id_tempFiles_folder, showWarnings = FALSE) # Create the directory

	# Get a list of all files in the source directory
	list_tempfiles <- list.files(dir1, full.names = TRUE)

	# Copy files to the new directory
	file.copy(from = list_tempfiles, to = id_tempFiles_folder, overwrite = TRUE, recursive = TRUE)
  message(config1$`cell-thickness`)

	# Execute 'plot.R'.
      tryCatch({
         plot(data1, data2, dir1, dir2, AxisMaxValue, cell_value = config1$`cell-thickness`)
        #message(sprintf(" %s plot saved in %s.\n", , results_folder))
       } ,error = function(e) {
         message("\n Error executing 'plot.R':", conditionMessage(e), "\n")
      })

  # Change the working directory back to the original
  setwd(oldwd)
  }

  message(" RadEro_run finished.\n")

}
