## VARIANT TRACKER
# 
# Description
#
# This Shiny application the user to identify the pathogenic variants from an 
# individual PLINK file, displaying summary information about the variant and 
# its phenotypic effect, and showing the Minor Allele frequency of the identified
# SNP in curret and ancient populations.
# 
# Usage
#
# 1. Upload the bim file using the left panel and run the analysis. A list
# containing the variants identified will be then displayed.
#
# 2. Check the tab of interest of each variants. The options are "General information",
# which is active by default and shows a brief description of the variant and its 
# effects, a tab showing a map with the MAF in current populations and a tab that
# displays a map per each ancient population. The time periods to take into account
# can be selected.
#
# Data Input
#
# This application requires a bim file to be provided by the user. The reference data
# should be stored in the same directory than the script
# 
# Dependencies
# 
# This application requires the following packages to be installed: shiny, shinythemes, leaflet
# 
# Author
# 
# Iñaki Sasiain 
# 
# Version
# 
# 1.0


# Uploading the required packages
library(shiny)
library(shinythemes)
library(leaflet)

#Importing functions to the working directory
source("./var_track_functions.R")

# Define the UI function
ui <- fluidPage(
  theme = shinytheme("united"), # Using the the 'united' rShiny theme
  titlePanel(h1(strong("Variant Tracker"))), # Add title of the page
  br(), # Add empty line after the title
  sidebarLayout( # Selecting a sidebar Layout
    sidebarPanel(
      # Writing a short description of the page
      t("This software analyzes a user-provided individual plink file and
      selects the variants associated with diseases according to the ClinVar
      database. It provides general information about each variant and the 
      associated disease.In addition, this tool analyzes the frequencies of the 
      identified pathogenic variants in different current populations. It also 
      allows the user to track the evolution of these variants over time across 
      different populations."),
      br(), br(), # Adding a white line
      #Adding an option to input the bim file in  the sidebar
      fileInput("bimfile", "Enter the bim file of the individual to analyse",
                multiple = FALSE, accept = c(".bim")),
      #Creating a button to run the analysis
      actionButton("run_analysis", "Run analysis")
    ),
    mainPanel(
      #Adding the title of the main panel
      h2("Detected pathogenic variants"), br(),
      
      #Adding the variant_list UI defined in the server function
      uiOutput("variant_list")
    ),
  )
)

#Defining the server function
server <- function(input, output, session) {
  
  # Store the reactive input file path
  file_path <- reactive({
    if (is.null(input$bimfile)) {
      return(NULL)
    } else {
      #Checking if the input file matches the required format
      for (line in readLines(input$bimfile$datapath, n=10)) {
        if (!grepl( "^[0-9]+\t+[a-z0-9]+\t+[0-9.]+\t+[0-9]+\t+[0-9]+\t+[0-9]+$", line)) {
          stop("The input file does not match the required format. The file must be in bim format")
        }
      }
      return(input$bimfile$datapath)
    }
  })
  
  # Display the pathogenic variants identified and their effect using render UI.
  # The UI of each list's element is defined on the server.
  output$variant_list <- renderUI({
    req(input$run_analysis) # Clicking the run_analysis button is requested
    #Running the path_var_detector function to get the variant list
    variants <- path_var_detector("./pathogenic_variants.tsv", file_path())
    
    #Creating a div per each element of the list
    variant_divs <- lapply(names(variants), function(name) {
      
      #Creating a new name for plotting through time intervals
      new_name <- paste("interval", name, sep=)
      
      #Defining an HTML div tag
      div(
        br(), # Adding empty line
        h3(strong(paste("  --> VARIANT:", name))), # Creating a header
        br(),
        tabsetPanel( # Creating tabs
          
          # Tab to show general information about the variant
          tabPanel("General information",
            br(),
            p(variants[[name]]), # Adding the annotation text of each        
            ),
          
          # Tab to show the MAF of current populations
          tabPanel("Current Populations", 
            
            #cAdding the header   
            h4(paste("FREQUENCY OF", name, "IN THE CURRENT POPULATION")),
            # PLotting the data using the plotting_MAF_in_map function
            renderLeaflet(plotting_MAF_in_map("./curr_SNP_matrix.txt", "./curr_coor.csv", name)),
            ),
          
          # Tab to show the MAF of ancient populations
          tabPanel("Ancient Populations", 
                   
                   # Adding a header
                   h4(paste("EVOLUTION OF", name, "ACROSS TIME")), 
                   #Printing a warining message
                   t("Loading of the map may take some seconds due to the large amount of refernce data analysed."),
                   br(), br(), #Ading white lines
                   #Allowing the user to use a time interval
                   selectInput(new_name, "Select interval (Years BC):", 
                               choices = c("0_1000", "1000_2000", "2000_3000", 
                                           "3000_4000", "4000_5000", "5000_6000",
                                           "6000_7000", "7000_8000", "8000_9000", 
                                           "9000_10000", "10000_12000", "> 12000")),
                   
                   # Call the function with the selected interval as input
                   renderLeaflet(plotting_MAF_in_map(paste("range_", gsub("> 12000", "12000_Inf", gsub("^0", "-Inf", input[[new_name]])), "_SNP_matrix.txt", sep=""), "./ancient_coor.csv", name))
          )
        ),
      )
    })
    # Calling the tagList function and passing the variant_divs list as arguments
    do.call(tagList, variant_divs)
  })
}

#Running the shiny app
shinyApp(ui = ui, server = server)
