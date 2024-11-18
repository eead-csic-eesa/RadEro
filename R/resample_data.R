#' @title Resample Input Data
#'
#' @description
#' "resample_data" processes the data based on predefined rules before being read by the C model, and saves the output in a specified directory.
#'
#' @details
#' This function takes two arguments: a dataset ("data2") and the temporal directory path ("dir1").
#'
#' @param data2 Input data by ID. The input dataset to be resampled or transformed.
#' @param dir1 Temporal directory. Path to the folder where the resampled data will be saved.
#'
#' @returns A resampled version of "data2" named "_exp.txt" saved in the directory specified by "dir1."


resample_data <- function(data2, dir1) {

  temp_exp_path <- file.path(dir1, "_exp.txt")

  if (file.exists(temp_exp_path)) {
      file.remove(temp_exp_path)
  }

  # Function resample to write '_exp.txt'.
  resample <- function(df1, df2)
  {
    for(i in 1:nrow(df2))
    {
      z1 <- df2$z1[i]
      z2 <- df2$z2[i]

      inv <- 0.0
      for(j in 1:nrow(df1))
      {
        oz1 <- df1$z1[j]
        oz2 <- df1$z2[j]
        oinv <- df1$inv[j]

        if(z1 < oz1 && z2 > oz1 && z2 <= oz2)
        {
          inv = inv + oinv * (z2-oz1) / (oz2-oz1)
        }
        else if(z1 >= oz1 && z2 <= oz2)
        {
          inv = inv + oinv * (z2-z1) / (oz2-oz1)
        }
        else if(z1 >= oz1 && z1 <= oz2 && z2 > oz2)
        {
          inv = inv + oinv * (oz2-z1) / (oz2-oz1)
        }
        else if(z1 <= oz1 && z2 >= oz2)
        {
          inv = inv + oinv
        }
      }
      df2$inv[i] <- inv
    }

    df2
  }


  z1 <- c(data2[["depth_i"]])
  z2 <- c(data2[["depth_f"]])
  inv <-c(data2[["Cs137_invt"]])
  exp <- data.frame(z1, z2, inv)
  exp
  sum(exp$inv)

  tz <- tail(data2$lower_boundary, 1)
  n <- tail(data2$lower_boundary, 1) * 100
  dz <- tz / n

  z1 <- c()
  z2 <- c()
  inv <- c()
  for(i in 1:n)
  {
    z1 <- c(z1, (i-1)*dz)
    z2 <- c(z2, i*dz)
    inv <- c(inv, 0)
  }
  sim <- data.frame(z1, z2, inv)
  sim <- resample(exp, sim)
  head(sim)
  sum(sim$inv)

  exp <- resample(sim, exp)
  exp
  sum(exp$inv)

  # Write temporal '_exp.txt'.
  write.table(sim[,3], file = temp_exp_path, sep = "\t", row.names = FALSE, col.names = FALSE)

}


