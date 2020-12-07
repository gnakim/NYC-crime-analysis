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
                                            selected = "Suspect's Race")),
                    fluidRow(plotOutput("victimPlot")),
                    fluidRow(selectizeInput(inputId = "selectedVic",
                                            label = "Select Item to Display",
                                            choice = c("Victim's Age Group", 
                                                       "Victim's Race", 
                                                       "Victim's Sex"),
                                            selected = "Victim's Race")),
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
                    fluidRow(p("STAN GLM MODEL HERE")),
                    fluidRow(plotOutput("modelPlot"))),
            tabItem(tabName = "about",
                    fluidRow(h3("Project Background and Motivations"),
                             p("This project analyzes the NYPD crime reports from 2019-2020. 
                               I specifically analyze th race, sex, and age of people involved in these crime reports, the suspect and victim.
                               There is also a graph that analyzes the location of where the crime is committed. You can toggle between the boroughs,
                               parks, and buildings in NYC."),
                             h3("About Me"),
                             p("Hi! I'm Geena and I'm a sophomore at Harvard University
                               studying computer science and chemistry."),
                             p("You can reach me at gkim@college.harvard.edu.")))
        )
    )
))