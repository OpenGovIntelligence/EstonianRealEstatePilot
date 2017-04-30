library(shiny)
library(leaflet)
library(data.table)
library(ggmap)

##Load Data Here
schoolData <- readRDS("datasets/schoolData.rds")
lasteaedData <- readRDS("datasets/lasteaedData.RDS")
crashData <- readRDS("datasets/crashDataCleanedFixed.rds")

##Subset and Select data here
names(schoolData)[6] <- paste("Type")
lasteaedData <- subset(schoolData, schoolData$Type == "lasteaed", select = V1:ads_oid)
schoolData <- subset(schoolData, schoolData$Type != "lasteaed", select = V1:ads_oid)

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

function(input, output, session) {
  
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
          crashData$Kuupäev,
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
        overlayGroups = c("Schools","Kindergartens", "Car Accidents", "Crime", "Bus Stops"),
        options = layersControlOptions(collapsed = FALSE)
      ) %>%
      hideGroup("Schools")    %>%
      hideGroup("Kindergartens")    %>%
      hideGroup("Car Accidents")     %>%
      hideGroup("Crime")     %>%
      hideGroup("Bus Stops")
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
  
}
