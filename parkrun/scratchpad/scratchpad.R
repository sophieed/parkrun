#' TODO - List of things I plan to do
#'
#' - Calculate speed
#' - Calculate relative positions (e.g out of total runners; out of sex class; out of age-sex class
#' - Create more plots and metrics to visualise data for individual runners (e.g. average speed plots by grouping)
#' - Work out a way to optionally obfuscate names of runners that aren't you (not strictly necessary, but better for data protection
#' - Develop a way to save (obfuscated) processed data locally to negate the need to keep scraping it
#' - Develop time series data (need to find a way to timestamp race numbers)
#'


# RUN THE SCRIPTS

library(parkrun)
library(dplyr)

event <- "worcester"
race_number <- 650

scrapeData(event, race_number) %>%
  processData() %>%
  plotPositionByTime()
