
# RadEro Model R pagkage
# A Compartmental and Physically Based Model to estimate Soil Redistribution Rates using 137Cs Analysis
# EESA group at EEAD-CSIC, Spain

# Sript to Install and Execute RadEro package (version 1.0.8) using an example (see PROTOCOL.pdf v1.0.8 on GitHub).
# GitHub link: https://github.com/eead-csic-eesa/RadEro
# Created by: Erosion & Soil and Water Evaluation Group
# Contact email: radero@eead.csic.es

################################################################################
# Option A) QUICK EXECUTION
################################################################################

setwd(R"(C:\your\own\working\directory)")
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
install.packages("RadEro_1.0.8.zip")
library (RadEro)

direct <- R"(C:\your\own\working\directory)"
RadEro_example(target_dir = direct)

#  RadEro_run() for reference site : estimate reference diffusion coefficient (k) from sectioned reference profile with null redistribution rate
RadEro_run("input-data_example_reference.csv","input-config_example_reference.js", output_dir = direct)
results <- read.table(R"(results\results.txt)", header = FALSE, sep = ",")
View(results)

#  RadEro_run() for sampling sites : estimate redistribution rate (e) with reference diffusion coefficient (k)
RadEro_run("input-data_example.csv","input-config_example.js", output_dir = direct)
results <- read.table(R"(results\results.txt)", header = FALSE, sep = ",")
View(results)


################################################################################
# Option B) Step by step explanation of the QUICK EXECUTION:
################################################################################

################################################################################
# 1 - INSTALLATION FROM CRAN
################################################################################

#### STEP 1 | Install the package:
# This will download the latest version of the RadEro package available on CRAN.
# For more details, visit the GitHub repository. https://github.com/eead-csic-eesa/RadEro

  install.packages("RadEro")

#### STEP 2 | Load the package:

  library (RadEro)


################################################################################
# 2 - INSTALLATION FROM GitHub
################################################################################

#### STEP 1 | Download the "RadEro_x.x.x.zip" file.
# Download the latest available version of RadEro from the GitHub repository:
# GitHub link: https://github.com/eead-csic-eesa/RadEro
# Save the file in a directory of your choice.

#### STEP 2 | Set the working directory to the location of "RadEro_x.x.x.zip".

setwd(R"(C:\your\own\working\directory)")

#### STEP 3 | Load necessary libraries to install the RadEro package.

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

#### Step 4 | Install RadEro package (Example: version 1.0.8)

install.packages("RadEro_1.0.8.zip")

#### STEP 5 | Load the package:

library (RadEro)



################################################################################
# 3 - EXAMPLE INPUT FILES: RadEro_example()
################################################################################

#### STEP 1 | Create a New Working Directory

direct <- R"(C:\your\own\working\directory)"

#### STEP 2 | Create the Example Input Files

RadEro_example(target_dir = direct)

# This has created 4 files:
#   a) Two input files that define an example of reference profile:
#       	File 1: "input-data_example_reference.csv"
#       	File 2: "input-config_example_reference.js"
#   b) Two input files that define an example of six sampling sites:
#       	File 3:"input-data_example.csv"
#       	File 4:"input-config_example.js"

# Block a) using File 1 and 2, RadEro Model will estimate the k (diffusion coefficient)
#  and e (redistribution rate) values.
# In these case undisturbed sectioned soil profile is needed. 

# Block b) using File 3 and 4, RadEro Model will estimate the e (redistribution rate) 
#  value using the k obtained from the reference site (kref).
# For sectionded profile at the sampling sites a k value can be estimated. However, 
#  we recoment to use the "kref" to estimate a reliable e value.

# The estimation of the "k" value will take more time than the estimation of the soil
#  redistribution rates from the sampling sites. Nevertheless, both operations are 
#  activeted with the same function, RadEro_run().



################################################################################
# 4 - DIFFUSION COEFFICIENT, ESTIMATE k VALUE: RadEro_run() for reference site
################################################################################

#### STEP 1 | Run the model

RadEro_run("input-data_example_reference.csv","input-config_example_reference.js", output_dir = direct)

# Depending on the resolution defined in the configuration file ("k-samples" and
# "e-samples" values), this process can take several minutes.
# Section 5 of this QuickStart Manual, already have the k value estimated.

#### STEP 2 | VISUALIZE the Output Files

results <- read.table(R"(results\results.txt)", header = FALSE, sep = ",")
View(results)

# The folder containing plots and the soil redistribution rates is in "results.txt"
# will be created in the "direct" directory.
# You can take the k value estimated  from the "results.txt" file.



################################################################################
# 5 - SOIL REDISTRIBUTION RATE, ESTIMATE e VALUE:  RadEro_run() for sampling sites
################################################################################

#### STEP 1 | Run the model

RadEro_run("input-data_example.csv","input-config_example.js", output_dir = direct)

#### STEP 2 | VISUALIZE the Output Files

results <- read.table(R"(results\results.txt)", header = FALSE, sep = ",")
View(results)

# The folder containing plots and the soil redistribution rates in "results.txt"
# will be created in the "direct" directory. To visualize the results file.
