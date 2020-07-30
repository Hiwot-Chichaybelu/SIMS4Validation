require(devtools)
require(SIMS4Validation)
require(datimvalidation)

datimvalidation::loadSecrets("~/Documents/datim-validation/datim.json")

# folder where file is located, and where output files will be written to
folder <- "~/USAID/"
out_dir <- folder
# name of the file to validate
filename <- "usaid.csv"

# type of the file (json, xml, or csv)
file_type <- "csv"

# identifier scheme used in the input file
idScheme <- "code"
dataElementIdScheme <- "name"
orgUnitIdScheme <-"id"

# calendar period (quarter) covered by the input file in YYYYQN format, e.g. 2019Q3 for July-September 2019
isoPeriod <- "2019Q4"

# whether the input file has the header as the first line
fileHasHeader <- TRUE

#remove CEEs and assessments that fail validation checks
remove <- TRUE

SIMS4Validation::SIMSValidationScript(out_dir,filename,file_type,idScheme,dataElementIdScheme,orgUnitIdScheme,isoPeriod,fileHasHeader,remove)
