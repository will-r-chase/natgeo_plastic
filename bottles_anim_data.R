library(tidyverse)
library(jsonlite)

data_all <- readxl::read_excel("jambeck_with_oceans.xlsx")
data_select <- read_csv("plastic_bars_101719.csv")

data_all_clean <- 
  data_all %>%
  filter(country %in% data_select$country) %>%
  mutate(kg_mismanaged_per_sec = mismanaged_plastic_waste_2010_kg_minute / 60,
         ripples_per_second = kg_mismanaged_per_sec / 100,
         anim_interval_seconds = 1 / ripples_per_second) %>%
  select(-kg_mismanaged_per_sec, ripples_per_second) %>%
  arrange(match(country, data_select$country))

final_data <- 
  data_select %>%
  mutate(anim_interval_seconds = data_all_clean$anim_interval_seconds)

write_excel_csv(final_data, "plastic_bars_101919.csv")
write_json(final_data, "plastic_bars_101919.json")  
