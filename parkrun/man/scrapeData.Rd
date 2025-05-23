% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/parkrunscraper.R
\name{scrapeData}
\alias{scrapeData}
\title{Scrape Data}
\usage{
scrapeData(event, race_number)
}
\arguments{
\item{event}{The event name (usually the Parkrun location. e.g. 'worcester')}

\item{race_number}{The race number (an integer. e.g. 431)}
}
\value{
a dataframe containing the raw scraped data
}
\description{
Scrapes all data for a particular race from the Parkrun website. This is
functional as of May 2025
}
\examples{
data <- scrapeData('worcester', 620);
data <- scrapeData('ludlow', 65);
}
\author{
Sophie Edgar-Andrews (github @sophieed)
}
