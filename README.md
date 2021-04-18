# BuildDataVisTool

The purpose of this assignment is to draw on your knowledge of the grid and ggplot2 package to build a new geom. You will then need to load and tidy the provided dataset in order to plot the geom on a map.

For this assessment, you will need to

Build a custom geom for ggplot2 that can be used to add the hurricane wind radii chart for a single storm observation to a map (i.e., could be used to recreate the figure shown above).
Use the geom to map the create a map showing the wind radii chart at one observation times for Hurricane Ike, which occurred in September 2008. Use an observation time when the storm was near or over the United States.

More specifically, you will need to

Download the data on all storms in the Atlantic basin from 1988–2015 (extended best tracks) tidy the dataset into “long” format. Data cleaning should include: (1) add a column for storm_id that combines storm name and year (the same storm name can be used in different years, so this will allow for the unique identification of a storm); (2) format the longitude to ensure it is numeric and has negative values for locations in the Western hemisphere (this will make it easier to use the longitude for mapping); (3) format and combine columns describing the date and time to create a single variable with the date-time of each observation; and (4) convert the data to a “long” format, with separate rows for each of the three wind speeds for wind radii (34 knots, 50 knots, and 64 knots). For example, the cleaned dataset for a single observation point for Hurricane Katrina may look like this after the data is tidied:
##       storm_id                date latitude longitude wind_speed  ne  nw
## 1 Katrina-2005 2005-08-29 12:00:00     29.5     -89.6         34 200 100
## 2 Katrina-2005 2005-08-29 12:00:00     29.5     -89.6         50 120  75
## 3 Katrina-2005 2005-08-29 12:00:00     29.5     -89.6         64  90  60
##    se  sw
## 1 200 150
## 2 120  75
## 3  90  60

Subset to the specific hurricane that you will be mapping (Hurricane Ike) and to a single observation time for that hurricane
Write the code for a geom named “geom_hurricane” that plots a wind radii for a single hurricane observation. For example, if this geom is added to a ggplot object with a dataset named katrina with the data shown above for a single observation point of the storm, you would get the following plot:

ggplot(data = katrina) +
  geom_hurricane(aes(x = longitude, y = latitude,
                     r_ne = ne, r_se = se, r_nw = nw, r_sw = sw,
                     fill = wind_speed, color = wind_speed)) +
  scale_color_manual(name = "Wind speed (kts)",
                     values = c("red", "orange", "yellow")) +
  scale_fill_manual(name = "Wind speed (kts)",
                    values = c("red", "orange", "yellow")) 
 
Test to ensure that you can use this geom to add a hurricane wind radii chart to a base map. For example, if you have created an ggmap object named base_map with a map of the Louisiana area, the following code should result in the map shown below the code:
map_data <- get_map("Louisiana", zoom = 6, maptype = "toner-background")
base_map <- ggmap(map_data, extent = "device")

base_map +
  geom_hurricane(data = katrina, aes(x = longitude, y = latitude,
                                       r_ne = ne, r_se = se,
                                       r_nw = nw, r_sw = sw,
                                       fill = wind_speed,
                                       color = wind_speed)) +
  scale_color_manual(name = "Wind speed (kts)",
                     values = c("red", "orange", "yellow")) +
  scale_fill_manual(name = "Wind speed (kts)",
                    values = c("red", "orange", "yellow"))
  
