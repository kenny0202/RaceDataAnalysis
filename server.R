library(shiny)
library(plotly)
library(DT)
library(ggmap)

shinyServer(function(input, output) {

  readFile <- reactive({
    infile <- input$file
    if (is.null(infile)){
      return(NULL)      
    }
    #read csv file skipping the first 9 lines
    csv_to_Table <- read.csv(infile$datapath, header=TRUE, sep=",", skip=9)
    
    #filter using grep to remove "N/A" from Lap # column
    csv_to_Table <- csv_to_Table[!grepl("N/A", csv_to_Table$Lap..),]
    
    #remove unecessary columns
    csv_to_Table <- csv_to_Table[,!grepl("^Time", names(csv_to_Table)) &
                                  !grepl("^Distance..km", names(csv_to_Table)) &
                                  !grepl("^Locked", names(csv_to_Table)) & 
                                  !grepl("^Trap", names(csv_to_Table)) & 
                                  !grepl("^Speed..m.s.", names(csv_to_Table)) &
                                  !grepl("^Altitude", names(csv_to_Table))
                                ]
    
  })
  
  output$choose_columns <- renderUI({
    cn <- colnames(readFile())
    checkboxGroupInput("columns", "", 
                        choices  = cn,
                        selected = cn)
  })
  
  data_table <- reactive({
    # If missing input, return to avoid error later in function
    if(is.null(input$file))
      return(NULL)
    
    # Get the data set
    dat <- readFile()
    
    # Keep the selected columns
    dat[, input$columns, drop = FALSE]
  })
  
  output$createTable <- DT::renderDataTable({
    DT::datatable(data_table(), filter='top')
  })
  
  output$var_single <- renderUI({
    selectInput('select_var_single', 'Variable to graph',
                sort(colnames(readFile())) )
  })
  
  output$var_x <- renderUI({
    selectInput('select_var_x', 'Variable to display on X axis',
                sort(colnames(readFile())) )
  })
  output$var_y <- renderUI({
    selectInput('select_var_y', 'Variable to display on Y axis',
                sort(colnames(readFile())) )
  })
  
  output$single_var_graph <- renderPlotly({
    input$generateGraph
      plot_ly(readFile(), x=readFile()$Distance..m., y=readFile()$Speed..kph., type = 'scatter', mode = 'lines', color = I("blue")) %>% 
        layout(title="Race Data", xaxis = list(title="Date"), yaxis = list(title="Speed km/h"))
  })
  
  output$two_var_graph <- renderPlotly({
    input$generateGraph
  })
  
  output$map <- renderPlot({
    loc <- c(lon = -122.3268492 , lat = 49.1265247)
    test <- get_map(loc, zoom = 16, maptype = 'satellite')
    ggmap(test)
    
  }, width = 1800, height = 900)

})
