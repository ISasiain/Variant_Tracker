#Installing snpStats
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
