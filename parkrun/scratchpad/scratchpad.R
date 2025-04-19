################################################################################
#'
#'   TODO - List of things I plan to do next
#'
#' - Develop a way to save your own processed data locally to negate the need to
#'   keep scraping it
#'   Efficiency: check whether that run already exists in your saved data before
#'   trying to re-scrape it.
#'
#' - Add more filters
#' - Build timeseries
#' - Pull filter functions out so can be used with different plots
#' - Calculate relative positions (e.g out of total runners; out of sex class;
#'   out of age-sex class
#'
#' - Work on the README documentation for this package
#'
#'
################################################################################


# Import packages
library(parkrun)
library(tidyverse)


# Define any global variables
your_name = 'Sophie EDGAR-ANDREWS'


# PULL ONLY YOUR OWN DATA
your_data <-fetchAllYourData(your_name)


# PULL ALL DATA FOR A PARTICULAR RACE
data_for_particular_race <- scrapeData(event, race_number) %>%
  processData()


# PLOT YOUR OWN POSITION AGAINST OTHERS OF YOUR SEX
event <- 'worcester'
race_number <- 654

scrapeData(event, race_number) %>%
  processData('Sophie EDGAR-ANDREWS') %>%
  plotPositionByTime('sex')
