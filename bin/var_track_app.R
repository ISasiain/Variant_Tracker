#!/usr/bin/Rscript

# Uploading the required packages
library(shiny)
library(shinyjs)
library(shinythemes)

#Importing functions to teh working directory
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

# Define the serve function
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
      div(
        h4(strong(paste("  --> VARIANT:", name))),
        p(variants[[name]]),
        actionButton(paste0("view_", name), "View details"),
        actionButton(paste0("track_", name), "Track evolution"),
        br()
      )
    })
    do.call(tagList, variant_divs)
  })
  
  # Link the "View details" and "Track evolution" buttons to other Shiny pages
  observe({
    req(input$run_analysis)
    variants <- path_var_detector("./pathogenic_variants.tsv", file_path())
    lapply(names(variants), function(variant) {
      observeEvent(input[[paste0("view_", variant)]], {
        # Code to link to the page that shows details for the variant
        variant_details_page <- fluidPage(
          theme = shinytheme("united"),
          titlePanel(h1(strong(paste("Variant Tracker: Variant Details - ", variant)))),
          br(),
          p("Details for ", variant)
        )
        updatePage(variant_details_page)
      })
      observeEvent(input[[paste0("track_", variant)]], {
        # Code to link to the page that tracks the evolution of the variant
        variant_evolution_page <- fluidPage(
          theme = shinytheme("united"),
          titlePanel(h1(strong(paste("Variant Tracker: Variant Evolution - ", variant)))),
          br(),
          p("Evolution of ", variant)
        )
        updatePage(variant_evolution_page) 
      })
    })
  })
}  

shinyApp(ui = ui, server = server)