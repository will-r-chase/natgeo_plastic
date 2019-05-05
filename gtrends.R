#have to load fonts before ggplot
extrafont::loadfonts(device="win")

library(tidyverse)
library(gtrendsR)
library(janitor)
library(directlabels)

data(countries)
country_codes <- countries %>% distinct(country_code) %>% pull(country_code) %>% as.character()
country_codes <- country_codes[-c(62, 151, 200, 233, 252)] #these don't have data on google trends so they give errors

#to collect google trend data
#this takes a long time
########################
# ocean_plastic <- list()
# for(i in 1:length(country_codes)) {
#   ocean_plastic[[country_codes[i]]] <- gtrends("ocean plastic", geo = country_codes[i], time = "all")
#   Sys.sleep(3)
# }
# 
# plastic_pollution <- list()
# for(i in 1:length(country_codes)) {
#   plastic_pollution[[country_codes[i]]] <- gtrends("plastic pollution", geo = country_codes[i], time = "all")
#   Sys.sleep(3)
# }

#saveRDS(ocean_plastic, "ocean-plastic_gtrend.RDS")
#saveRDS(plastic_pollution, "plastic-pollution_gtrend.RDS")

ocean_plastic <- readRDS("ocean-plastic_gtrend.RDS")
plastic_pollution <- readRDS("plastic-pollution_gtrend.RDS")

ocean_plastic_time <- read_csv("google_trends/ocean-plastic_by_time.csv", skip = 2) %>% clean_names()
ocean_plastic_region <- read_csv("google_trends/ocean-plastic_by_region.csv", skip = 2) %>% clean_names()
plastic_pollution_time <- read_csv("google_trends/plastic-pollution_by_time.csv", skip = 2) %>% clean_names()
plastic_pollution_region <- read_csv("google_trends/plastic-pollution_by_region.csv", skip = 2) %>% clean_names()

ocean_plastic_time_clean <- 
  ocean_plastic_time %>%
  mutate(month = paste(month, "01", sep = "-"), time = lubridate::ymd(month), group = "Ocean plastic") %>%
  rename(value = ocean_plastic_worldwide)

plastic_pollution_time_clean <- 
  plastic_pollution_time %>%
  mutate(month = paste(month, "01", sep = "-"), time = lubridate::ymd(month), group = "Plastic pollution") %>%
  rename(value = plastic_pollution_worldwide)

plastic_all <- rbind(ocean_plastic_time_clean, plastic_pollution_time_clean)

ggplot(plastic_all) +
  geom_line(aes(x = time, y = value, group = group, color = group), size = 1.5) +
  scale_color_manual(values = c("#F0C73B", "#E5957C"), guide = "none") +
  geom_dl(aes(x = time, y = value, color = group, label = group), method = list(cex = 3.5, dl.trans(x = x + 0.2), "last.qp")) + 
  scale_x_date(expand = expand_scale(mult = c(0, 0.15))) +
  theme_minimal(base_family = "Comfortaa", base_size = 12) +
  theme(plot.background = element_rect(fill = "#DCEEE0"), plot.margin = margin(t = 20, b = 15, l = 15, r = 20), 
        panel.grid.major.y = element_line(color = "white"), title = element_text(size = 16)) +
  labs(x = "", y = "Search popularity", title = "Worldwide Google search trends, 2004 to present")

ggsave("google_trends.png", device = "png", type = "cairo", height = 6, width = 8)

