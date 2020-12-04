# (optional file) defines objects available to both ui.R and server.R

library(tidyverse)
library(janitor)
# crime_data <- read_csv('raw_data/NYPD_crime_data.csv',
#                        col_types = cols(
#                          .default = col_character(),
#                          CMPLNT_NUM = col_double(),
#                          ADDR_PCT_CD = col_double(),
#                          CMPLNT_FR_TM = col_time(format = ""),
#                          CMPLNT_TO_TM = col_time(format = ""),
#                          HOUSING_PSA = col_double(),
#                          JURISDICTION_CODE = col_double(),
#                          KY_CD = col_double(),
#                          PD_CD = col_double(),
#                          TRANSIT_DISTRICT = col_double(),
#                          X_COORD_CD = col_double(),
#                          Y_COORD_CD = col_double(),
#                          Latitude = col_double(),
#                          Longitude = col_double())) %>%
#   clean_names() %>%
#   select(-c(cmplnt_num, addr_pct_cd, hadevelopt, housing_psa, transit_district, 
#             x_coord_cd:new_georeferenced_column, patrol_boro, pd_cd, pd_desc,
#             jurisdiction_code, ky_cd)) %>%
#   filter(juris_desc == "N.Y. POLICE DEPT")
# 
# saveRDS(crime_data, "crime_data.RDS")

