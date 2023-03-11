#!/usr/bin/R

#Parsing command line arguments
args <- commandArgs(trailingOnly=TRUE)

#Read the annotation file 
file_annotation <- read.csv(args[1], sep="\t")

#Get only the columnd of interest and renaming them
reduced_df <- data.frame(file_annotation[,14], file_annotation[,1], file_annotation[,8])
colnames(reduced_df) <- c("Country", "ID", "Years.BC")
reduced_df$"Country" <- gsub("\\s+", "_", reduced_df$"Country")

#Transform the year into a numeric datatype
reduced_df$"Years.BC" <- as.numeric(reduced_df$"Years.BC")

#Defining the year intervals to split the data in
year_intervals = list(
    c(-Inf,1000),
    c(1000,2000),
    c(2000,3000),
    c(3000,4000),
    c(4000,5000), 
    c(5000,6000),
    c(6000,7000),
    c(7000,8000),
    c(8000,9000),
    c(9000,10000),
    c(10000,12000),
    c(12000,Inf)
)

#Creating the txt files to filter the data using plink
for (interval in year_intervals) {

    #Definining the filename of the new file
    filename <- paste("range_", interval[1],"_" ,interval[2], ".txt", sep="")

    #Filtering the file_annotation dataframe to keep only the population and family ids of the oindividuals of each time interval
    inds_to_keep <- reduced_df$"Years.BC" > interval[1] & reduced_df$"Years.BC" <= interval[2]
    filtered_df <- data.frame(reduced_df[inds_to_keep,]$"Country", reduced_df[inds_to_keep,]$"ID")

    #Writing the new filtering txt files
    write.table(filtered_df, file=paste(args[2], filename, sep = ""), row.names=FALSE, col.names=FALSE, quote=FALSE, sep=" ")
}