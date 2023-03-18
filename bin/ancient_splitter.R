#!/usr/bin/R

# -SCRIPT'S NAME:
# 
#     ancient_splitter.R
# 
# -DESCRIPTION:
# 
#     Given an annotation file with information about individuals and their locations at different times, this script creates multiple filtering text files based on year intervals. The year intervals are pre-defined and stored in a list. The script reads the annotation file, extracts the columns of interest, renames them, transforms the years column to numeric data type, and then creates multiple filtering text files by selecting individuals within each year interval.
# 
# -USER DEFINED FUNCTIONS:
# 
#     None.
# 
# -LIST OF MODULES:
# 
#     None.
# 
# -PROCEDURE:
# 
#     1.The script parses command line arguments using the commandArgs function and reads the annotation file using the read.csv function.
#     
#     2.The script extracts the columns of interest and renames them using the data.frame and colnames functions, respectively. It also 
#     replaces any whitespace in the "Country" column with underscores using the gsub function.
#     
#     3.The script transforms the "Years.BC" column to a numeric data type using the as.numeric function.
#     
#     4.The script defines the pre-defined year intervals and stores them in a list.
#     
#     5.The script creates multiple filtering text files using a for loop that iterates over the year intervals list. For each interval,
#     the script filters the individuals within that interval using the data.frame function and writes the filtered data to a new text 
#     file using the write.table function. The file name of each output text file is based on the lower and upper bounds of the year interval.
# 
# -INPUT:
# 
#     The script takes two command line arguments:
# 
#     --> The path to the input annotation file in CSV format.
#     --> The path to the output directory where the filtering text files will be saved.
# 
# -OUTPUT:
# 
#     The script generates multiple text files in the specified output directory. Each file corresponds to a year interval and contains the "Country" and "ID" columns of individuals within that interval.
# 
# -USAGE:
# 
#     Execution of the script: Rscript ancient_splitter.R input_annotation_file.csv output_directory/
# 
# 
# -VERSION: 1.0
# 
#     DATE: 14/03/2023
# 
# -AUTHOR: Iñaki Sasiain Casado


# Parsing command line arguments
args <- commandArgs(trailingOnly=TRUE)

# Read the annotation file
file_annotation <- read.csv(args[1], sep="\t")

# Get only the columns of interest and renaming them
reduced_df <- data.frame(file_annotation[,14], file_annotation[,1], file_annotation[,8])
colnames(reduced_df) <- c("Country", "ID", "Years.BC")
reduced_df$"Country" <- gsub("\\s+", "_", reduced_df$"Country")

# Transform the year into a numeric datatype
reduced_df$"Years.BC" <- as.numeric(reduced_df$"Years.BC")

# Defining the year intervals to split the data in
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

# Creating the txt files to filter the data using plink
for (interval in year_intervals) {

    # Defining the filename of the new file
    filename <- paste("range_", interval[1], "_", interval[2], ".txt", sep="")

    # Filtering the file_annotation dataframe to keep only the population and family ids of the individuals of each time interval
    inds_to_keep <- reduced_df$"Years.BC" > interval[1] & reduced_df$"Years.BC" <= interval[2]
    filtered_df <- data.frame(reduced_df[inds_to_keep,]$"Country", reduced_df[inds_to_keep,]$"ID")

    # Writing the new filtering txt files
    write.table(filtered_df, file=paste(args[2], filename, sep = ""), row.names=FALSE, col.names=FALSE, quote=FALSE, sep=" ")
}