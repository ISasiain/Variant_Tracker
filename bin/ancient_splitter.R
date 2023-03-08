#!/usr/bin/R

#Parsing command line arguments
args <- commandArgs(trailingOnly=TRUE)

#Read the annotation file 
file_annotation <- read.csv(args[1], sep="\t")

#Transform the year into a numeric datatype
file_annotation$"Years.BC" <- as.numeric(file_annotation$"Years.BC")

#Defining the year intervals to split the data in
year_intervals = list(
    c(-Inf,3000),
    c(3000,3500),
    c(4000,4500),
    c(4500,5000), 
    c(5000,5500),
    c(6000,6500),
    c(6500,7000),
    c(7000,7500),
    c(7500,8000),
    c(8000,9000),
    c(9000,Inf)
)

#Creating the txt files to filter the data using plink
for (interval in year_intervals) {

    #Definining the filename of the new file
    filename <- paste("range_", interval[1],"_" ,interval[2], ".txt", sep="")

    #Filtering the file_annotation dataframe to keep only the population and family ids of the oindividuals of each time interval
    inds_to_keep <- file_annotation$"Years.BC" > interval[1] & file_annotation$"Years.BC" <= interval[2]
    filtered_df <- data.frame(file_annotation[inds_to_keep,]$"Country", file_annotation[inds_to_keep,]$"ID")

    #Writing the new filtering txt files
    write.table(filtered_df, file=paste(args[2], filename, sep = ""), row.names=FALSE, col.names=FALSE, quote=FALSE, sep=" ")
}