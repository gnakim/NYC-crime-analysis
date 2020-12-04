library(DT)
library(shiny)
library(rstanarm) # for stan_glm

crime_data <- readRDS("crime_data.RDS")

shinyServer(function(input, output){
    
    # show data using DataTable on the Data tab
    output$table <- DT::renderDataTable({
        datatable(crime_data, rownames=FALSE) %>% 
            formatStyle(input$selected, background="skyblue", fontWeight='bold')
    })
    
    output$suspectPlot <- renderPlot({
        
        # nice <- tibble(ugly_names = colnames(crime_data),
        #                      nice_names = c(1:20)) # type out nice names
        #     
        # nice$nice_names[which(nice$ugly_names == "boro_nm")]
        
        crime_data %>%
            select(susp_age_group, susp_race, susp_sex, law_cat_cd) %>%
            filter(susp_age_group != "UNKNOWN", susp_race != "UNKNOWN", susp_sex != "U") %>%
            filter(!(susp_age_group %in% c("-928", "-942", "-965", "1925", "2019"))) %>%
            group_by(.data[[input$selectedSus]]) %>%
            summarise(count = n(), .groups = "drop", law_cat_cd) %>%
            ggplot(aes(x = fct_reorder(.data[[input$selectedSus]], count), y = count, fill = law_cat_cd)) +
            geom_col() +
            labs(title = "Characteristics of Crime Suspects",
                 y = "Number of Crimes Committed within' Specified Group",
                 # x = nice$nice_names[which(nice$ugly_names == input$selected)]) +
                 x = input$selectedSus) +
            theme_bw()
    })
    
    output$victimPlot <- renderPlot({
        crime_data %>%
            select(vic_age_group, vic_race, vic_sex,law_cat_cd) %>%
            drop_na() %>%
            filter(vic_age_group != "UNKNOWN", vic_race != "UNKNOWN", vic_sex != "U") %>%
            group_by(.data[[input$selectedVic]]) %>%
            summarise(count = n(), .groups = "drop", law_cat_cd) %>%
            ggplot(aes(x = fct_reorder(.data[[input$selectedVic]], count), y = count, fill = law_cat_cd)) +
            geom_col() +
            labs(title = "Characteristics of Crime Victims",
                 y = "Number of Crimes Committed Against' Specified Group",
                 x = input$selectedVic) +
            theme_bw()
    })
    
    output$placePlot <- renderPlot({
        crime_data %>%
            select(boro_nm, parks_nm, prem_typ_desc, law_cat_cd) %>%
            drop_na(input$selectedPlace) %>%
            group_by(.data[[input$selectedPlace]]) %>%
            summarise(count = n(), .groups = "drop", law_cat_cd) %>%
            ggplot(aes(x = fct_reorder(.data[[input$selectedPlace]], count), y = count, fill = law_cat_cd)) +
            geom_col() +
            labs(title = "Places Crimes Took Place",
                 y = "Number of Crimes Committed In Specified Place",
                 x = input$selectedPlace) +
            theme_bw()
    })
    
    output$modelPlot <- renderPlot({
        fitted_model <- crime_data %>%
            select(law_cat_cd, susp)
            stan_glm(formula = ,
                     family = gaussian(),
                     refresh = 0)
    })
    
    
    
})