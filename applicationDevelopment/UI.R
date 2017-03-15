navbarPage(
  "Tallinn Real Estate Pilot Program",
  tabPanel("Map of Tallinn",
           sidebarLayout(
             sidebarPanel(
               textInput("address", "Address", value = ""),
               verbatimTextOutput("value"),
               actionButton("addressButton", "Search"),
               p("Type in an address and press 'search' to mark the location on the map!"),
               checkboxGroupInput(
                 "checkGroup",
                 label = h4("Select Map Layers"),
                 choices = list(
                   "Car Accidents" = 1,
                   "Schools" = 2,
                   "Bus stops" = 3
                 ),
                 selected = 2
               )
             ),
             mainPanel(
               tags$style(type = "text/css", "#map {height: calc(100vh - 80px) !important;}"),
               leafletOutput("map", width = "100%", height = "800px")
             )
           )),
  tabPanel("Data Explorer")
  
)
