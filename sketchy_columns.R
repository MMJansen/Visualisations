################################################################################
###
### Making sketchy column charts
###
### Martine Jansen, 2024_04_30
###
### Inspired by & thanks to Nicola Rennie's blog
### https://nrennie.rbind.io/blog/sketchy-waffle-charts-r/
###
### and thanks to David Schoch for making roughsf
### https://github.com/schochastics/roughsf
###
################################################################################



# libraries needed: sf, dplyr, purrr, roughsf

#  some_data is a data frame with 4 columns:
# -  label; description of the column, used for labelling
# -  x; denoting the order on the x-axis
# -  n; the height of the column
# - fill; a hex colour coded fill colour for the column


plot_sketchy_column <- function(some_data, width_of_columns, some_title,
                                size_title = 50, size_label = 40){
  
  #### making the labels -------------------------------------------------------
  
  some_labels <- some_data |>
    dplyr::select(label)

  # the point where the label is attached,
  # should be in the mid of the column
  # at the bottom of the bar

  list_points <- list()
  for (i in 1:nrow(some_data)){
    list_points[[i]] <- sf::st_point(c(some_data$x[i] + 0.5*width_of_columns, 0))
  }

  some_labels$geometry <- sf::st_sfc(list_points)

  sf_some_labels <- sf::st_sf(some_labels)


  #### function for making the columns -----------------------------------------
                            
  make_column <- function(x0 = 0, y0 = 0, height_of_column = 1, width_of_column) {
    # a default column start at (x0,Y0) = (1,0), has height 1 and width as given
      sf::st_polygon(
      list(
        cbind(
          c(x0, 
            x0 + width_of_column,
            x0 + width_of_column,
            x0,
            x0),
          c(y0,
            y0,
            y0 + height_of_column,
            y0 + height_of_column,
            y0)
        )
      )
    )
  }


  list_inputs <- list(
    some_data$x,
    0,
    some_data$n,
    width_of_columns
    )
  
  
  
  poly_list_columns <- purrr::pmap(
    .l = list_inputs,
    make_column
  )
  
  sf_columns <- sf::st_sf(some_data |> dplyr::select(fill), geometry = poly_list_columns)
  
  sf_columns$fillstyle <- "cross-hatch"
  sf_columns$fillweight <- 0.6
  
  sf_some_labels$size <- 0
  sf_some_labels$label_pos <- "s"


  
  rough_columns <- roughsf::roughsf(
    list(sf_columns, sf_some_labels),
    title = some_title,
    title_font = paste0(size_title,"px"," Pristina"),
    font = paste0(size_label,"px"," Pristina"),
    roughness = 3,
    bowing = 2,
    width = 600,
    height = 300,
  )

  rough_columns

} # end function






# try the function ------------------------------------------------------------


the_data <- tibble::tribble(~label, ~x, ~n, ~fill,
                            "And",  1,   5, "#1b9e77",
                            "Be",  2,   2, "#d95f02",
                            "Cool",  3,   4, "#7570b3",
                            "Duh", 4, 1, "#1b9e77")

the_plot <- plot_sketchy_column(some_data = the_data,
                                width_of_columns = 0.9,
                                some_title = "Sketchy Column Chart",
                                size_title = 50,
                                size_label = 30)

the_plot

#### saving the plot -----------------------------------------------------------
roughsf::save_roughsf(
  rsf = the_plot,
  file = "sketchy_columns.png"
)


