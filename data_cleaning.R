library(tidyverse)
library(nominatim)
library(photon)

tweets1 <- readRDS("tweets_04112019.rds")
tweets2 <- readRDS("tweets_05022019.rds")

glimpse(tweets1)

tweets <- rbind(tweets1, tweets2) %>%
  distinct(status_id, .keep_all = TRUE)

tweets_simple <- 
  tweets %>%
  select(status_id, created_at, text, is_quote, favorite_count, retweet_count, hashtags, media_url, lang, place_full_name, country, status_url, name, location)

junk_locations <- c("#", "Gal", "\\", "/", "Earth", "Global", "Tramway", "Worldwide", "Summit", "team pucca", 
                    "The Great Wide Open", "Spider Hell", "the wild west", "At home", "By The Sea", "world", "ERROR", ";", 
                    "Author", "!", "Ocean", "global", "World", "earth", "&")

tweets_location <- 
  tweets_simple %>%
  filter(location != "" | !is.na(place_full_name)) %>%
  filter(!str_detect(.$location, paste(junk_locations, collapse = "|"))) 

#geocodes <- osm_geocode(tweets_location$location, key = "SS3xwin3B2tjrqdBAAs1GaAYl2OZR4Su")

tweets_media <- 
  tweets_location %>%
  filter(!is.na(media_url))

tweets_location_vec <- tweets_location$location

#testing photon geocoder
photon_geo_1 <- geocode(tweets_location_vec[1:200], limit = 1)

photon_geo <- list()
for(i in 4:10) {
  tryCatch(photon_geo[[i]] <- geocode(tweets_location_vec[((i*200)-199):(i*200)], limit = 1), 
           error = function(e) NA)
  Sys.sleep(3)
}

photon_geo[[4]] <- geocode(tweets_location_vec[601:800], limit = 1)
photon_geo[[5]] <- geocode(tweets_location_vec[801:1000], limit = 1)
photon_geo[[9]] <- geocode(tweets_location_vec[1601:1800], limit = 1)

photon_geo_df <- 
  photon_geo %>%
  bind_rows() %>%
  slice(1:1913) %>%
  select(location, name, city, state, country, osm_key, lon, lat)

tweets_location_geocode <- cbind(tweets_location, photon_geo_df)
#saveRDS(tweets_location_geocode, "tweets_geocoded.rds")
#rtweet::write_as_csv(tweets_location_geocode, "tweets_geocoded.csv")
#saveRDS(geocodes, "mapquest_geocodes.rds")

tweets_media_geocode <- tweets_location_geocode %>% 
  as_tibble(.name_repair = "unique") %>%
  filter(!is.na(media_url))

#saveRDS(tweets_media_geocode, "tweets_media_geocoded.rds")
#rtweet::write_as_csv(tweets_media_geocode, "tweets_media_geocoded.csv")

