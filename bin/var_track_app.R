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
  
  # Create a reactive object for the selected time interval
  selected_interval <- reactive({
    input$interval
  })
  
  # Display the pathogenic variants identified and their effect
  output$variant_list <- renderUI({
    req(input$run_analysis)
    variants <- path_var_detector("./pathogenic_variants.tsv", file_path())
    variant_divs <- lapply(names(variants), function(name) {
      div(
        br(),
        h3(strong(paste("  --> VARIANT:", name))),
        p(variants[[name]]),
        br(),
        tabsetPanel(
          tabPanel("Details", 
                   h4(paste("FREQUENCY OF", name, "IN THE CURRENT POPULATION")),
                   renderPlot(plotting_MAF_in_map("./curr_SNP_matrix.txt", "./curr_coor.csv", name)),
                   h5("MINOR ALLELE FREQUENCY", style = "color:red;", align = "center"),
                   h5("MAJOR ALLELE FREQUENCY", style = "color:green;" , align = "center")
          ),
          
          tabPanel("Evolution", 
                   h4(paste("EVOLUTION OF", name, "ACROSS TIME"), br(), br()),
                   selectInput("interval", "Select interval:", 
                               choices = c("0-1.000 BC", "1.000-2.000 BC", "2.000-3.000 BC", 
                                           "3.000-4.000 BC", "4.000-5.000 BC", "5.000-6.000 BC",
                                           "6.000-7.000 BC", "7.000-8.000 BC", "8.000-9.000 BC", 
                                           "9.000-10.000 BC", "10.000-12.000", "> 12.000 BC")),
                   # Call the function with the selected interval as input
                   renderPlot(plotting_MAF_in_map("range_10000_12000_SNP_matrix.txt", "./ancient_coor.csv", name)),
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