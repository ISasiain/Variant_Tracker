#!/usr/bin/R

# -SCRIPT'S NAME:
# 
#     snp_per_population.R
# 
# -DESCRIPTION:
# 
#     This functions creates a matrix with population names as columns and variant names as rows containing the Minor Allele
#     Frequency of each variant and population. 
# 
# -USER DEFINED FUNCTIONS:
# 
#     None.
# 
# -LIST OF MODULES:
# 
#     snpStats
# 
# -PROCEDURE:
# 
#     1.Check if "BiocManager" package is installed. If not, install it and load "snpStats" package..
#     
#     2.Parse command line arguments and read plink files.
#     
#     3.Compute the MAF per variant for each population by creating a list of indexes for individuals belonging to each population, creating an empty dataframe with variant names as row names, and adding MAF data of each population as new columns in the dataframe.
#     
#     4.Write the MAF dataframe to a file specified by the second command line argument.
#     
# 
# -INPUT:
# 
#     The script takes two command line arguments:
# 
#     --> The path to the plink file (without the extensions)
#     --> The path to the output directory where the MAF matrix will be saved
# 
# -OUTPUT:
# 
#     The script generates a txt file containing a MAF matrix with the populations as columns and variants as rows
# 
# -USAGE:
# 
#     Execution of the script: Rscript snp_per_population input_plink output_MAX_matrix
# 
# -VERSION: 1.0
# 
#     DATE: 14/03/2023
# 
# -AUTHOR: Iñaki Sasiain Casado

#Installing snpStats (uncomment the following commands if the package is not already installed)
#if (!require("BiocManager", quietly = TRUE))
#    install.packages("BiocManager")
#BiocManager::install("snpStats")

#Loading the required packages
library(snpStats)

#Parsing command line arguments
args <- commandArgs(trailingOnly=TRUE)

#Reading the plink files
var_file <- read.plink(args[1])

#Creating a matrix with the MAF of each variant per population

#Creating a list with the indexes of the individuals belonging to the differnet populations
pop_index <- list()

#Getting the names of all the unique populations keeping their position in the dataframe
populations <- var_file$fam[,1]

#Creating a list with the row number of the individuals that belong to each population
for (pop in unique(populations)) {
  pop_index[[pop]] <- which(populations == pop)
}

#Creating an empty dataframe with the variants as row names
MAF_df <- data.frame(row.names = var_file$map[,2])

#Adding the MAF data of each population to the dataframe as new columns
for (pop in unique(populations)) {
  MAF_df[[pop]] <- col.summary(var_file$genotype[pop_index[[pop]],])$MAF
}


write.table(MAF_df, file=args[2])
print("PROCESS FINISHED")
