################################################################################
#'
#'   TODO - List of things I plan to do next
#'
#' - Pull local copy of data first and check whether the run already exists, to
#'   negate the need to scrape it again
#'
#' - Build timeseries
#'
#' - Add more filters
#' - Pull filter functions out so can be used with different plots
#'
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
event <- 'worcester'
race_number <- 654


# PULL ONLY YOUR OWN DATA
your_data <-fetchAllYourData(your_name)
exportData(your_data, your_name) # Save it to your working directory


# PULL ALL DATA FOR A PARTICULAR RACE
data_for_particular_race <- scrapeData(event, race_number) %>%
  processData()


# PLOT YOUR OWN POSITION AGAINST OTHERS OF YOUR SEX
scrapeData(event, race_number) %>%
  processData('Sophie EDGAR-ANDREWS') %>%
  plotPositionByTime('sex')
