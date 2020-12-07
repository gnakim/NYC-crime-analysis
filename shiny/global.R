# (optional file) defines objects available to both ui.R and server.R

library(tidyverse)
library(janitor)

crime_data <- read_csv('NYPD_crime_data.csv',
                       col_types = cols(
                         .default = col_character(),
                         CMPLNT_NUM = col_double(),
                         ADDR_PCT_CD = col_double(),
                         CMPLNT_FR_TM = col_time(format = ""),
                         CMPLNT_TO_TM = col_time(format = ""),
                         HOUSING_PSA = col_double(),
                         JURISDICTION_CODE = col_double(),
                         KY_CD = col_double(),
                         PD_CD = col_double(),
                         TRANSIT_DISTRICT = col_double(),
                         X_COORD_CD = col_double(),
                         Y_COORD_CD = col_double(),
                         Latitude = col_double(),
                         Longitude = col_double())) %>%
  clean_names() %>%
  filter(juris_desc == "N.Y. POLICE DEPT") %>%
  select(cmplnt_num,law_cat_cd, ofns_desc, pd_desc,
         susp_race, susp_age_group, susp_sex, vic_race, vic_age_group, vic_sex,
         boro_nm, parks_nm, prem_typ_desc,cmplnt_to_dt, cmplnt_to_tm,
         crm_atpt_cptd_cd)
 
# saveRDS(crime_data, "crime_data.RDS")

