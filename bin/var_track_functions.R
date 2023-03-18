#!/usr/bin/env Rscript

#Importing roxygen2 to write the function's documentation
library(roxygen2)

#' Determine the pathogenic variants of an individual plink file
#'
#'@description 
#'path_var_detector() function analyses an individual plink's file bim file that
#'has to be provided as the second argument of the function, determining the 
#'variants that match with the clinvar reference file provided as the first 
#'argument. The output of this function is a list containing the id of the 
#'variant as the identifier and a string with a short annotation of the detected
#'variant and its generating phenotype.
#'
#'@param clinvar_ref_file. The path of the reference ClinVar file to detect the
#'variants of interest must be entered here. The file must be a tsv file
#'downloaded from the ClinVar database (variant_summary.txt).
#'
#'@param bim_file. The path of the individual bim file of the individual to
#'analyse must be entered here. The format of bim files must be kept to guarantee
#'the proper functioning of the function.
#'
#'@returns An object of class "List" containing the identified variant ID as the 
#'element identifier as a string containing short description of the variant's 
#'annotation as the values.
#'
#'@example 'path_var_detector("./clinvar_ref.txt", "./individual.bim")'
#'
#'@author Iñaki Sasiain Casado

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
  
  # Creating the list to return
  ret_ls=list()
  
  # If a pathogenic variant is detected as an item to the list
  if (nrow(matching_bim) != 0) { 
    
    #Iterating through the matches
    for (var in 1:nrow(matching_bim)) {
      
      #Ading each identified pathogenic variant to the list
      ret_ls[[matching_bim[var,2]]] <- paste(
                              "A", matching_clinvar[var,3], "genetic variant has been detected in the individual analysed.",
                              "The variant affects the gene", matching_clinvar[var,4], "and has been associated with the following genotype:", matching_clinvar[var,5], ".",
                              "The variant is located in the position", matching_bim[var,4], "of chromosome", matching_bim[var,1], ".")
    }
    # Return the ret_ls. The list will be empty is no variant has been identified
    return(ret_ls)
  }
}

#' Plotting the Minor Allele Frequency of a certain variant in different 
#' populations on a map
#'
#'@description 
#'plotting_MAF_in_map(). This function plots the Minor Allele frequency of the 
#'variant provided as the third argument among the populations specified in the 
#'MAF dataframe. The MAF will be represented through pie charts located in the
#'corresponding location of each population. The location of the populations must
#'be specified through a txt file.
#'
#'@param MAF_matrix. The path to a matrix containing the populations as rows and
#'the variants as columns and indicating the MAF per each case must be entered 
#'here.
#'
#'@param coordinates_file. A file in csv format containing the coordinates of the
#'populations to be plotted (Format: Pop,Long,Lat) must be entered here. The
#'populations whose coordinates have not been specified will not be used for the 
#'plot.
#'
#'@param variant_of_interest. A string containing the id of the variant whose
#'MAF wants to be plotted must be entered here.
#'
#'@returns An object of leaflet plot class is returned. Is the specified variants 
#'was not found in the refrence data an error message would be printed.
#'
#'@example 'plotting_MAF_in_map("./MAF_matrix.txt", "coordinates.csv", "rs3755319")'
#'
#'@author Iñaki Sasiain Casado

plotting_MAF_in_map <- function(MAF_matrix, coordinates_file, variant_of_interest) {
  
  # Uploading the required libraries
  library(leaflet)
  library(leaflet.minicharts)
  
  # Reading the coordinates file and the MAF matrix as dataframes
  coor_df <- read.csv(coordinates_file, sep =",", header=TRUE)
  MAF_df <- read.table(MAF_matrix)
  
  # Printing an error message if the variant is not found in the MAF_df
  if (! variant_of_interest %in% rownames(MAF_df))
  {stop("Variant not identified in the reference data. The MAF map can not be displayed")}
  
  # Removing the columns (populations) of the MAF_df whose coordinates are not specified
  coor_known <- colnames(MAF_df) %in% coor_df$"Group"
  MAF_df <- MAF_df[,coor_known]
  
  # Adding the coordinates of the populations of the coor_df that are also in
  # MAF_df to pop_df
  pop_in_file <- coor_df$"Group" %in% colnames(MAF_df)
  pop_df <- data.frame(coor_df[pop_in_file,])
  
  # Sorting the dataframes to ensure that both are in the same order
  MAF_df <- MAF_df[order(names(MAF_df))]
  pop_df <- pop_df[order(pop_df$"Group"),]
  
  # Addiing the MiAF and MaAF columnd to the pop_df
  pop_df$"Minor allele frequency" <- t(MAF_df[variant_of_interest,])
  pop_df$"Major allele frequency" <- 1 - pop_df$"Minor allele frequency"
  
  # Determine the coordinates to center the map
  long <- (min(pop_df$Longitude) + max(pop_df$Longitude))/2
  lati <- mean(min(pop_df$Latitude) + max(pop_df$Latitude))/2
  
  # Storing the linj to the world map that will be used for the plot
  tilesURL <- "http://server.arcgisonline.com/ArcGIS/rest/services/Canvas/World_Light_Gray_Base/MapServer/tile/{z}/{y}/{x}"
  
  # Plotting the result and storin it in the MAF_plot variable
  MAF_plot <- leaflet(width = "100%", height = "400px") %>%
    addTiles(tilesURL) %>% # Adding the basemap
    setView(lng = long, lat = lati, zoom = 3) %>% # Setting the intial view configuration
    addMinicharts( # Adding the pie charts to the plot
      pop_df$Longitude, pop_df$Latitude,
      type = "pie",
      chartdata = pop_df[,c("Minor allele frequency","Major allele frequency")],
      width = 30, height = 30) 
  
  # Returning the plot
  return(MAF_plot)
}