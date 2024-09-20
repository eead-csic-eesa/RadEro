#' RadEro: Physically Based Compartmental Model for 137Cs Analysis and Soil Redistribution Rates Estimation
#' @name RadEro
#'
#' @description
#' RadEro is a straightforward model to estimate soil migration rates across various soil contexts. Building on the compartmental, vertically-resolved, physically-based mass balance model of Soto and Navas (2004, 2008), RadEro is accessible as a user-friendly R package. Input data, including 137Cs inventories and parameters directly derived from soil samples (e.g., fine fraction density, effective volume), accurately capture 137Cs distribution within the soil profile. The model simulates annual 137Cs fallout, radioactive decay, and vertical diffusion, using a diffusion coefficient derived from 137Cs reference inventory profiles. RadEro also accommodates user-defined parameters as calibration coefficients. The package, code, and test data are openly accessible for widespread use.
#'
#' @author
#' * Arturo Catalá <acatalae@gmail.com> ([ORCID](https://orcid.org/0009-0008-7996-1870))
#' * Borja Latorre <borja.latorre@csic.es> ([ORCID](https://orcid.org/0000-0002-6720-3326))
#' * Leticia Gaspar ([ORCID](https://orcid.org/0000-0002-3473-7110))
#' * Ana Navas ([ORCID](https://orcid.org/0000-0002-4724-7532))
#'
#' @md
#'
#' @seealso
#' Useful links:
#' * [GitHub repository](https://github.com/eead-csic-eesa/RadEro)
#'
#' @examples
#' # Example workflow for running the RadEro model:
#'
#' # Step 1: Define your working directory
#' directory <- getwd()  # You can change this to any other directory if needed
#'
#' # Step 2: Copy example files (.csv and .js) from the package to the working directory
#' RadEro_example(directory)
#' # Those files can be used as templates for your own projects.
#'
#' # Step 3: Execute the model with the example files
#' RadEro_run(data = "archivo_ejemplo.csv", config = "archivo_ejemplo.js")
#'

#' @keywords internal
"_PACKAGE"
## usethis namespace: start
## usethis namespace: end
NULL
