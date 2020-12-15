library(DT)
library(shiny)
library(rstanarm)
library(data.table)
library(gt)


crime_data <- readRDS("crime_data.RDS")

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
            select(-c(cmplnt_num, pd_desc, crm_atpt_cptd_cd, 
                      cmplnt_to_dt, cmplnt_to_tm)) %>%
            drop_na()
        datatable(data_table, rownames=FALSE) %>% 
            formatStyle(input$selected, background="skyblue", fontWeight='bold')
    })
    
    # At first I had trouble with the ambiguous x value inputs for the graphs
    # and the unusual input$selectedSus and .data[[input$selectedSus]] syntax.
    # But it became manageable once I understood the concept of referencing the
    # selected input in accordance with the UI. Another aspect I had difficulty
    # with was the ggplot aesthetics: legend title renaming and overlapping
    # titles. Looking up the syntax for scale_fill_manual made my legend look
    # presentable, and I decided to put the x-axis names at a 45 degree angle so
    # that, with race, park names, and general location, there would be no label
    # overlap. Originally, I also had the rename portion of the code a lot more
    # complicated than it needed to be because I operated in the false
    # assumption that these chr variable names could not have whitespace. This
    # is normally convention, but if I work carefully and function-locally with
    # white space as variable names via rename, I've found that I could avoid
    # underscores in the rendered table. I just had to make sure the UI choices
    # of the selected input choices reflected the variable name changes I made.
    
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
                 x = input$selectedSus) +
            theme_bw() +
            scale_fill_manual(name = "Level of Offense", 
                              labels = c("Felony", "Misdemeanor", "Violation"),
                              values = c("steelblue", "cadetblue3", "azure2")) +
            scale_y_continuous(name = 
                                   "Crimes Committed Within' Specified Group", 
                               labels = scales::comma) +
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
                 x = input$selectedVic) +
            theme_bw() +
            scale_fill_manual(name = "Level of Offense", 
                              labels = c("Felony", "Misdemeanor", "Violation"),
                              values = c("steelblue", "cadetblue3", "azure2")) +
            scale_y_continuous(name = 
                                   "Crimes Committed Against Specified Group", 
                               labels = scales::comma) +
            theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1))
    })
    
    # Pipe the function into unique() to get rid of any repeated rows retained
    # after summarize
    
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
                 x = input$selectedPlace) +
            theme_bw() +
            scale_fill_manual(name = "Level of Offense", 
                              labels = c("Felony", "Misdemeanor", "Violation"),
                              values = c("steelblue", "cadetblue3", "azure2")) +
            scale_y_continuous(name = 
                                   "Crimes Committed In Specified Location", 
                               labels = scales::comma) +
            theme(axis.text.x = element_text(angle = 45, vjust = 1, hjust = 1))
    })
    
    output$modelPlot <- renderPlot({
        set.seed(30)
        
        # Convert the time from date-time for seamless integration into stan_glm
        
        model_data <- crime_data %>%
            select(law_cat_cd, cmplnt_to_tm) %>%
            drop_na() %>%
            mutate(time_chr = as.character(cmplnt_to_tm)) %>%
            mutate(time_sub = map_chr(time_chr, ~ substr(., 1, 2))) %>%
            mutate(time_numeric = as.numeric(time_sub)) %>%
            select(law_cat_cd, time_numeric)
        
        # For the stan_glm formula, subtract 1 to get rid of the intercept
        
        fitted_model <- model_data %>%
            stan_glm(formula = time_numeric ~ law_cat_cd - 1,
                     family = gaussian(),
                     refresh = 0)
        
        # Create posterior distribution histogram 
        
        fitted_model %>% 
            as_tibble() %>% 
            select(-sigma) %>% 
            mutate(Felony = law_cat_cdFELONY,
                   Misdemeanor = law_cat_cdMISDEMEANOR, 
                   Violation = law_cat_cdVIOLATION) %>%
            pivot_longer(cols = Felony:Violation,
                         names_to = "parameter",
                         values_to = "time") %>% 
            ggplot(aes(x = time, fill = parameter)) +
            geom_histogram(aes(y = after_stat(count/sum(count))),
                           alpha = 0.8, 
                           bins = 120, 
                           position = "identity",
                           color = "darkgrey") +
            labs(title = "Posterior Probability Distribution",
                 subtitle = "Average time of Crimes Reported in NYC since 1918",
                 x = "Time",
                 y = "Probability") +
            scale_fill_manual(name = "Level of Offense",
                              labels = c("Felony", "Misdemeanor", "Violation"),
                              values = c("steelblue", "cadetblue3", "azure3")) +
            scale_y_continuous(labels = scales::percent_format()) +
            theme_classic()
    })
    
    # output$modelTable <-render_gt({
    #     
    #     tibble(subject = c("Felony", "Misdemeanor ", "Violation", "Sigma"),
    #            Median = c("12.49758", "13.02425", "13.89109", "6.30854"),
    #            MAD_SD = c("0.02299", "0.01713", "0.03295", "0.00891")) %>%
    #         
    #         # table setup
    #         
    #         gt() %>%
    #         cols_label(subject = "Model",
    #                    Median = "Median",
    #                    MAD_SD = "MAD_SD") %>%
    #         tab_style(cell_borders(sides = "right"),
    #                   location = cells_body(columns = vars(subject))) %>%
    #         tab_style(cell_text(weight = "bold"),
    #                   location = cells_body(columns = vars(subject))) %>%
    #         cols_align(align = "center", columns = TRUE) %>%
    #         fmt_markdown(columns = TRUE) 
    # })
   
    
})