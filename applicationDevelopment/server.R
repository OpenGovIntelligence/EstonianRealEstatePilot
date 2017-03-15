require(shiny)
require(leaflet)
require(data.table)
require(nominatim)
require(httr)

schoolData <- readRDS("datasets/schoolData.rds")


##This may be used to retrieve JSON address information from Google Maps API, 
#it takes a user inputted address as a parameter
#TODO://User input address must sub spaces for + in order to work
#EX:Pärnu+mnt+102c would work, but Pärnu mnt 102c would crash app

getAddressData <- function(address){
  url <- paste0("https://maps.googleapis.com/maps/api/geocode/json?address=",address)
  someData <- jsonlite::fromJSON(url)

}


function(input, output, session) {
  
  
  #In the future this should be able to create an addressMarker by retrieving the lat and lon
  #from user input address
  ##NB! Currently does nothing
  addressMarker <- observeEvent(input$addressButton, {getAddressData(addressCleaned)})

  
  addressValue <- eventReactive(input$addressButton, {input$address})

  ##Displays the users' input in the UI underneath the address text field
  output$value <- addressValue
  
  
  ##Outputs the leaflet map, currently it is setlto display all schools on map
  output$map <- renderLeaflet({
    leaflet() %>%
      addProviderTiles(providers$Stamen.TonerLite,
                       options = providerTileOptions(noWrap = TRUE)
      ) %>%
      addMarkers(data = schoolData)
  })
  

}
