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
               ),
               checkboxGroupInput(
                 "checkGroup",
                 label = h4("Select Map Layers"),
                 choices = list(
                   "Car Accidents" = 1,
                   "Schools" = 2,
                   "Bus stops" = 3
                 )
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
    "Data Exploration Tools",
    a("Cube Explorer", href = "http://wapps.islab.uom.gr/CubeVisualizer/crashes/", target =
        "_blank"),
    br(),
    a("QB OLAP browser", href = "http://wapps.islab.uom.gr/qbOLAPbrowser", target =
        "_blank")
  ),
  tabPanel(
    "About",
    "The Estonian pilot program is one of 6 pilot programs being carried out
    by the OpenGovIntelligence project. This pilot program is being carried out by The Estonian Ministry
    of Economic Affairs and Communications and Tallinn University of Technology.
    The purpose of this pilot program is to fight information asymmetry in the real estate market and
    provide an easy way to access real estate data. The pilot is intended to give real estate agents, property developers,
    investors, and those involved in the real estate market (buyers, sellers, renters, students, new arrivals etc.)
    a deeper knowledge of the marketplace.",
    br(),
    br(),
    "For questions on current stage of pilot please contact: ",
    a("Keegan.mcbride@ttu.ee", target = "_blank")
  )
  
  
  
)
