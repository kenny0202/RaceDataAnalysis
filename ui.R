library(shiny)
library(plotly)

shinyUI(bootstrapPage(theme = "bootstrap.css", 

  navbarPage("RaceChrono Analyzer", collapsible = TRUE,
     tabPanel("Home", icon = icon("home")
     
     ),
     tabPanel("Data", icon = icon("file-text"),
              fileInput("file", h3("Upload RaceChrono2AVI.csv format"), accept=c("text/csv", "text/comma-separated-values,text/plain", ".csv")),
              tags$hr(),
              uiOutput("choose_columns"),
              DT::dataTableOutput('createTable')
     ),
     tabPanel("One variable graph", icon = icon("signal"),
              uiOutput('var_single'),
              actionButton('generateGraph', 'Generate'),
              tags$br(),
              tags$br(),
              plotlyOutput('single_var_graph')
     ),
     tabPanel("Two variable graph", icon = icon("bar-chart"),
              uiOutput('var_x'),
              uiOutput('var_y'),
              actionButton('generateGraph', 'Generate'),
              tags$br(),
              tags$br(),
              plotlyOutput('two_var_graph')
     ),
     tabPanel("Map", icon = icon("map-marker"),
              plotOutput("map")
     )
  )
))
