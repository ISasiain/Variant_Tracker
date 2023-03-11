#!/usr/bin/env Rscript

#This functions detects the pathogenic variants from the individual input bim file
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

#Creating a function to plot the MAF in a map
plotting_MAF_in_map <- function(MAF_matrix, coordinates_file, variant_of_interest) {
    #Loading the required data
    library(ggplot2)
    library(rworldmap)

    #Reading the files
    pop_df <- read.csv(coordinates_file, sep =",")
    MAF_df <- read.table(MAF_matrix)

    #Getting the MAF of out variant of interest and adding it to the dataframe
    pop_df$"Minor allele frequency" <- t(MAF_df[variant_of_interest,])
    pop_df$"Mayor allele frequency" <- 1 - pop_df$"Minor allele frequency"

    #Getting the coordenates to limit the map
    long <- c(min(pop_df$Longitude) - 1, max(pop_df$Longitude) + 1)
    lat <- c(min(pop_df$Latitude) - 1, max(pop_df$Latitude) + 1)

    #Potting the MAF in a map
    png("/home/inf-52-2022/pop_gen_project/05_Generating_plots/my_plot.png", width=700, height=700)
    my_plot <- mapPies(pop_df, nameX = "Longitude", nameY = "Latitude",
            nameZs = c("Minor allele frequency", "Mayor allele frequency"), 
            zColours = c("Red", "Green"),
            symbolSize = 1, 
            xlim = long, 
            ylim = lat, 
            borderCol = "Black",
            landCol = "lightGrey",
            oceanCol = "lightBlue",
            lwd=2,
            addSizeLegend=FALSE,
            addCatLegend=FALSE)

    #Creating a legend for the plot
    legend(long[1],lat[1]+4,
       legend=c("Minor allele frequency",
                 "Mayor allele frequency"),
       col=c("red",
             "green"),
       pch=16,
       cex=1.7,
       pt.cex=2,
       bty="o",
       box.lty=2,
       horiz = F,
       bg="#FFFFFF70")

    dev.off()

}