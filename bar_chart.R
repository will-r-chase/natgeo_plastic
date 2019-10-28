library(tidyverse)
library(readxl)
library(countrycode)
library(geojsonio)
library(rmapshaper)
library(sf)
library(jsonlite)

data <- read_excel("JambeckSData_2014.xlsx") %>% janitor:: clean_names()
glimpse(data)

data_sort <- 
  data %>%
  select(country, mismanaged_plastic_waste_kg_person_day_7) %>%
  filter(!is.na(country)) %>%
  mutate(mismanaged_plastic_waste_kg_person_day_7 = parse_number(mismanaged_plastic_waste_kg_person_day_7),
         country = str_remove(country, "8")) %>%
  arrange(desc(mismanaged_plastic_waste_kg_person_day_7))

write_excel_csv(data_sort, "data_for_map.csv")

data_sort_tons <- 
  data %>%
  select(country, mismanaged_plastic_waste_in_2010_tonnes_7, mismanaged_plastic_waste_in_2025_tonnes_7) %>%
  filter(!is.na(country)) %>%
  mutate(tons_2010 = mismanaged_plastic_waste_in_2010_tonnes_7,
         tons_2025 = mismanaged_plastic_waste_in_2025_tonnes_7,
         country = str_remove(country, "8"), 
         average_waste_day = ((tons_2010 + tons_2025)/2)/365) %>%
  arrange(desc(average_waste_day))

data_oceans <- 
  data %>%
  select(country, mismanaged_plastic_waste_in_2010_tonnes_7, mismanaged_plastic_waste_in_2025_tonnes_7, mismanaged_plastic_waste_kg_person_day_7) %>%
  filter(!is.na(country)) %>%
  mutate(tons_2010 = mismanaged_plastic_waste_in_2010_tonnes_7,
         tons_2025 = mismanaged_plastic_waste_in_2025_tonnes_7,
         country = str_remove(country, "8"), 
         average_waste_day = ((tons_2010 + tons_2025)/2)/365) %>%
  arrange(desc(average_waste_day))

bars <- c("United States", "Canada", "Mexico", "Cuba","Nicaragua", "Ecuador", "Guatemala", "Colombia", "Costa Rica", "Brazil", "Venezuela","Chile", 
          "South Africa", "Nigeria", "Senegal","Morocco", "Cape Verde", "Egypt", "Somalia", "Spain", "Greece","Iceland","Sweden", 
          "Korea, North", "Germany","United Kingdom", "Israel", "Belgium",
          "Saudi Arabia", "Yemen","Turkey","Italy", "Norway", "Russia", "Poland", "Thailand", "Fiji", "Australia", "New Zealand", 
          "Malaysia", "Maldives", "China", "Philippines", "India", "Bangladesh", "Japan", "Korea, South (Republic of Korea)", "Taiwan",
          "Pakistan", "Indonesia")

data_chart <- 
  data_sort %>%
  filter(country %in% bars) %>%
  rename(plastic_waste = mismanaged_plastic_waste_kg_person_day_7) %>%
  mutate(complete = 0.25 - plastic_waste) %>%
  gather(key = var, value = value, -country) %>%
  mutate(country = fct_relevel(country, "United States", "Canada", "Mexico", "Nicaragua", "Colombia", "Costa Rica", "Brazil", "Chile", 
                               "South Africa", "Nigeria", "Morocco","Somalia", "Spain", "Sweden", "Ukraine", "Germany","United Kingdom", "Israel", 
                               "Saudi Arabia","Italy", "Norway", "Russia", "Thailand", "Fiji", "Australia",
                               "Malaysia", "Maldives", "China", "Philippines", "India"))

data_chart_tons <- 
  data_sort %>%
  filter(country %in% bars) %>%
  rename(plastic_waste = mismanaged_plastic_waste_kg_person_day_7) %>%
  mutate(complete = 0.25 - plastic_waste) %>%
  gather(key = var, value = value, -country) %>%
  mutate(country = fct_relevel(country, "United States", "Canada", "Mexico", "Nicaragua", "Colombia", "Costa Rica", "Brazil", "Chile", 
                               "South Africa", "Nigeria", "Morocco","Somalia", "Spain", "Sweden", "Ukraine", "Germany","United Kingdom", "Israel", 
                               "Saudi Arabia","Italy", "Norway", "Russia", "Thailand", "Fiji", "Australia",
                               "Malaysia", "Maldives", "China", "Philippines", "India"))


