checkCoverSheetCompleteness <- function(data_dictionary,path){
  coversheet_data_elements <- read_excel(path = data_dictionary, sheet = "Coversheet")
  print(coversheet_data_elements)
}
