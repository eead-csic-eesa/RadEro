#' @title Resample Configuration Data
#'
#' @description
#' "resample_config" adjusts and modifies a input configuration file based on the input data. The function resamples, filters and restructures data according to the parameters passed in the configuration file. It also interacts with a directory specified by the user for output.
#'
#' @details
#' This function takes three arguments: a dataset ("data2"), a configuration object ("config1"), and a directory path ("dir1"). The function applies resampling methods to the data as specified by "config1". The resampled data is typically saved to the provided directory.
#'
#' @param data2 Input data by ID. The input data to be resampled or transformed.
#' @param config1 Input configuration. Configuration details that dictate how the data should be processed, including resampling methods, filters, and other transformation rules.
#' @param dir1 Temporal directory. Path to the folder where output config file should be saved.
#'
#' @returns A modified version of "config1" named "_config.js" that will be read by the C model.


resample_config <- function(data2, config1, dir1) {

  temp_config_path <- file.path(dir1,"_config.js")

  #Eliminate "_config.js" if it already exist.
  if (file.exists(temp_config_path)) {
    file.remove(temp_config_path)
  }

  #Copy selected radioisotopic configuration.
  temp_config <- config1


  verify <- function (v1){
    ifelse(is.na(v1), 0.0, v1)
  }


  #Modify values according to "data2".
  temp_config["soil-thickness"] <- verify(tail(data2$lower_boundary, 1))
  temp_config["soil-effective-volume"] <- verify(tail(data2$effVol, 1))
  temp_config["soil-density"] <- verify(tail(data2$density, 1))
  temp_config["mix-from-depth"] <- verify(tail(data2$mix_depth_i, 1))
  temp_config["mix-to-depth"] <- verify(tail(data2$mix_depth_f, 1))
  temp_config["mix-interval"] <- verify(tail(data2$mix_frequency, 1))
  temp_config["mix-inicial-year"] <- verify(tail(data2$mix_year_i, 1))
  temp_config["mix-final-year"] <- verify(tail(data2$mix_year_f, 1))
  temp_config[["fallout"]][["reference-inventory"]] <- verify(tail(data2$Ref_Cs137_invt, 1))
  #Modify values k according to "data2".
  kx <- tail(data2$k, 1)
  if (!is.na(kx)) {
  temp_config[["optimization"]][["k-initial"]] <- verify(kx)
  temp_config[["optimization"]][["k-final"]] <- verify(kx)
  temp_config[["optimization"]][["k-samples"]] <- 1
  }
  #Modify values e according to "data2".
  ex <- tail(data2$e, 1)
  if (!is.na(ex)) {
    temp_config[["optimization"]][["e-initial"]] <- verify(ex)
    temp_config[["optimization"]][["e-final"]] <- verify(ex)
    temp_config[["optimization"]][["e-samples"]] <- 1
  }

  #Create temporal _config sample file.
  temp_config_js <- toJSON(temp_config, auto_unbox = TRUE, pretty = TRUE)
	#cat(temp_config_js)
  writeLines(temp_config_js, con = temp_config_path)
}
