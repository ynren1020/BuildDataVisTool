# use geom_huricane -----


# load package 
library(dplyr)

# read in data ---
ext_tracks_widths <- c(7, 10, 2, 2, 3, 5, 5, 6, 4, 5, 4, 4, 5, 3, 4, 3, 3, 3,
                       4, 3, 3, 3, 4, 3, 3, 3, 2, 6, 1)
ext_tracks_colnames <- c("storm_id", "storm_name", "month", "day",
                         "hour", "year", "latitude", "longitude",
                         "max_wind", "min_pressure", "rad_max_wind",
                         "eye_diameter", "pressure_1", "pressure_2",
                         paste("radius_34", c("ne", "se", "sw", "nw"), sep = "_"),
                         paste("radius_50", c("ne", "se", "sw", "nw"), sep = "_"),
                         paste("radius_64", c("ne", "se", "sw", "nw"), sep = "_"),
                         "storm_type", "distance_to_land", "final")

ext_tracks <- readr::read_fwf("ebtrk_atlc_1851_2019.txt", 
                       readr::fwf_widths(ext_tracks_widths, ext_tracks_colnames))


# reformat Ike data---
ext_tracks <- ext_tracks[ext_tracks$storm_name=="IKE",]

ext_tracks$storm_id <- paste0(ext_tracks$storm_name,"-",ext_tracks$year)
ext_tracks$storm_name <- NULL
ext_tracks$date <- paste0(ext_tracks$year,"-",ext_tracks$month,"-",ext_tracks$day," ",ext_tracks$hour,":00:00")
ext_tracks$day <- ext_tracks$month <- ext_tracks$year <- ext_tracks$hour <- NULL
ext_tracks <- ext_tracks[,c(1,25,2:3,10:21)]
ext_tracks <- ext_tracks[ext_tracks$date=="2008-09-11 18:00:00",]
ext_tracks$longitude <- 0-ext_tracks$longitude

ext_tracks_reform <- ext_tracks%>%tidyr::pivot_longer(cols = contains("radius"), names_to = "wind_speed", 
             values_to = "value") %>%
    tidyr::separate(wind_speed, c(NA, "wind_speed", "direction"), sep = "_") %>%
    tidyr::pivot_wider(names_from = "direction", values_from = "value") 

write.table(ext_tracks_reform,"hurricane_IKE_091118.txt",col.names = TRUE, row.names = FALSE,
            sep = "\t", quote = FALSE)



# plot ---
library(ggplot2)
library(ggmap)

# API Key
# how to get API key https://developers.google.com/maps/documentation/maps-static/get-api-key#get-key
register_google(key = "mykey")

# Google Maps/Stratmen
base_map <- get_map(location = c(-88.9,25.8), # c(longitude,latitude)
        zoom = 5,
        maptype = "toner-background") %>%
    
    # Saving the map
    ggmap(extent = "device")



base_map +
    geom_hurricane(data = ext_tracks_reform, aes(x = longitude, y = latitude,
                                       r_ne = ne, r_se = se,
                                       r_nw = nw, r_sw = sw,
                                       fill = wind_speed,
                                       color = wind_speed)) +
    scale_color_manual(name = "Wind speed (kts)",
                       values = c("red", "orange", "yellow")) +
    scale_fill_manual(name = "Wind speed (kts)",
                      values = c("red", "orange", "yellow"))

