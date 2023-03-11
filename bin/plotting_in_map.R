#Loading the required data
library(ggplot2)
library(scatterpie)
library(rworldmap)

#Reading the files
pop_df <- read.csv("/home/inf-52-2022/pop_gen_project/05_Generating_plots/coor.csv", sep =",")
MAF_df <- read.table("/home/inf-52-2022/pop_gen_project/05_Generating_plots/curr_SNP_matrix.txt")

#Getting the MAF of out variant of interest and adding it to the dataframe
pop_df$"Minor allele frequency" <- t(MAF_df["rs908742",])
pop_df$"Mayor allele frequency" <- 1 - pop_df$"Minor allele frequency"

#Potting the MAF in a map

png("/home/inf-52-2022/pop_gen_project/05_Generating_plots/my_plot.png", width=700, height=700)
my_plot <- mapPies(pop_df, nameX = "Longitude", nameY = "Latitude",
        nameZs = c("Minor allele frequency", "Mayor allele frequency"), 
        zColours = c("Red", "Green"),
        symbolSize = 1, 
        mapRegion = "europe",
        borderCol = "Black", 
        landCol = "lightGrey",
        lwd=2)
dev.off()
