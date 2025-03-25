#' RadEro: Physically Based Compartmental Model for 137Cs Analysis and Soil Redistribution Rates Estimation
#' @name RadEro
#'
#' @description
#' RadEro is a straightforward model to estimate soil migration rates across various soil contexts. Building on the compartmental, vertically-resolved, physically-based mass balance model of Soto and Navas (2004, 2008), RadEro is accessible as a user-friendly R package. Input data, including 137Cs inventories and parameters directly derived from soil samples (e.g., fine fraction density, effective volume), accurately capture 137Cs distribution within the soil profile. The model simulates annual 137Cs fallout, radioactive decay, and vertical diffusion, using a diffusion coefficient derived from 137Cs reference inventory profiles. RadEro also accommodates user-defined parameters as calibration coefficients. The package, code, and test data are openly accessible for widespread use.
#'
#' @author
#' * Arturo Catala ([ORCID](https://orcid.org/0009-0008-7996-1870))
#' * Borja Latorre ([ORCID](https://orcid.org/0000-0002-6720-3326))
#' * Leticia Gaspar ([ORCID](https://orcid.org/0000-0002-3473-7110))
#' * Ana Navas ([ORCID](https://orcid.org/0000-0002-4724-7532))
#'
#' @md
#'
#' @seealso
#'
#' * [GitHub repository](https://github.com/eead-csic-eesa/RadEro)
#'
#' @examples
#' \donttest{
#'
#' # Step 1: RadEro requires a specific structure for data and configuration files.
#' # The "RadEro_examples" function creates sample files (.csv and .js)
#' # in the specified output directory.
#'
#' RadEro_example()
#' # These files can be used as templates for user projects.
#'
#' # Step 2: Run the model with the example files and define the output directory.
#'
#' RadEro_run(data = "input-data_example.csv",
#'            config = "input-config_example.js")
#' }
#'
#' @return A "results" folder containing for each analyzed profile: a) ID_plot.png: Experimental (blue) and simulated (red) inventory depth profile plots; b) ID_tempfile: Experimental inventory (Bq /kg1) per cell unit in the defined profile depth; c) results.txt: Summary file with columns for ID, migration rate (e), erosion rate (m), diffusion coefficients (k and kv), total experimental inventory, and total simulated inventory; d) Additionally, a "temp" folder for advanced users is created for each profile, containing configuration and inventory files related to individual analyses.
#'
#'

#' @keywords internal
"_PACKAGE"
## usethis namespace: start
## usethis namespace: end
NULL
