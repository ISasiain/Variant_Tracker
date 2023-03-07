#!/usr/bin/R

#Installing and activating the required packages

#install.packages("readxl")
library(readxl)

#Parsing command line arguments
args <- commandArgs(trailingOnly=TRUE)

#Opening Reich_dataset_V50.xlsx file
features <- read_excel(args[1])

#Opening the filtered .fam file
filtered_fam <- read.csv(args[2], header=FALSE, sep=" ")

#Removing the raws of the annotation file without an identifier in the fam file
matches <- features$"Master ID" %in% filtered_fam[,2]
features <- features[matches, ]

#Removing rows in which the individual ID is duplicated. The row of the first appearance is kept
features <- features[!duplicated(features$"Master ID"),]

filtered_annotation <- data.frame(features[,3], features[,9], features[,15], features[,16], features[,17])
colnames(filtered_annotation) <- c("ID", "Years BC", "Country", "Lat.", "Long.")

filtered_annotation$"Country" <- gsub("\\s+", "", filtered_annotation$"Country")

#Create the Data_to_filter.txt with the individual that should be kept in the plink files
write.table(filtered_annotation, file=paste(args[3], "/filtered_annotation.tsv", sep=""), row.names=FALSE, col.names=TRUE, quote=FALSE, sep="\t")

