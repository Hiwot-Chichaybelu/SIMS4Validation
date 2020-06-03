checkCoverSheetCompleteness <- function(data_dictionary,folder,fileHasHeader,de_map){
  #cover sheet data elements in data dictionary
  data_dictionary_CS_data_elements <- readxl::read_excel(path = data_dictionary, sheet = "Coversheet",range = "D1:D38")
  data_dictionary_CS_data_elements <- data_dictionary_CS_data_elements[!(data_dictionary_CS_data_elements$`DATA POINT ID - 4.0`=='Inherent to DATIM'),]

  data_dictionary_CS_data_elements <- as.list(data_dictionary_CS_data_elements$`DATA POINT ID - 4.0`)

  #data elements in file to validate
  #data_elements <- read.csv(folder, header = fileHasHeader)[ ,1:1]
  data_elements <- read.csv(folder, header = fileHasHeader)
  #data_elements <- dplyr::select(data_elements,1,6)

  data_elements_by_assessment<-split(data_elements, data_elements[,7])
  d = NULL


  for(i in 1:length(data_elements_by_assessment)){
    list_of_CS <- vector("list", length(data_dictionary_CS_data_elements))
    index <- 1
    for(j in data_elements_by_assessment[[i]][,1]){
      if(length(de_map) > 0){
        j <- de_map[[j]]
      }
      if(startsWith( j, 'SIMS.CS')) {
        list_of_CS[[index]] <- j
        index <- index + 1
      }
    }
    #	If assessment type is missing, cover sheet is incomplete
    if(!('SIMS.CS_ASMT_TYPE' %in% list_of_CS)){
      d = rbind(d, data.frame('Missing CS Data Elements'='SIMS.CS_ASMT_TYPE', Assessment=names(data_elements_by_assessment)[i]))

      # remove rows with this assessment
      data_elements <- data_elements[data_elements[,7] != names(data_elements_by_assessment)[i],]
    }
    else{
      for(j in 1:length(data_elements_by_assessment[[i]][,1])){
        de <- NULL
        if(length(de_map) > 0){
          de <- de_map[[data_elements_by_assessment[[i]][j,1]]]
        }
        else{
          de <- data_elements_by_assessment[[i]][j,1]
        }
        if(de %in% c('SIMS.CS_ASMT_TYPE')){
          #Comprehensive assessment
          if(data_elements_by_assessment[[i]][j,6] %in% c('1')){
            for(k in data_dictionary_CS_data_elements){
              if(!startsWith(k, 'SIMS.CS_ASMT_REASON')){
                if(!(k %in% list_of_CS)){
                  d = rbind(d, data.frame('Missing CS Data Elements'=k, Assessment=names(data_elements_by_assessment)[i]))

                  #remove assessment
                  data_elements <- data_elements[data_elements[,7] != names(data_elements_by_assessment)[i],]
                }
              }
            }

            #if list doesn't have at least one reason
            #if(!(list_of_CS %like% 'SIMS.CS_ASMT_REASON%')){
            # d = rbind(d, data.frame('Missing CS Data Elements'=k, Assessment=names(data_elements_by_assessment)[i]))
            # }
            sub_list <- grep("REASON", list_of_CS)
            if(length(sub_list) < 1){
              d = rbind(d, data.frame('Missing CS Data Elements'='SIMS.CS_ASMT_REASON*', Assessment=names(data_elements_by_assessment)[i]))
              #remove assessment
              data_elements <- data_elements[data_elements[,7] != names(data_elements_by_assessment)[i],]
            }

        }
        #Followup assessment
        else if(data_elements_by_assessment[[i]][j,6] %in% c('2')){
          for(k in data_dictionary_CS_data_elements){
            if(!startsWith(k, 'SIMS.CS_ASMT_REASON')){
              if(!(k %in% list_of_CS)){
                d = rbind(d, data.frame('Missing CS Data Elements'=k, Assessment=names(data_elements_by_assessment)[i]))
                #remove assessment
                data_elements <- data_elements[data_elements[,7] != names(data_elements_by_assessment)[i],]
              }
            }
          }

          #if list has at least one reason
          sub_list <- grep("REASON", list_of_CS)
          if(length(sub_list) > 0){
            d = rbind(d, data.frame('Missing CS Data Elements'='SIMS.CS_ASMT_REASON*', Assessment=names(data_elements_by_assessment)[i]))
            #remove assessment
            data_elements <- data_elements[data_elements[,7] != names(data_elements_by_assessment)[i],]
          }
         }
        }
      }

      }
  }
  write.csv(data_elements, paste0(folder, "_assessmentRemoved.csv"), row.names=FALSE, na="")

  return (d)
}
