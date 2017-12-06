library(shiny)
library(leaflet)
library(data.table)
library(ggmap)
library(DT)

##Load School and Lasteaed Data
schoolData <- readRDS("datasets/schoolDataSubset.RDS")
colnames(schoolData)[7] <- "Oppekeel"
lasteaedData <- readRDS("datasets/lasteaedData.RDS")
colnames(lasteaedData)[7] <- "Oppekeel"

#Load Car Crash Data
crashData <- readRDS("datasets/crashDataCleanedFixed.RDS")
colnames(crashData)[4] <- "Kuupaev"
colnames(crashData)[6] <- "Situatsiooni.tuup"

##Load Crime Data
crimeProperty <- readRDS("datasets/crimePropertyTallinn.RDS")
crimeState <- readRDS("datasets/crimeStateTallinn.RDS")
crimeTraffic <- readRDS("datasets/crimeTrafficTallinn.RDS")

##Create Custom Icons Here
schoolIcons <- awesomeIcons(
  icon = 'graduation-cap',
  markerColor = 'lightblue',
  library = 'fa',
  iconColor = 'black'
)

lasteaedIcons <- awesomeIcons(
  icon = 'graduation-cap',
  markerColor = 'darkpurple',
  library = 'fa',
  iconColor = 'black'
)

addressIcons <- awesomeIcons(
  icon = 'home',
  markerColor = "red",
  library = 'fa',
  iconColor = 'black'
)

##Start Server Code
function(input, output, session) {
  
 output$propertytable <- DT::renderDataTable({
    if (input$linnaosa != "All") {
      crimeProperty <- crimeProperty[crimeProperty$KohtNimetus == input$linnaosa,]
    }
    if (input$day != "All") {
      crimeProperty <- crimeProperty[crimeProperty$ToimNadalapaev == input$day,]
    }
    DT::datatable(crimeProperty)
  })
  output$statetable <- DT::renderDataTable({
    if (input$linnaosa != "All") {
      crimeState <- crimeState[crimeState$KohtNimetus == input$linnaosa,]
    }
    if (input$day != "All") {
      crimeState <- crimeState[crimeState$ToimNadalapaev == input$day,]
    }
    DT::datatable(crimeState)
  })
  output$traffictable <- DT::renderDataTable({
    if (input$linnaosa != "All") {
      crimeTraffic <- crimeTraffic[crimeTraffic$KohtNimetus == input$linnaosa,]
    }
    if (input$day != "All") {
      crimeTraffic <- crimeTraffic[crimeTraffic$ToimNadalapaev == input$day,]
    }
    DT::datatable(crimeTraffic)
  })
  
  ##Initializes the leaflet map for the page.
  output$outputmap <- renderLeaflet({
    map <-
      leaflet() %>% addProviderTiles(providers$OpenStreetMap.Mapnik)  %>%
      setView(lng =  24.753574,
              lat = 59.436962,
              zoom = 12) %>%
      addAwesomeMarkers (
        lng = schoolData$Lon,
        lat = schoolData$Lat,
        icon = schoolIcons,
        popup = paste(
          "Name:",
          schoolData$Nimi,
          "<br>",
          "Language:",
          schoolData$Oppekeel,
          "<br>",
          "Type:",
          schoolData$Type,
          "<br>",
          "Address:",
          schoolData$Aadress
        ),
        group = "Schools"
      ) %>%
      addAwesomeMarkers (
        lng = lasteaedData$Lon,
        lat = lasteaedData$Lat,
        icon = lasteaedIcons,
        popup = paste(
          "Name:",
          lasteaedData$Nimi,
          "<br>",
          "Language:",
          lasteaedData$Oppekeel,
          "<br>",
          "Type:",
          lasteaedData$Type,
          "<br>",
          "Address:",
          lasteaedData$Aadress
        ),
        group = "Kindergartens"
      ) %>%
      
      addAwesomeMarkers(
        lng = crashData$Lon,
        lat = crashData$Lat,
        clusterOptions = markerClusterOptions(),
        popup = paste(
          "Date:",
          crashData$Kuupaev,
          "<br>",
          "Situation:",
          crashData$Situatsiooni.tuup,
          "<br>",
          "Time:",
          crashData$Kellaaeg,
          "<br>",
          "Damage (EUR):",
          crashData$Kahju.suurus..euro.
        ),
        group = "Car Accidents"
      ) %>%
      
      addLayersControl(
        overlayGroups = c("Schools","Kindergartens", "Car Accidents"),
        options = layersControlOptions(collapsed = FALSE)
      ) %>%
      hideGroup("Schools")    %>%
      hideGroup("Kindergartens")    %>%
      hideGroup("Car Accidents")    
  })
  
  
  ##Geocoding of custom address input
  geocoding <-
    eventReactive(input$addressButton, {
      geocode(input$address)
    })
  
  #Takes an address input and places a marker on the map at given location
  observeEvent(input$addressButton, {
    newMarker <- geocoding()
    leafletProxy('outputmap') %>% addAwesomeMarkers(
      lng = newMarker$lon,
      lat = newMarker$lat,
      icon = addressIcons,
      label = input$address
    )
  })
  
  
  datasetInput <- reactive({
    switch(input$dataset,
           "Property Crime" = crimeProperty, 
           "Crimes against the State" = crimeState, 
           "Traffic Crimes" = crimeTraffic,
           "Lastead Data" = lasteaedData,
            "School Data" = schoolData,
            "Car Crash Data" = crashData)
  })
  
  output$table <- DT::renderDataTable({
  datasetInput()
  })
  
  output$downloadData <- downloadHandler(
      filename = function() {
      paste(input$dataset, ".csv", sep = "")
    },
    content = function(file) {
      write.csv(datasetInput() , file, row.names = FALSE)
    }
  )
  
}