data_chart2 <- read_csv("countries_plastic_oceans.csv") %>%
  select(country, ocean, kg_person_day) %>%
  mutate(complete = 0.25 - kg_person_day) %>%
  gather(key = var, value = value, -country, -ocean) %>%
  arrange(ocean) %>%
  mutate(country = fct_inorder(country))

ggplot(data_chart2) +
  geom_bar(aes(x = country, y = value, fill = var), stat = "identity", width = 1) +
  scale_fill_manual(values = c("#16E3D0", "#F1EBCE"), guide = "none") +
  theme_minimal(base_size = 14) +
  theme(axis.title = element_blank(), axis.text.y = element_blank(),
        axis.text.x = element_text(angle = 90), panel.grid = element_blank())

ggsave("bar_chart_2.svg", height = 10, width = 15)

data_chart_tons <- read_csv("countries_plastic_oceans.csv") %>%
  select(country, ocean, tonnes_plastic_per_day) %>%
  mutate(complete = 37000 -tonnes_plastic_per_day) %>%
  gather(key = var, value = value, -country, -ocean) %>%
  arrange(ocean) %>%
  mutate(country = fct_inorder(country))

ggplot(data_chart_tons) +
  geom_bar(aes(x = country, y = value, fill = var), stat = "identity", width = 1) +
  scale_fill_manual(values = c("#16E3D0", "#F1EBCE"), guide = "none") +
  theme_minimal(base_size = 14) +
  theme(axis.title = element_blank(), axis.text.y = element_blank(),
        axis.text.x = element_text(angle = 90), panel.grid = element_blank())

ggsave("bar_chart_tonnes.svg", height = 10, width = 15)


data_sheet <- 
  data_oceans %>%
  select(country,tonnes_plastic_per_day = average_waste_day, kg_person_day = mismanaged_plastic_waste_kg_person_day_7) %>%
  filter(country %in% bars)

write_excel_csv(data_sheet, "countries_plastic_oceans2.csv")

#for map
world <- geojson_read("countries.geojson", what = "sp")

world_simple <- ms_simplify(world, keep = 0.005)
world_sf <- st_as_sf(world_simple) %>%
  filter(ADMIN != "Antarctica")

map_dat <- read_csv("data_for_map.csv")
world_plastic <- left_join(world_sf, map_dat, by = "ADMIN")

ggplot(world_plastic) +
  geom_sf(aes(fill = plastic), color = "white", size = 0.5) +
  scale_fill_gradientn(name = str_wrap("Mismanaged plastic (kg) per person per day", 30), 
                       colours = c("#64d3e2", "#bbe2e5", "#f4ece1", "#f4ece1", "#f4ece1", "#f4ece1", "#d7c5ab", "#d7c5ab", "#d7c5ab", "#d7c5ab", "#d7c5ab", "#c49e7a", "#c49e7a", "#c49e7a", "#c49e7a", "#c49e7a", "#c49e7a",  "#c49e7a", "#c49e7a", "#c49e7a" ),
                       na.value = "lightgrey") +
  coord_sf(crs = st_crs(54012)) + 
  theme(panel.background = element_rect(fill = "transparent"),
        panel.grid.major = element_line(color = "transparent"), 
        axis.text = element_blank(), 
        axis.ticks = element_blank(),
        legend.position = "bottom")


##output as topojson for SVG version
topojson_write(world_plastic, file = "plastic_map.topojson")


ggsave("worldMap_plastic_pollution3.svg", height = 8, width = 12)

ggsave("map_test.png", height = 8, width = 12)


##this is for JSON file for inbal's developer
data_percent <- 
  data_chart2 %>%
  select(country, var, value) %>%
  spread(key = var, value = value) %>%
  mutate(total = complete + kg_person_day,
         percent_sand = (kg_person_day / total) * 100,
         percent_water = (complete / total) * 100,
         country = ifelse(country == "Korea, South (Republic of Korea)", "South Korea", as.character(country)))

data_walk <- read_excel("walking_time_2.xlsx")
ocean_order <- read_csv("ocean_order.csv")

data_join <- 
  data_percent %>%
  select(country, percent_sand, percent_water) %>%
  left_join(., data_walk, by = "country") %>%
  mutate(walking_time_hours = round(walking_time_hours, 0),
         km_per_year = round(km_per_year, 0),
         tonnes_plastic_per_day = round(tonnes_plastic_per_day, 2)) %>%
  arrange(match(country, ocean_order$country))

write_excel_csv(data_join, "plastic_barchart_data.csv")
data_join_json <- toJSON(data_join)
write_json(data_join, "plastic_barchart_data.json")
