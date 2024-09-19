
# RadEro R pagkage 
# A Compartmental and Physically Based Model to estimate Soil Redistribution Rates using 137Cs Analysis
# EESA group at EEAD-CSIC, Spain

# Sript to Install and Execute RadEro package (version 1.0.3) using an example
# created by Arturo Catalá Escamilla | 2024.08.21
# modified by Leticia Gaspar | 2024.08.21

################################################################################

#### STEP 1 | SET Working Directory to "RadEro_1.0.3.zip" location
setwd(R"(C:\Users\lgaspar\Downloads\RadEro_1.0.3)")

#### Step 2 | LOAD Libraries Needed To Install RadEro package (version 1.0.3) 
load_libraries <- function() {
  library(Rcpp)
  library(roxygen2)
  library(usethis)
  library(jsonlite)
  library(data.table)
  library(devtools)
  library(ggplot2)
  library(patchwork)
  library(dplyr)
}
load_libraries()

#### Step 3 | INSTALL RadEro package (version 1.0.3) 
# Install RadEro package
install.packages("RadEro_1.0.3.zip")
# Load RadEro library
library(RadEro)

#### Step 4 | PREPARE Input files
# Create a folder for each project (e.g. example)
# Complete file "input-data.csv" with your own data following the protocol of RadEro package (version 1.0.3) (e.g. "input-data_example.csv")
# Complete file "input-config.js" with your own data following the protocol of RadEro package (version 1.0.3) (e.g. "input-config_example.csv")
# Set working directory of the project
setwd(R"(C:\Users\lgaspar\Downloads\RadEro_1.0.3\example)")

#### Step 5 | EXECUTE RadEro package (version 1.0.3)
# Execute "RadEro_run" function with specified input files: DATA "input-data.csv" and CONFIGURATION "input-config.js"
RadEro_run("input-data_example.csv","input-config_example.js")

#### Step 6 | VISUALIZE Output files
# Folder with plots and Soil Redistribution Rates in "results.txt" created
results <- read.table(R"(results\results.txt)", header = FALSE, sep = ",")
View(results)