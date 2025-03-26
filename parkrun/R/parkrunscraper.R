#' Scrape Data
#'
#' Scrapes data results from the Parkrun website. This is functional as of March 2025
#'
#' @author Sophie Edgar-Andrews (github @sophieed)
#' @param event The event name (usually the Parkrun location)
#' @param race_number The race number
#' @return a data frame containing the scraped data
#' @import dplyr chromote rvest xml2
#' @examples
#' data <- scrapeData('worcester', 620);
#' data <- scrapeData('ludlow', 65);
#' @export
scrapeData <- function(event, race_number) {
  data <- read_html_live(paste0("https://www.parkrun.org.uk/", event, "/results/", race_number, "/")) %>%
    html_elements(".js-ResultsTbody") %>%
    html_table() %>%
    data.frame()

  return(data)
}


#' Process Data
#'
#' Processes the data to transform the scraped information into a useable table.
#' Regular expressions are used to pull out the key data, and any necessary type
#' conversions are performed. Speed and pace are calculated.
#'
#' @author Sophie Edgar-Andrews (github @sophieed)
#' @param data The data that needs processing
#' @param your_name The name of the person you're interested in viewing, if
#' applicable. This must be in the same format as it appears on the website. As
#' of March 2025, that format is 'Firstname LASTNAME'
#' @return a data frame containing the processed data ready for analysis
#' @import dplyr lubridate stringr
#' @examples
#' data <- processData(data, 'John SMITH');
#' data <- processData(data)
#' @export
processData <- function(data, your_name = NULL) {
  processed <- data %>%
    rowwise() %>%
    mutate(absolute_position = X1,
           name = str_extract(X2, "^.*?(?=[0-9])"),
           number_of_races = as.numeric(str_extract(X2, "([0-9]+)")),
           sex = str_trim(str_extract(X2, "(?<=\n)(.*)")),
           time = ms(str_extract(X6, "([0-9]+):([0-9]+)")),
           category = str_extract(X4, "[A-Z]{2}[0-9]{2}-[0-9]{2}"),
           age_grading = as.numeric(str_extract(X4, "[0-9]{2}.[0-9]{2}(?=%)"))/100,
           position_by_sex = as.numeric(str_extract(X3, "[0-9]+(?=/)")),
           sex_total = as.numeric(str_extract(X3, "(?<=/)[0-9]+")),
           club = X5,
           is_you = ifelse(is.null(your_name), FALSE, your_name == name)) %>%
    select(-c(X1, X2, X3, X4, X5, X6)) %>% # remove raw columns
    mutate(speed = (5/time_length(time,"minute"))*60,
           pace = time_length(time,"minute")/5)

  return(processed)
}


#' Plot Position by Time
#'
#' Plots the finishing position against completion time
#'
#' @author Sophie Edgar-Andrews (github @sophieed)
#' @param data The data to be plotted. This must be the processed form, not the
#' raw scraped form
#' @param filter_by A way to filter the dataset. Options are currently 'sex'
#' @return A plot of the data
#' @import dplyr ggplot2
#' @examples
#' plot <- plotPositionByTime(data);
#' plot <- plotPositionByTime(data, 'sex')
#' @export
plotPositionByTime <- function(data, filter_by = NULL){

  if(!is.null(filter_by) && filter_by == 'sex'){
    data <- data %>% filter(sex == data$sex[!is.na(data$is_you) & data$is_you])
  }

  p <- ggplot2::ggplot() +
    geom_point(data = data,
               aes(x = time, y = absolute_position, color = sex, alpha = is_you, size = is_you)) +
    labs(x = "Finish Time", y = "Finishing Position",
         title = "Position by Time") +
    scale_x_time() +
    guides(alpha = "none", size = "none") +
    theme_classic()

  return(p)
}
