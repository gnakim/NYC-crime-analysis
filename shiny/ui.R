library(DT)
library(shiny)
library(shinydashboard)

crime_data <- readRDS("crime_data.RDS")

shinyUI(dashboardPage(
    dashboardHeader(title = "NYC Crime Report Analysis"),
    dashboardSidebar(
        
        sidebarUserPanel("NYC Crime Analysis 2019-2020"),
        sidebarMenu(
            menuItem("Model", tabName = "data_comp", icon = icon("chart-bar")),
            menuItem("Data", tabName = "data", icon = icon("database")),
            # menuItem("Model", tabName = "model", icon = icon("bookmark")),
            menuItem("About", tabName = "about", icon = icon("user"))
        )
    ),
    
    dashboardBody(
        tags$head(
            tags$link(rel = "stylesheet", type = "text/css", href = "custom.css")
        ),
        
        tabItems(
            tabItem(tabName = "data_comp",
                    fluidRow(plotOutput("suspectPlot")),
                    fluidRow(selectizeInput(inputId = "selectedSus",
                                            label = "Select Item to Display",
                                            choice = c("susp_age_group", "susp_race", "susp_sex"), # c("name" = ugly)
                                            selected = "susp_race")),
                    fluidRow(plotOutput("victimPlot")),
                    fluidRow(selectizeInput(inputId = "selectedVic",
                                            label = "Select Item to Display",
                                            choice = c("vic_age_group", "vic_race", "vic_sex"), # c("name" = ugly)
                                            selected = "vic_race")),
                    fluidRow(plotOutput("placePlot")),
                    fluidRow(selectizeInput(inputId = "selectedPlace",
                                            label = "Select Item to Display",
                                            choice = c("boro_nm", "parks_nm", "prem_typ_desc"), # c("name" = ugly)
                                            selected = "boro_nm"))),
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