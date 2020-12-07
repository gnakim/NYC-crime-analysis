library(DT)
library(shiny)
library(shinydashboard)

#crime_data <- readRDS("crime_data.RDS")

shinyUI(dashboardPage(
    dashboardHeader(title = "NYC Crime Report Analysis"),
    dashboardSidebar(
        
        # The first argument after menuItem is the label of the tab, then
        # tabname is what is used to reference the tab. The icon is referenced
        # from a shiny icon gallery and shows which picture should show beside
        # the name on the tab.
        
        sidebarUserPanel("NYC Crime Analysis 2019-2020"),
        sidebarMenu(
            menuItem("Graphs", tabName = "data_comp", icon = icon("chart-bar")),
            menuItem("Data", tabName = "data", icon = icon("database")),
            menuItem("Model", tabName = "model", icon = icon("bookmark")),
            menuItem("About", tabName = "about", icon = icon("user"))
        )
    ),
    
    dashboardBody(
        
        # This is used to link the css sheet to the shiny so that there is
        # better control over the fonts and style of the site. I struggled with
        # this syntax for a bit.
        
        tags$head(
            tags$link(rel = "stylesheet", type = "text/css", 
                      href = "custom.css")
        ),
        
        # One of the trickiest parts of shiny, for me, was figuring out the
        # syntax for the ui portion of the project. Everything became easier to
        # manage after realizing that choice could be anything, and I could just
        # use that to reference portions of the crime data. At first, I had the
        # column names as the choices, so some of the option just did not work,
        # because the plot wasn't meant to handle certain types. Limiting the
        # user's access to choices was a prompt fix. I just had to be careful
        # that the choices matched up with the actual variable names, especially
        # after the renaming fiasco that happened on the server end.
        
        # One thing I would like to implement on the about page before the final
        # project is due is giving wider margins for the text on the left and
        # right.
        
        tabItems(
            tabItem(tabName = "data_comp",
                    fluidRow(plotOutput("suspectPlot")),
                    fluidRow(selectizeInput(inputId = "selectedSus",
                                            label = "Select Item to Display",
                                            choice = c("Suspect's Age Group", 
                                                       "Suspect's Race", 
                                                       "Suspect's Sex"),
                                            selected = "Suspect's Age Group")),
                    fluidRow(plotOutput("victimPlot")),
                    fluidRow(selectizeInput(inputId = "selectedVic",
                                            label = "Select Item to Display",
                                            choice = c("Victim's Age Group", 
                                                       "Victim's Race", 
                                                       "Victim's Sex"),
                                            selected = "Victim's Age Group")),
                    fluidRow(plotOutput("placePlot")),
                    fluidRow(selectizeInput(inputId = "selectedPlace",
                                            label = "Select Item to Display",
                                            choice = c("Borough", "Park Name", 
                                                       "General Location"), 
                                            # c("name" = ugly)
                                            selected = "Borough")),
                    column(4,
                           imageOutput("population"))),
            
            tabItem(tabName = "data",
                    fluidRow(box(DT::dataTableOutput("table"), width = 12))),
            
            tabItem(tabName = "model",
                    fluidRow(h3("Statistical Model"),
                             p("This one parameter model was generated using stan_glm model. The formula used was the ending time of the crime as a function of a constant"),
                             p("The median of the intercept was 12.98539, which would translate to 1pm EDT. This is the time at which most crimes are likely to happen. The MAD_SD of the intercept was 0.01177, translating to a high degree of preciseness within' the dataset"),
                             p("The median of the auxilary parameter, sigma, was 6.32472 while its MAD_SD was 0.00882")),
                    fluidRow(plotOutput("modelPlot")),
                    column(4,
                           imageOutput("stan_glm_pic"))),
            
            
            tabItem(tabName = "about",
                    fluidRow(h3("Project Background and Motivations"),
                             p("This project analyzes the NYPD crime reports from 2019-2020. I look specifically at the observations under the NYPD jurisdiction
                               The plots compare between the race, sex, and age of individuals involved in these crime reports: the suspect and victim.
                               I also look into the location and times crimes most likely take place. The locations look at boroughs, parks, and buildings in NYC."),
                             h3("About Me"),
                             p("Hi! I'm Geena Kim and I'm a sophomore at Harvard University
                               studying computer science and chemistry."),
                             p("You can reach me at gkim@college.harvard.edu.")))
        )
    )
))