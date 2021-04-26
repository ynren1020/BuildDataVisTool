#' geom_hurricane function for week 4 project
#'
#' @param x longitude
#' @param y latitude
#' @param r_ne Northeast radius
#' @param r_se Southeast radius
#' @param r_sw Southwest radius
#' @param r_nw Northwest radius
#' export
#' examples
#' geom_hurricane(data = ext_tracks_reform, 
#'                 aes(x = longitude, y = latitude,
#'                     r_ne = ne, r_se = se,
#'                     r_nw = nw, r_sw = sw,
#'                     fill = wind_speed,
#'                     color = wind_speed))



GeomHurricane <- ggplot2::ggproto("GeomHurricane",
                                  Geom,
                                  required_aes = c("x",  # longitude
                                                   "y",     # latitude
                                                   "r_ne",  
                                                   "r_se",  
                                                   "r_sw",  
                                                   "r_nw"), 
                                  
                                  default_aes = ggplot2::aes(colour  = "black",  
                                                             fill        = "black",  
                                                             linetype    = 0,        
                                                             alpha       = 0.65,     
                                                             scale_radii = 1.0),     
                                  
                                  draw_key = draw_key_polygon,
                                  
                                  draw_group = function(data,
                                                        panel_scales,
                                                        coord) {
                                      # Creating a data frame
                                      df_hurricane <- dplyr::as_tibble()
                                      center       <- dplyr::as_tibble()
                                      
                                      # Adding new columns
                                      data %>% dplyr::mutate(fill = fill,     
                                                             colour = colour) 
                                      
                                      # Center of the hurricane
                                      center <- data %>% dplyr::select(lon = x,           
                                                                       lat = y)  
                                      
                                      # transform radius
                                      radius <- data %>% dplyr::select(r_ne,       
                                                             r_se,       
                                                             r_sw,       
                                                             r_nw) %>%   
                                          
                                          dplyr::mutate(r_ne = data$scale_radii * r_ne * 1852,  
                                                        r_se = data$scale_radii * r_se * 1852, 
                                                        r_sw = data$scale_radii * r_sw * 1852, 
                                                        r_nw = data$scale_radii * r_nw * 1852) 
                                      
                                      # four quadrants (columns)
                                      for (i in 1:4)
                                      {
                                          # For each quadrant: Loop to create the 34, 50 and 64 knot areas (rows)
                                          for (j in 1:nrow(data))
                                          {
                                              # Generating the points
                                              df_hurricane <- geosphere::destPoint(c(x = center[j,1],        # Center of the "circle"
                                                                                     y = center[j,2]),       # 
                                                                                     b = ((i-1)*90):(90*i),  # 360 degrees (a complete circle)
                                                                                     d = radius[j,i]) %>%    # radius
                                                  
                                                  rbind(c(x = center[j,1],       # Longitude
                                                          y = center[j,2])) %>%  # Latitude
                                                  
                                                  rbind(df_hurricane)  
                                          }
                                          
                                          # Data Manipulation
                                          quadrant_points <- df_hurricane %>% 
                                              
                                              dplyr::as_tibble() %>% 
                                              
                                              dplyr::rename(x = lon,     
                                                            y = lat) %>%  
                                              
                                              coord$transform(panel_scales)  
                                      }
                                      
                                      # Plot the polygon
                                      grid::polygonGrob(x = quadrant_points$x,   
                                                        y = quadrant_points$y,   
                                                        default.units = "native",
                                                        gp = grid::gpar(col = data$colour,  
                                                                        fill = data$fill,   
                                                                        alpha = data$alpha, 
                                                                        lty = 1,            
                                                                        scale_radii = data$scale_radii))       
                                  }
)

# Default functions
geom_hurricane <- function(mapping = NULL,
                           data = NULL,
                           stat = "identity",
                           position = "identity",
                           na.rm = FALSE,
                           show.legend = NA,
                           inherit.aes = TRUE, ...){
    
    ggplot2::layer(geom = GeomHurricane,
                   mapping = mapping,
                   data = data,
                   stat = stat,
                   position = position,
                   show.legend = show.legend,
                   inherit.aes = inherit.aes,
                   params = list(na.rm = na.rm,...)
    )
}












