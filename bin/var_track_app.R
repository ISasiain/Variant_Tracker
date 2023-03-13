# Uploading the required packages
library(shiny)
library(shinyjs)
library(shinythemes)

#Importing functions to the working directory
source("./var_track_functions.R")

# Define the UI function
ui <- fluidPage(
  theme = shinytheme("united"),
  titlePanel(h1(strong("Variant Tracker"))),
  br(),
  sidebarLayout(
    sidebarPanel(
      t("This software analyzes a user-provided individual plink file and
      selects the variants associated with diseases according to the ClinVar
      database. It provides general information about each variant and the 
      associated disease.In addition, this tool analyzes the frequencies of the 
      identified pathogenic variants in different current populations. It also 
      allows the user to track the evolution of these variants over time across 
      different populations."),
      br(), br(),
      fileInput("bimfile", "Enter the bim file of the individual to analyse",
                multiple = FALSE, accept = c(".bim")),
      actionButton("run_analysis", "Run analysis")
    ),
    mainPanel(
      h2("Detected pathogenic variants"), br(),
      uiOutput("variant_list")
    ),
  )
)

server <- function(input, output, session) {
  
  # Store the reactive input file path
  file_path <- reactive({
    if (is.null(input$bimfile)) {
      return(NULL)
    } else {
      return(input$bimfile$datapath)
    }
  })
  
  # Display the pathogenic variants identified and their effect
  output$variant_list <- renderUI({
    req(input$run_analysis)
    variants <- path_var_detector("./pathogenic_variants.tsv", file_path())
    variant_divs <- lapply(names(variants), function(name) {
      new_name <- paste("interval", name, sep=)
      div(
        br(),
        h3(strong(paste("  --> VARIANT:", name))),
        p(variants[[name]]),
        br(),
        tabsetPanel(
          tabPanel("Current Populations", 
                   h4(paste("FREQUENCY OF", name, "IN THE CURRENT POPULATION")),
                   renderPlot(plotting_MAF_in_map("./curr_SNP_matrix.txt", "./curr_coor.csv", name)),
                   h5("MINOR ALLELE FREQUENCY", style = "color:red;", align = "center"),
                   h5("MAJOR ALLELE FREQUENCY", style = "color:green;" , align = "center")
          ),
          
          tabPanel("Ancient Populations", 
                   h4(paste("EVOLUTION OF", name, "ACROSS TIME"), br(), br()),
                   selectInput(new_name, "Select interval (Years BC):", 
                               choices = c("0_1000", "1000_2000", "2000_3000", 
                                           "3000_4000", "4000_5000", "5000_6000",
                                           "6000_7000", "7000_8000", "8000_9000", 
                                           "9000_10000", "10000_12000", "> 12000")),
                   
                   
                   # Call the function with the selected interval as input
                   renderPlot(plotting_MAF_in_map(paste("range_", gsub("> 12000", "12000_Inf", gsub("^0", "-Inf", input[[new_name]])), "_SNP_matrix.txt", sep=""), "./ancient_coor.csv", name)),
                   h5("MINOR ALLELE FREQUENCY", style = "color:red;", align = "center"),
                   h5("MAJOR ALLELE FREQUENCY", style = "color:green;" , align = "center")
          )
        ),
        br()
      )
    })
    do.call(tagList, variant_divs)
  })
}

shinyApp(ui = ui, server = server)