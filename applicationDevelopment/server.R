require(shiny)
require(leaflet)
require(data.table)
require(nominatim)
require(httr)

schoolData <- readRDS("datasets/schoolData.rds")

getAddressData <- function(address){
  url <- paste0("https://maps.googleapis.com/maps/api/geocode/json?address=",address)
  someData <- jsonlite::fromJSON(url)

}


function(input, output, session) {
  
  
  addressMarker <- observeEvent(input$addressButton, {getAddressData(input$address)})

  
  addressValue <- eventReactive(input$addressButton, {input$address})

  APICall <- eventReactive(input$addressButton, {fromJSON(paste(URL,input$address))})

                                                         
  
  output$value <- addressValue
  
  output$map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$Stamen.TonerLite,
                       options = providerTileOptions(noWrap = TRUE)
      ) %>%
      addMarkers(data = schoolData)
  })
  

}
