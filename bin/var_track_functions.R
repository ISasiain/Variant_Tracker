#!/usr/bin/env Rscript

path_var_detector <- function(clinvar_ref_file, bim_file) {
  
  # Reading the clinvar variant files and bim files as dataframes
  clinvar <- read.csv(file=clinvar_ref_file, sep="\t")
  bim <- read.csv(file=bim_file, sep="\t", header=FALSE)
  
  # Filter the dataframes to get only the variants found in both dataframes
  matches_bim <- bim[,2] %in% clinvar[,2]
  matches_clinvar <- clinvar[,2] %in% bim[,2]
  
  # Getting unique values per variant
  matching_bim <- unique(bim[matches_bim,])
  matching_clinvar <- unique(clinvar[matches_clinvar,])
  
  # Creating the output
  
  # Creating the list to return
  ret_ls=list()
  
  # If no pathogenic variant has been identified return the following message
  if (nrow(matching_bim) == 0) {
    
    # Returning an empty list
    return(ret_ls)
    
    # If the number of pathogenic variants identified is different to 0 print the informetion of each idetified variant
  } else {
    # Looping through the variants identified
    for (var in 1:nrow(matching_bim)) {
      ret_ls[[matching_bim[var,2]]] <- paste(
                              "A", matching_clinvar[var,3], "genetic variant has been detected in the individual analysed.",
                              "The variant affects the gene", matching_clinvar[var,4], "and has been associated with the following genotype:", matching_clinvar[var,5], ".",
                              "The variant is located in the position", matching_bim[var,4], "of chromosome", matching_bim[var,1], ".")
    }
    return(ret_ls)
  }
}