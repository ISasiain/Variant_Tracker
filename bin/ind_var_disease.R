#!/usr/bin/env Rscript

#Passing command line arguments. The first argument must be the file containing the clinvar pathogenic variants, and the second one the .bim file.
args = commandArgs(trailingOnly=TRUE)

#Reading the clinvar variant files and bim files as dataframes
clinvar <- read.csv(file=args[1], sep="\t")
bim <- read.csv(file=args[2], sep="\t", header=FALSE)

#Find the variants present in the individuals in the clinvar dataframe
matches_bim <- bim[,2] %in% clinvar[,2]
matches_clinvar <- clinvar[,2] %in% bim[,2]

#Getting the unique variants
matching_bim <- unique(bim[matches_bim,])
matching_clinvar <- unique(clinvar[matches_clinvar,])

#Creating a vector to store the variant names
variants <- c()

#Printing the output.
if ( nrow(matching_bim) != nrow(matching_bim) ) {
   cat("\n*** DATABASE ERROR ***\n")

} else if (nrow(matching_bim) == 0) {
   cat ("\nNo pathogenic variant was found in the analysed individual\n")

} else {
   for (var in 1:nrow(matching_bim)) {
      
        cat("\n\n", "  --> VARIANT ", var, "\n\n")

        cat("A", matching_clinvar[var,3], "genetic variant has been detected in the individual analysed:", matching_clinvar[var,2], "\n")
        cat("The variant affects the gene", matching_clinvar[var,4], "and has been associated with the following genotype:", matching_clinvar[var,5], "\n")
        cat("The variant is located in the position", matching_bim[var,4], "of chromosome", matching_bim[var,1], "\n\n")


         #Storing the name of the pathogenic variables identified into a vector
         variants <- c(variants, matching_clinvar[var,2])

   }
}

print(variants)

