#' Scrape Data
#'
#' Scrapes all data for a particular race from the Parkrun website. This is
#' functional as of March 2025
#'
#' @author Sophie Edgar-Andrews (github @sophieed)
#' @param event The event name (usually the Parkrun location. e.g. 'worcester')
#' @param race_number The race number (an integer. e.g. 431)
#' @return a dataframe containing the raw scraped data
#' @import dplyr chromote rvest xml2
#' @examples
#' data <- scrapeData('worcester', 620);
#' data <- scrapeData('ludlow', 65);
#' @export
scrapeData <- function(event, race_number) {
  data <- read_html_live(paste0("https://www.parkrun.org.uk/", event, "/results/", race_number, "/")) %>%
    html_elements(".js-ResultsTbody") %>%
    html_table() %>%
    data.frame() %>%
    mutate(date = scrapeRaceDate(event, race_number))

  return(data)
}


#' Scrape Race Date
#'
#' Scrapes the date that a particular race took place
#'
#' @author Sophie Edgar-Andrews (github @sophieed)
#' @param event The event name (usually the Parkrun location. e.g. 'worcester')
#' @param race_number The race number (an integer. e.g. 431)
#' @return the date of the race
#' @import dplyr chromote rvest xml2
#' @examples
#' date <- scrapeRaceDate('worcester', 620);
#' date <- scrapeRaceDate('ludlow', 65);
#' @export
scrapeRaceDate <- function(event, race_number){

  date <- read_html_live(paste0("https://www.parkrun.org.uk/", event, "/results/", race_number, "/")) %>%
    html_element("h3") %>%
    html_text() %>%
    str_extract("\\d{1,2}\\/\\d{1,2}\\/\\d{2,4}")

  return(as.Date(date, "%d/%m/%Y"))
}


#' Process Data
#'
#' Processes the data to transform the scraped information into a useable format.
#' Regular expressions are used to pull out the key data, and any necessary type
#' conversions are performed. Speed and pace are calculated.
#'
#' @author Sophie Edgar-Andrews (github @sophieed)
#' @param data The data that needs processing
#' @param your_name The name of the person you're interested in viewing, if
#' applicable. This must be in the same format as it appears on the website. As
#' of March 2025, that format is 'Firstname LASTNAME'
#' @return a data frame containing the processed data ready for analysis
#' @import dplyr stringr
#' @importFrom hms hms
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
           time = str_extract(X6, "([0-9]):([0-9]+):([0-9]+)|([0-9]+):([0-9]+)"),
           category = str_extract(X4, "[A-Z]{2}[0-9]{2}-[0-9]{2}"),
           age_grading = as.numeric(str_extract(X4, "[0-9]{2}.[0-9]{2}(?=%)"))/100,
           position_by_sex = as.numeric(str_extract(X3, "[0-9]+(?=/)")),
           sex_total = as.numeric(str_extract(X3, "(?<=/)[0-9]+")),
           club = X5,
           is_you = ifelse(is.null(your_name), FALSE, your_name == name)) %>%
    select(-c(X1, X2, X3, X4, X5, X6))# %>% # remove raw columns

  # Process times
  processed <- processed %>%
    mutate(time = ifelse(str_detect(time, "([0-9]):([0-9]+):([0-9]+)"),
                         time,
                         paste0('0:',time)),
           time = parse_hms(time),
           speed = (5/time_length(time,"minute"))*60,
           pace = time_length(time,"minute")/5)

  return(processed)
}


#' Fetch Race Data for Individual
#'
#' Helper function to scrape data from the Parkrun website for a particular race
#' and individual. Saves the scraped line to a file.
#'
#' @author Sophie Edgar-Andrews (github @sophieed)
#' @param location The Parkrun location. Usually the location (e.g. 'ludlow')
#' @param race_number The race number. An integer (e.g. 243)
#' @param your_name The name of the person you're interested in viewing. This
#' must be in the same format as it appears on the website. As #' of March 2025,
#' that format is 'Firstname LASTNAME'
#' @return the data for that individual
#' @import dplyr
#' @examples
#' data <- fetchRaceDataForIndividual('worcester', 431, 'John SMITH');
#' @export
fetchRaceDataForIndividual <- function(location, race_number, your_name){
  data <- scrapeData(location, race_number) %>%
    processData(your_name) %>%
    filter(is_you) %>%
    mutate(location = location,
           race_number = race_number)

  if(exists('your_data') && is.data.frame(get('your_data'))){
    your_data <- rbind(your_data, data)
  } else {
    your_data <- data
  }

  return(your_data)
}


#' Fetch All of Your Data
#'
#' Function to pull all data for an individual. Requires a csv file in the
#' data/imported_data' folder containing a list of all races for a location. The
#' file name should be the location name, matching the formatting on the Parkrun
#' website (e.g. 'worcester.csv'). Each run number should be on a new line.
#'
#' @author Sophie Edgar-Andrews (github @sophieed)
#' @param your_name The name of the person you're interested in viewing. This
#' must be in the same format as it appears on the website. As #' of March 2025,
#' that format is 'Firstname LASTNAME'
#' @return all data for the listed runs associated with that individual
#' @import dplyr
#' @importFrom tidytable map_df
#' @examples
#' data <- fetchAllYourData('John SMITH');
#' @export
fetchAllYourData <- function(your_name){

  your_runs <- list.files("./data/imported_data", pattern="*.csv", full.names=TRUE) %>%
    tidytable::map_df(~read_csv(., col_names = 'race_number', col_types = 'i', id = 'location')) %>%
    mutate(location = str_remove(basename(location), ".csv"))

  data <- as.data.frame(t(mapply(fetchRaceDataForIndividual,
                                 your_runs$location,
                                 your_runs$race_number,
                                 your_name)))

  rownames(data) <- NULL

  return(data)
}
