library(shiny)
library(leaflet)
library(ggmap)
library(data.table)
library(DT)

navbarPage(
  "Tallinn Real Estate Pilot Program",
  tabPanel("Map of Tallinn",
           sidebarLayout(
             sidebarPanel(
               textInput("address", "Address", value = ""),
               verbatimTextOutput("value"),
               actionButton("addressButton", "Search"),
               p(
                 "Type in an address and press 'search' to mark the location on the map!"
               )
             ),
             mainPanel(
               tags$style(type = "text/css", "#map {height: calc(100vh - 150px) !important;}"),
               leafletOutput("outputmap", width = "100%", height = "800px"),
               hr(
                 "This project has received funding from the European Union’s Horizon 2020 research and innovation programme under grant agreement No 693849."
               )
               
             )
           )),
  tabPanel(
    title = "Crime Data Exploration",
    sidebarLayout(
      sidebarPanel(
      selectInput("dataset", "Choose Dataset to Display and Download:", choices = c("Property Crime", 
                                                                                    "Crimes against the State", 
                                                                                    "Traffic Crimes", 
                                                                                    "Lastead Data", 
                                                                                    "School Data", 
                                                                                    "Car Crash Data")),
      downloadButton("downloadData", "Download data")),
      mainPanel(
          DT::dataTableOutput("table")
    ))),
  tabPanel(title = "About", 
           fluidRow(
             column(8, offset = 1,
                    includeMarkdown("about.md"))))
  
)