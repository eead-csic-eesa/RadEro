#' @title Copy Example Files from Package Data Directory to a Specified Directory
#'
#' @description
#' This function copies example files (e.g., .js and .csv) from the "data" directory of the package to a specified working directory.
#'
#' @details
#' The function uses "system.file()" to locate the example files within the package's "data" directory and copies them to a directory of your choice using "file.copy()".
#'
#' @param target_dir  The path to the directory where the files will be copied.
#' @param overwrite Logical. Whether to overwrite the files if they already exist in the target directory (default is TRUE).
#'
#' @return This function generates two templates files for a reference site and two template files for study sires in the specified directory: each set has one file for data input and another for configuration input. These templates serve as examples, demonstrating how to construct and format the input files.
#'
#' @export

RadEro_example <- function(target_dir=NULL, overwrite = TRUE) {

  # Detect if it's runing in `R CMD check` context.
  if (is.null(target_dir) || nzchar(Sys.getenv("R_TESTS"))) {
    target_dir <- tempdir()  # Usar el directorio temporal de `R CMD check`
  }

  # Ensure the target directory exists
  if (!dir.exists(target_dir)) {
    stop("Target directory does not exist: ", target_dir)
  }

  # List of files in the data directory of the package
  files_to_copy <- c("input-data_example.csv", "input-config_example.js","input-data_example_reference.csv", "input-config_example_reference.js")

  # Loop over files and copy them to the target directory
  for (file_name in files_to_copy) {
    file_path <- system.file("extdata", file_name, package = "RadEro")

    if (file_path == "") {
      warning("File not found in package data directory: ", file_name)
      next
    }

    # Construct the destination file path
    destination <- file.path(target_dir, file_name)

    # Copy the file to the target directory
    file.copy(from = file_path, to = destination, overwrite = overwrite)

    message("Copied: ", file_name, " to ", target_dir)
  }
}
