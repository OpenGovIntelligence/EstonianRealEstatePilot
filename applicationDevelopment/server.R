library(shiny)
library(leaflet)
library(data.table)
library(ggmap)

#This is a dataset for all school locations in Tallinn
schoolData <- readRDS("datasets/schoolData.rds")
crashData <- readRDS("datasets/crashData.rds")

function(input, output, session) {
  #Initializes the leaflet map for the page.
  
  schoolIcons <- awesomeIcons(
    icon = 'graduation-cap',
    markerColor = ifelse(schoolData$Tüüp == "lasteaed", 'lightblue', 'darkpurple'),
    library = 'fa',
    iconColor = 'black'
  )
  
  addressIcons <- awesomeIcons(
    icon = 'home',
    markerColor = "red",
    library = 'fa',
    iconColor = 'black'
  )
  
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
          "Type:",
          schoolData$Tüüp,
          "<br>",
          "Address:",
          schoolData$Aadress
        ),
        group = "Schools"
      ) %>%
      addLayersControl(
        overlayGroups = c("Schools", "Car Accidents", "Crime", "Bus Stops"),
        options = layersControlOptions(collapsed = FALSE)
      ) %>%
      hideGroup("Schools")    %>%
      hideGroup("Car Accidents")     %>%
      hideGroup("Crime")     %>%
      hideGroup("Bus Stops")
  })
  
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
  
}
