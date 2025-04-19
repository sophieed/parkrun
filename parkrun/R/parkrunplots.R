#' Plot Position by Time
#'
#' Plots the finishing position against completion time
#'
#' @author Sophie Edgar-Andrews (github @sophieed)
#' @param data The data to be plotted. This must be the processed form, not the
#' raw scraped form
#' @param filter_by A way to filter the dataset. Options are currently 'sex' and
#' 'category'
#' @return A plot of the data
#' @import dplyr ggplot2
#' @examples
#' plot <- plotPositionByTime(data);
#' plot <- plotPositionByTime(data, 'sex')
#' plotPositionByTime(data, 'category')
#' @export
plotPositionByTime <- function(data, filter_by = NULL){

  if(!is.null(filter_by) && filter_by == 'sex'){
    data <- data %>% filter(sex == data$sex[!is.na(data$is_you) & data$is_you])
  }

  if(!is.null(filter_by) && filter_by == 'category'){
    data <- data %>% filter(category == data$category[!is.na(data$is_you) & data$is_you])
  }

  p <- ggplot2::ggplot() +
    geom_point(data = data,
               aes(x = absolute_position, y = time, color = sex, alpha = is_you, size = is_you)) +
    labs(x = "Finishing Position", y = "Finishing Time",
         title = "Position by Time") +
    scale_y_time() +
    guides(alpha = "none", size = "none") +
    theme_classic()

  return(p)
}
