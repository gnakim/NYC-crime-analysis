library(DT)
library(shiny)
library(shinydashboard)

crime_data = readRDS("crime_data.rds")

shinyUI(dashboardPage(
    dashboardHeader(title = "NYC Crime Report Analysis"),
    dashboardSidebar(
        
        sidebarUserPanel("NYC Crime Analysis 2019-2020"),
        sidebarMenu(
            menuItem("Model", tabName = "model", icon = icon("bookmark")),
            menuItem("Data Comparisons", tabName = "data_comp", icon = icon("chart-bar")),
            menuItem("Data", tabName = "data", icon = icon("database")),
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
                                            choice = colnames(crime_data), # c("name" = ugly)
                                            selected = "vic_race"))),
            tabItem(tabName = "data",
                    fluidRow(box(DT::dataTableOutput("table"), width = 12))),
            tabItem(tabName = "about",
                    fluidRow(h3("Project Background and Motivations"),
                             p("This project analyzes the NYPD crime reports from 2019-2020. It allows us to see how activity has changed since the onset of the COVID-19 pandemic and what stayed the same."),
                             h3("About Me"),
                             p("Hi! I'm Geena and I'm a sophomore at Harvard University.I'm studying computer science and chemistry."),
                             br(),
                             p("You can reach me at gkim@college.harvard.edu.")))
        )
    )
))