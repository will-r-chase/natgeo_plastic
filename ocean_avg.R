library(tidyverse)
library(jsonlite)

data <- readxl::read_excel("jambeck_with_oceans.xlsx")

atlantic <- 
  data %>%
  filter(primary_ocean == "Atlantic" | secondary_ocean == "Atlantic") %>%
  summarize(mismanaged_plastic_kg_day = sum(mismanaged_plastic_waste_2010_kg_day)) %>%
  mutate(ocean = "Atlantic")
pacific <- 
  data %>%
  filter(primary_ocean == "Pacific" | secondary_ocean == "Pacific") %>%
  summarize(mismanaged_plastic_kg_day = sum(mismanaged_plastic_waste_2010_kg_day)) %>%
  mutate(ocean = "Pacific")
indian <- 
  data %>%
  filter(primary_ocean == "Indian" | secondary_ocean == "Indian") %>%
  summarize(mismanaged_plastic_kg_day = sum(mismanaged_plastic_waste_2010_kg_day)) %>%
  mutate(ocean = "Indian")
mediterranean <- 
  data %>%
  filter(primary_ocean == "Mediterranean" | secondary_ocean == "Mediterranean") %>%
  summarize(mismanaged_plastic_kg_day = sum(mismanaged_plastic_waste_2010_kg_day)) %>%
  mutate(ocean = "Mediterranean")

all_oceans <- 
  rbind(atlantic, pacific, indian, mediterranean) %>%
  mutate(percent_sand = (mismanaged_plastic_kg_day / 60585326) * 100,
         percent_water = 100 - percent_sand,
         mismanaged_plastic_kg_sec = mismanaged_plastic_kg_day / 86400,
         anim_interval_sec = 1000 / mismanaged_plastic_kg_sec) %>%
  select(ocean, everything())

write_excel_csv(all_oceans, "oceans_plastic_sum_102019.csv")
write_json(all_oceans, "oceans_plastic_sum_102019.json")  
