% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/parkrunscraper.R
\name{scrapeData}
\alias{scrapeData}
\title{Scrape Data}
\usage{
scrapeData(event, race_number)
}
\arguments{
\item{event}{The event name (usually the Parkrun location)}

\item{race_number}{The race number}
}
\value{
a data frame containing the scraped data
}
\description{
Scrapes data results from the Parkrun website. This is functional as of March 2025
}
\examples{
data <- scrapeData('worcester', 620);
data <- scrapeData('ludlow', 65);
}
\author{
Sophie Edgar-Andrews (github @sophieed)
}
