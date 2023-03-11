
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

plotting_MAF_in_map("/home/inf-52-2022/pop_gen_project/05_Generating_plots/curr_SNP_matrix.txt", "/home/inf-52-2022/pop_gen_project/05_Generating_plots/coor.csv", "rs908742")