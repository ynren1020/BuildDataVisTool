# April 19, 2021 ---
# create new stat, follow reference from Extending-ggplot2 ---
# examples are from the link (https://cran.r-project.org/web/packages/ggplot2/vignettes/extending-ggplot2.html)

# Step 1
#We’ll start by creating a very simple stat: one that gives the convex hull (the c hull) of a set of points.
#First we create a new ggproto object that inherits from Stat:

StatChull <- ggproto("StatChull", Stat,
                     compute_group = function(data, scales) {
                         data[chull(data$x, data$y), , drop = FALSE]
                     },
                     
                     required_aes = c("x", "y")
)

#The two most important components are the compute_group() method 
#(which does the computation), and the required_aes field, which 
#lists which aesthetics must be present in order for the stat to work.

# Step 2
#Next we write a layer function.
# All layer functions follow the same form - you specify defaults in the function 
# arguments and then call the layer() function, sending ... into the params argument. 
# The arguments in ... will either be arguments for the geom (if you’re making a stat wrapper), 
# arguments for the stat (if you’re making a geom wrapper), or aesthetics to be set. 
# layer() takes care of teasing the different parameters apart and making sure they’re stored in the right place:

stat_chull <- function(mapping = NULL, data = NULL, geom = "polygon",
                       position = "identity", na.rm = FALSE, show.legend = NA, 
                       inherit.aes = TRUE, ...) {
    layer(
        stat = StatChull, data = data, mapping = mapping, geom = geom, 
        position = position, show.legend = show.legend, inherit.aes = inherit.aes,
        params = list(na.rm = na.rm, ...)
    )
}

# Step 3 
# try
ggplot(mpg, aes(displ, hwy)) + 
    geom_point() + 
    stat_chull(fill = NA, colour = "black")

ggplot(mpg, aes(displ, hwy, colour = drv)) + 
    geom_point() + 
    stat_chull(fill = NA)

ggplot(mpg, aes(displ, hwy)) + 
    stat_chull(geom = "point", size = 4, colour = "red") +
    geom_point()


# Another example ---
# A more complex stat will do some computation. Let’s implement a simple version 
# of geom_smooth() that adds a line of best fit to a plot. 
# We create a StatLm that inherits from Stat and a layer function, stat_lm():

StatLm <- ggproto("StatLm", Stat, 
                  required_aes = c("x", "y"),
                  
                  compute_group = function(data, scales) {
                      rng <- range(data$x, na.rm = TRUE)
                      grid <- data.frame(x = rng)
                      
                      mod <- lm(y ~ x, data = data)
                      grid$y <- predict(mod, newdata = grid)
                      
                      grid
                  }
)


stat_lm <- function(mapping = NULL, data = NULL, geom = "line",
                    position = "identity", na.rm = FALSE, show.legend = NA, 
                    inherit.aes = TRUE, ...) {
    layer(
        stat = StatLm, data = data, mapping = mapping, geom = geom, 
        position = position, show.legend = show.legend, inherit.aes = inherit.aes,
        params = list(na.rm = na.rm, ...)
    )
}

ggplot(mpg, aes(displ, hwy)) + 
    geom_point() + 
    stat_lm()

# StatLm is inflexible because it has no parameters. We might want to allow 
# the user to control the model formula and the number of points used to generate the grid. 
# To do so, we add arguments to the compute_group() method and our wrapper function:

StatLm <- ggproto("StatLm", Stat, 
                  required_aes = c("x", "y"),
                  
                  compute_group = function(data, scales, params, n = 100, formula = y ~ x) {
                      rng <- range(data$x, na.rm = TRUE)
                      grid <- data.frame(x = seq(rng[1], rng[2], length = n))
                      
                      mod <- lm(formula, data = data)
                      grid$y <- predict(mod, newdata = grid)
                      
                      grid
                  }
)

stat_lm <- function(mapping = NULL, data = NULL, geom = "line",
                    position = "identity", na.rm = FALSE, show.legend = NA, 
                    inherit.aes = TRUE, n = 50, formula = y ~ x, 
                    ...) {
    layer(
        stat = StatLm, data = data, mapping = mapping, geom = geom, 
        position = position, show.legend = show.legend, inherit.aes = inherit.aes,
        params = list(n = n, formula = formula, na.rm = na.rm, ...)
    )
}

ggplot(mpg, aes(displ, hwy)) + 
    geom_point() + 
    stat_lm(formula = y ~ poly(x, 10)) + 
    stat_lm(formula = y ~ poly(x, 10), geom = "point", colour = "red", n = 20)

# Note that we don’t have to explicitly include the new parameters in the arguments 
# for the layer, ... will get passed to the right place anyway. 
# But you’ll need to document them somewhere so the user knows about them. 
# Here’s a brief example. Note @inheritParams ggplot2::stat_identity: 
# that will automatically inherit documentation for all the parameters also defined for stat_identity().

#' @export
#' @inheritParams ggplot2::stat_identity
#' @param formula The modelling formula passed to \code{lm}. Should only 
#'   involve \code{y} and \code{x}
#' @param n Number of points used for interpolation.
stat_lm <- function(mapping = NULL, data = NULL, geom = "line",
                    position = "identity", na.rm = FALSE, show.legend = NA, 
                    inherit.aes = TRUE, n = 50, formula = y ~ x, 
                    ...) {
    layer(
        stat = StatLm, data = data, mapping = mapping, geom = geom, 
        position = position, show.legend = show.legend, inherit.aes = inherit.aes,
        params = list(n = n, formula = formula, na.rm = na.rm, ...)
    )
}





