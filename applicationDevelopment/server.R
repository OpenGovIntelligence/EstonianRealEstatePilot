library(shiny)
library(leaflet)
library(data.table)
library(ggmap)

#This is a dataset for all school locations in Tallinn
schoolData <- readRDS("datasets/schoolData.rds")

function(input, output, session) {
  #Initializes the leaflet map for the page.
  output$outputmap <- renderLeaflet({
    map <-
      leaflet() %>% addProviderTiles(providers$OpenStreetMap.Mapnik)  %>%
      setView(lng =  24.753574,
              lat = 59.436962,
              zoom = 12)
    
  })
  
  
  geocoding <- eventReactive(input$addressButton, {geocode(input$address)})
  
  
  
  #Takes an address input and places a marker on the map at given location
  observeEvent(input$addressButton, {
    newMarker <- geocoding()
    leafletProxy('outputmap') %>% addMarkers(lng = newMarker$lon, lat = newMarker$lat)
  })
  
  
  #If the option "Schools" is checked then all schools will be placed on a map
  #TODO://Only display schools on map which are in current field of view (zoom level)
  observeEvent(input$checkGroup, {
    if (input$checkGroup == 2) {
      leafletProxy('outputmap') %>% addMarkers (data = schoolData)
    }
    
    
  })
  
  #If the option "Bus Stops" is selected, the map will change to a transport layer
  observeEvent(input$checkGroup, {
    if (input$checkGroup == 3) {
      leafletProxy('outputmap') %>% addProviderTiles(providers$Thunderforest.Transport)
      leafletProxy('outputmap') %>% removeTiles('outputmap')
      
      
    }
  })
  
  
}
