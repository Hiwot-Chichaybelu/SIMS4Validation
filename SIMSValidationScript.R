require(devtools)
#install_github("Hiwot-Chichaybelu/SIMS4Validation", force=TRUE)
require(SIMS4Validation)
#install_github("jason-p-pickering/datim-validation", force=TRUE)
require(datimvalidation)

datimvalidation::loadSecrets("~/Documents/datim-validation/datim.json")
#Data dictionary location
data_dictionary <- "~/Downloads/SIMS_4.1_DataDictionary_MASTER_2020Apr6.xlsx"

# folder where file is located, and where output files will be written to
folder <- "~/USAID/"
out_dir <- folder
# name of the file to validate
filename <- "usaid.csv"

# type of the file (json, xml, or csv)
file_type <- "csv"

# identifier scheme used in the input file
idScheme <- "id"
dataElementIdScheme <- "name"
orgUnitIdScheme <-"id"

# calendar period (quarter) covered by the input file in YYYYQN format, e.g. 2019Q3 for July-September 2019
isoPeriod <- "2019Q4"

# whether the input file has the header as the first line
fileHasHeader <- TRUE

#remove CEEs and assessments that fail validation checks
remove <- TRUE

bad_data_values <- SIMS4Validation::simsValidator(data_dictionary,out_dir,filename,file_type,idScheme,dataElementIdScheme,orgUnitIdScheme,isoPeriod,fileHasHeader)

path <- paste0(folder, filename)

#if dataElementIdScheme is id, construct map of data element ID and name
de_map = vector(mode = "list")
if(dataElementIdScheme %in% c("id")){
  data_elements <- read.csv(path, header = fileHasHeader)
  distinct_dataElements <- data_elements[!duplicated(data_elements[,1]),]
  for(row in 1:length(distinct_dataElements[,1])) {
    url <- paste0(getOption("baseurl"), "api/",
                  "dataElements/",distinct_dataElements[row,1],".json?fields=name")
    r <- httr::GET(url, httr::timeout(60))
    r <- httr::content(r, "text")
    de <- jsonlite::fromJSON(r, flatten = TRUE)$name
    key <- paste0("",distinct_dataElements[row,1])
    if(is.null(de_map[[key]])){
      de_map[[key]] <- de
    }
  }
}
incomplete_CS <- SIMS4Validation::checkCoverSheetCompleteness(data_dictionary,path,fileHasHeader,de_map)
if(!is.null(incomplete_CS) && nrow(incomplete_CS) != 0) {
  write.csv(incomplete_CS,file=paste0(folder, filename, "_incomplete_CS.csv"))
}

wrongType <- SIMS4Validation::checkForWrongAssessmentType(data_dictionary,path,fileHasHeader,de_map)
if(!is.null(wrongType) && nrow(wrongType) != 0) {
  write.csv(wrongType,file=paste0(folder, filename, "_wrongToolType.csv"))
}

inValidCEE <- SIMS4Validation::checkForCEEValidity(data_dictionary,path,fileHasHeader,de_map,bad_data_values)
if(!is.null(inValidCEE) && nrow(inValidCEE) != 0) {
  write.csv(inValidCEE,file=paste0(folder, filename, "_inValidCEE.csv"))
}
