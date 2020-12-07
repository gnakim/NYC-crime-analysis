library(DT)
library(shiny)
library(rstanarm) # for stan_glm
library(data.table)


#crime_data <- readRDS("crime_data.RDS")

shinyServer(function(input, output){
    
    # show data using DataTable on the Data tab
    # I had to decrease the number of selected because of the table, since it
    # isn't completely responsive, so only the most important and interesting
    # columns were kept in the data. I also drop_na for the entire graph here so
    # the audience can see only the most interesting parts, however, they should
    # be warned that this shrinks the data set by nearly hundreds of thousands
    # of observations compared to the compartmentalized drap_na used in the plot
    # renders.
    
    output$table <- DT::renderDataTable({
        data_table <- crime_data %>%
            select(-c(cmplnt_num, pd_desc, crm_atpt_cptd_cd)) %>%
            drop_na()
        datatable(data_table, rownames=FALSE) %>% 
            formatStyle(input$selected, background="skyblue", fontWeight='bold')
    })
    
    # show plots on data graph tab
    # At first I had trouble with the ambiguous x value inputs for the graphs
    # and the unusual input$selectedSus and .data[[input$selectedSus]] syntax.
    # But it became manageable once I understood the concept of referencing the
    # selected input in accordance with the UI. Another aspect I had difficulty
    # with was the ggplot aesthetics: legend title renaming and overlapping
    # titles. Looking up the syntax for scale_fill_manual made my legend look
    # presentable, and I decided to put the x-axis names at a 45 degree angle so
    # that, with race, park names, and general location, there would be no label
    # overlap. Something I want to implement is using a case_when function so
    # that only those x-axis that need it are put at an angle. It looks weird
    # when age/sex are put at a tilt. Originally, I also had the rename portion
    # of the code a lot more complicated than it needed to be because I operated
    # in the false assumption that these chr variable names could not have
    # whitespace. This is normally convention, but if I work carefully and
    # function-locally with white space as variable names via rename, I've found
    # that I could avoid underscores in the rendered table. I just had to make
    # sure the UI choices of the selected input choices reflected the variable
    # name changes I made.
    
    output$suspectPlot <- renderPlot({
        crime_data %>%
            select(susp_age_group, susp_race, susp_sex, law_cat_cd) %>%
            filter(susp_age_group != "UNKNOWN", susp_race != "UNKNOWN", 
                   susp_sex != "U") %>%
            filter(!(susp_age_group %in% 
                         c("-928", "-942", "-965", "1925", "2019"))) %>%
            rename("Suspect's Age Group" = susp_age_group, 
                   "Suspect's Race" = susp_race, "Suspect's Sex" = susp_sex) %>%
            group_by(.data[[input$selectedSus]]) %>%
            summarise(count = n(), .groups = "drop", law_cat_cd) %>%
            ggplot(aes(x = fct_reorder(.data[[input$selectedSus]], count), 
                       y = count, fill = law_cat_cd)) +
            geom_col() +
            labs(title = "Characteristics of Crime Suspects",
                 y = "Number of Crimes Committed within' Specified Group",
                 x = input$selectedSus) +
            theme_bw() +
            scale_fill_manual(name = "Level of Offense", 
                              labels = c("Felony", "Misdemeanor", "Violation"),
                              values = c("steelblue", "cadetblue3", "azure2")) +
            theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1))
    })
    
    output$victimPlot <- renderPlot({
        crime_data %>%
            select(vic_age_group, vic_race, vic_sex,law_cat_cd) %>%
            drop_na() %>%
            filter(vic_age_group != "UNKNOWN", vic_race != "UNKNOWN", 
                   vic_sex != "U") %>%
            filter(vic_age_group %in% 
                       c("<18", "65+", "18-24", "45-64", "25-44")) %>%
            filter(vic_sex %in% c("F", "M")) %>%
            rename("Victim's Age Group" = vic_age_group, 
                   "Victim's Race" = vic_race, "Victim's Sex" = vic_sex) %>%
            group_by(.data[[input$selectedVic]]) %>%
            summarise(count = n(), .groups = "drop", law_cat_cd) %>%
            ggplot(aes(x = fct_reorder(.data[[input$selectedVic]], count), 
                       y = count, fill = law_cat_cd)) +
            geom_col() +
            labs(title = "Characteristics of Crime Victims",
                 y = "Number of Crimes Committed Against' Specified Group",
                 x = input$selectedVic) +
            theme_bw() +
            scale_fill_manual(name = "Level of Offense", 
                              labels = c("Felony", "Misdemeanor", "Violation"),
                              values = c("steelblue", "cadetblue3", "azure2")) +
            theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1))
    })
    
    
    output$placePlot <- renderPlot({
        crime_data %>%
            select(boro_nm, parks_nm, prem_typ_desc, law_cat_cd) %>%
            rename("Borough" = boro_nm, "Park Name" = parks_nm, 
                   "General Location" = prem_typ_desc) %>%
            drop_na(input$selectedPlace) %>%
            group_by(.data[[input$selectedPlace]]) %>%
            summarise(count = n(), .groups = "drop", law_cat_cd) %>%
            unique() %>%
            arrange(desc(count)) %>%
            head(30) %>%
            ggplot(aes(x = fct_reorder(.data[[input$selectedPlace]], count), 
                       y = count, fill = law_cat_cd)) +
            geom_col() +
            labs(title = "Places Crimes Took Place",
                 y = "Number of Crimes Committed In Specified Place",
                 x = input$selectedPlace) +
            theme_bw() +
            scale_fill_manual(name = "Level of Offense", 
                              labels = c("Felony", "Misdemeanor", "Violation"),
                              values = c("steelblue", "cadetblue3", "azure2")) +
            theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1))
    })
    
    output$modelPlot <- renderPlot({
        fitted_model <- crime_data %>%
            select(law_cat_cd, susp)
            stan_glm(formula = ,
                     family = gaussian(),
                     refresh = 0)
    })
    
    
    
})