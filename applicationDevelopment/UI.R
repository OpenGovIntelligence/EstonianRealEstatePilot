library(shiny)
library(leaflet)
library(ggmap)
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

  fluidRow(
    column(4,
           selectInput("linnaosa",
                       "Linnaosa:",
                       c("All",
                         unique(as.character(crimeProperty$KohtNimetus))))
    ),
    column(4,
           selectInput("type",
                       "Crime Type:",
                       c("All",
                         unique(as.character(crimeProperty$ParagrahvTais))))
    ),
    column(4,
           selectInput("hind",
                       "Total Damage:",
                       c("All",
                         unique(as.character(crimeProperty$Kahjusumma))))
    )
  ),
  # Create a new row for the table.
   fluidRow(
     div(DT::dataTableOutput("table"))
   )),
  tabPanel(title = "About", 
           fluidRow(
             column(8, offset = 1,
                    includeMarkdown("about.md"))))
  
  
  
)
