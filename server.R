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
  
    #create new dataframe to contain only lap # and timestamp.
    #time_df will be used to calculate lap time.
    time_df <- csv_to_Table[c("Lap..", "Timestamp..s." )]
    #log information to csv for now
    write.csv(time_df, file = "data/lap_timestamp.csv")
    
    output$time_test <- renderText({
      #drive time in seconds
      time_seconds <- max(time_df$Timestamp..s.) - min(time_df$Timestamp..s.)
      
      
      
      
    })
    
    #remove unecessary columns
    csv_to_Table <- csv_to_Table[,!grepl("^Time", names(csv_to_Table)) &
                                  !grepl("^Distance..km", names(csv_to_Table)) &
                                  !grepl("^Locked", names(csv_to_Table)) & 
                                  !grepl("^Trap", names(csv_to_Table)) & 
                                  !grepl("^Speed..m.s.", names(csv_to_Table))
                                ]
    
  })
  
  readFile2 <- reactive({
    infile2 <- input$file
    if (is.null(infile2)){
      return (NULL)
    }
    
    #read track name
    #skip first 4 line and read max of 1 row 
    track_name <- read.csv(infile2$datapath, header = F, skip = 4, nrows = 1, as.is = F)
    
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
  
  output$max_speed <- renderText({
    "Max Speed"
  })
  
  output$lap_time <- renderText({
    "Fastest Lap Time"
  })
  
  output$createTable <- DT::renderDataTable({
    DT::datatable(data_table(), filter='top')
  })
  
  output$track_name <- renderPrint({
    print(df <- as.character(readFile2()[[2]]), quote=FALSE)
  })
  
  output$TopSpeed <- renderPrint({
    print("Top Speed")
  })
  output$fastest_speed <- renderPrint({
    max(readFile()$Speed..kph)
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
  
  long_lat_df <- reactive({
    long_lat <- subset(readFile(), select=c(Latitude..deg.,Longitude..deg.))
    return(long_lat)
  })
  
  output$createTable1 <- DT::renderDataTable({
    DT::datatable(long_lat_df(), filter='top')
  })

})
