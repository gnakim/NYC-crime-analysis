library(DT)
library(shiny)
library(shinydashboard)

crime_data <- readRDS("crime_data.RDS")

shinyUI(dashboardPage(
    dashboardHeader(title = "NYC Crime Report Analysis"),
    dashboardSidebar(
        
        # The first argument after menuItem is the label of the tab, then
        # tabname is what is used to reference the tab. The icon is referenced
        # from a shiny icon gallery and shows which picture should show beside
        # the name on the tab.
        
        sidebarUserPanel("NYC Crime Analysis 1918-2020"),
        sidebarMenu(
            menuItem("Graphs", tabName = "data_comp", icon = icon("chart-bar")),
            menuItem("Data", tabName = "data", icon = icon("database")),
            menuItem("Model", tabName = "model", icon = icon("bookmark")),
            menuItem("About", tabName = "about", icon = icon("user"))
        )
    ),
    
    dashboardBody(
        
        # This is used to link the css sheet to the shiny so that there is
        # better control over the fonts and style of the site. 
        
        tags$head(
            tags$link(rel = "stylesheet", type = "text/css", 
                      href = "custom.css")
        ),
        
        # One of the trickiest parts of shiny, for me, was figuring out the
        # syntax for the ui portion of the project. Everything became easier to
        # manage after realizing that choice was just a held variable, and I
        # could just use that to reference portions of the crime data. At first,
        # I had the column names as the choices, so some of the option just did
        # not work, because the plot wasn't meant to handle certain types.
        # Limiting the user's access to choices fixed that. I just had to be
        # careful that the choices matched up with the actual variable names,
        # especially after the renaming fiasco that happened on the server end.
        
        tabItems(
            tabItem(tabName = "data_comp",
                    fluidRow(h3("NYPD Crime Report"),
                             br()),
                    fluidRow(plotOutput("suspectPlot")),
                    fluidRow(selectizeInput(inputId = "selectedSus",
                                            label = "Select Item to Display",
                                            choice = c("Suspect's Age Group", 
                                                       "Suspect's Race", 
                                                       "Suspect's Sex"),
                                            selected = "Suspect's Age Group"),
                             br()),
                    fluidRow(plotOutput("victimPlot")),
                    fluidRow(selectizeInput(inputId = "selectedVic",
                                            label = "Select Item to Display",
                                            choice = c("Victim's Age Group", 
                                                       "Victim's Race", 
                                                       "Victim's Sex"),
                                            selected = "Victim's Age Group"),
                             br()),
                    fluidRow(plotOutput("placePlot")),
                    fluidRow(selectizeInput(inputId = "selectedPlace",
                                            label = "Select Item to Display",
                                            choice = c("Borough", "Park Name", 
                                                       "General Location"), 
                                            # c("name" = ugly)
                                            selected = "Borough"))),
            
            tabItem(tabName = "data",
                    fluidRow(box(DT::dataTableOutput("table"), width = 12))),
            
            tabItem(tabName = "model",
                    fluidRow(h3("Statistical Model"),
                             p("This two parameter regression model was 
                               generated using stan_glm in the rstanarm package. 
                               The formula used was the time a reported crime 
                               ended as a function of the crime's level of 
                               offense. So, there are 3 predictors: felony, 
                               misdemeanor, and violation.")),
                    fluidRow(plotOutput("modelPlot"),
                             br()),
                    fluidRow(p("The median of the intercept for felonies was 
                               12.98539, which would translate to a little about 
                               12:59pm EDT. This is the median of the average 
                               times at would translate to right about 1:01pm 
                               EDT. This is the median of the average times at 
                               which misdemeanor crimes are reported. The median 
                               of the intercept for violations was 13.89109, 
                               which would translate to later, around 1:54pm 
                               EDT. This is the median of the average times at 
                               which violation crimes are reported. The to a 
                               high degree of preciseness within' the dataset. 
                               The median of the auxilary parameter, sigma, was 
                               6.30854 while its MAD_SD was 0.00891"))),
            
            # The tag for the data url stopped working when I introduced a line
            # break to it so I kept it as is, although it breaks the 80
            # character style rule.

            tabItem(tabName = "about",
                    fluidRow(h3("Project Background"),
                             p("This project analyzes the NYPD crime complaints 
                             recorded from 1918-2020.  I look specifically at 
                             the observations under the NYPD jurisdiction. The 
                             plots compare between the race, sex, and age of 
                             individuals involved in these crime reports: the 
                             suspect and victim. Another plots are organized 
                             into three categories: characteristics of crime 
                             suspects, characteristics of crime victims, and 
                             characteristics of crime locations. The model 
                             graphs the level of offense to the time of day 
                             crimes have taken place."),
                             p("The data is sourced from New York City’s open 
                               data source website found",
                               tags$a(href = "https://data.cityofnewyork.us/Public-Safety/NYPD-Complaint-Data-Current-Year-To-Date-/5uac-w243",
                                      "here!"),
                               "Variables referenced in the data tab are also 
                               described at this link."),
                             h3("About Me"),
                             p("Hi! My name is Geena Kim and I'm in the 
                             graduating class of 2023 at Harvard University. 
                             I'm an AB candidate in computer science 
                               with an interest in data science. "),
                             p("You can reach me at gkim@college.harvard.edu. 
                               You can also checkout my github and project 
                               source code ",
                               tags$a(href = "https://github.com/gnakim",
                                      "here!"))))
        )
    )
))