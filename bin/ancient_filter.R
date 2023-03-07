#!/usr/bin/R

#Installing and activating the required packages

#install.packages("readxl")
library(readxl)

#Parsing command line arguments. The xml file containing the features of the ancient samples should be the first argument.
#The location of the output inds_to_keep.txt should be the second argument.
args = commandArgs(trailingOnly=TRUE)

#Opening Reich_dataset_V50.xlsx file
features <- read_excel(args[1])

#Generating a dataframe with the fields needed to filter the plink files
file_to_filter <- data.frame(features[,15], features[,3])
file_to_filter$"Country" <- gsub("\\s+", "", file_to_filter$"Country")

#Create the Data_to_filter.txt with the individual that should be kept in the plink files
write.table(file_to_filter, file=paste(args[2], "/inds_to_keep.txt", sep=""), row.names=FALSE, col.names=FALSE, quote=FALSE, sep=" ")