As a hint, notice that the wind radii geom essentially shows a polygon for each of the wind levels. One approach to writing this geom is therefore to write the hurricane stat / geom combination that uses the wind radii to calculate the points along the boundary of the polygon and then create a geom that inherits from a polygon geom. See the vignette for the geosphere package (https://cran.r-project.org/web/packages/geosphere/vignettes/geosphere.pdf) for more on how to calculate latitude and longitude values from a starting latitude and longitude, a distance, and a bearing. This will help you get some ideas on how to calculate the polygon boundary using data available from the wind radii.

The wind radii give the maximum radial extent of winds of a certain direction in each quadrant. In some circumstances, you may want to plot a certain percentage of the full wind radii, to give a better idea of average exposures in each quadrant. For example, you might want to plot a chart based on radii that are 80% of these maximum wind radii. Include a parameter in your geom called scale_radii that allows the user to plot wind radii charts with the radii scaled back to a certain percent of the maximum radii. For example, if a user set “scale_radii = 0.8”, the geom should plot a wind radii chart mapping the extent of 80% of the maximum wind radii in each quadrant.
If functions from other packages are called, you should use the appropriate :: notation to reference those functions (e.g., “dplyr::mutate” rather than “mutate”). If you were writing this geom to include as code in an R package, this step is very important because it ensures that the code will be robust to which packages (and in which order) another user has loaded in his or her R session. By using the package::function notation, you ensure that the user will use a function from a specific package. The exception is infix operators, like %>%, which are placed between operands; for infix operators, you should not use the package::function notation.
Write documentation in roxygen2 format that provides help file information for your geom


The hurricane data is a bit tricky to read into R so we provide some  code for doing so. After downloading the data from Coursera, unzip the zip file and you should have a file named "ebtrk_atlc_1988_2015.txt" on your computer. You can read the data in as follows.

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

ext_tracks <- read_fwf("ebtrk_atlc_1988_2015.txt", 
                       fwf_widths(ext_tracks_widths, ext_tracks_colnames),
                       na = "-99")
                      
After executing this code you should have an object named "ext_tracks" in your R workspace. Make sure that the data file is in your working directory before running this code.

Once you have read the data in, you should tidy it and subset to a single observation time for a single storm, so that you are working with a dataset that looks like this, with a single storm, a single date (giving the time of that observation), a single center storm location, three rows for each of the wind intensities (34, 50, and 64 knots), and columns for the wind radii for a given intensity in each of the four quadrants: 
#      storm_id                date latitude longitude wind_speed  ne  nw  se
## Katrina-2005 2005-08-29 12:00:00     29.5     -89.6         34 200 100 200
## Katrina-2005 2005-08-29 12:00:00     29.5     -89.6         50 120  75 120
## Katrina-2005 2005-08-29 12:00:00     29.5     -89.6         64  90  60  90
#   sw
## 150
##  75
##  60

While these geoms resemble wind rose diagrams, which can be created fairly easily in ggplot2 using polar coordinates with bar charts, you need to be careful about using that approach here. The wind radii charts should show the geographic locations within each radius, so you should include some code when creating your geom that calculates the latitude and longitude locations around the perimeter of the wind radii chart based on the center latitude and longitude and the radius. You may want to use a function from a package like geosphere to do this step. Keep in mind that the wind radii in the original data are reported in nautical miles. It is fine if your geom inherits from another geom, like the polygon geom. 

Once you have created your geom, you should be able to add a wind radii chart to a base map using something like the following code (based on how you write your geom, the call might vary a bit from this): 

library(ggmap)
get_map("Louisiana", zoom = 6, maptype = "toner-background") %>%
  ggmap(extent = "device") +
  geom_hurricane(data = storm_observation,
                 aes(x = longitude, y = latitude, 
                     r_ne = ne, r_se = se, r_nw = nw, r_sw = sw,
                     fill = wind_speed, color = wind_speed)) + 
  scale_color_manual(name = "Wind speed (kts)", 
                     values = c("red", "orange", "yellow")) + 
  scale_fill_manual(name = "Wind speed (kts)", 
                    values = c("red", "orange", "yellow"))
                    
  The following graph shows an example of the scale_radii option in action when mapping a chart for Hurricane Katrina. The plot on the left is using the default value of scale_radii (which should be 1), so it's showing the wind radii chart based on the maximum radii. The plot on the right has a scale_radii value of 0.5, so it's showing a chart based on wind radii scaled to 50% of the maximum radii values: 
  
  To submit this assignment you must submit

An R script containing the code implementing the geom
A plot file (in PNG or PDF format) containing a map that has the wind radii overlayed for Hurricane Ike
This assessment will ask reviewers the following questions:

Is a map included that shows the wind radii for a single observation time for Hurricane Ike?
Does the map show the correct hurricane?
Does the geom correctly map locations for the wind radii based on the center point, radii, and direction?
Is the proper notation used for calling functions in other packages?
Is there roxygen2-style documentation included in the R script?
Are all the parameters of the geom documented and described?
Does the geom include a scale_radii parameter that functions as described?
