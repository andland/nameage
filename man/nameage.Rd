% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/nameage.R
\name{nameage}
\alias{nameage}
\title{nameage}
\usage{
nameage(names, base_year = 2015, age_range)
}
\arguments{
\item{names}{First names as a character vector. Names are case insensitive.}

\item{base_year}{Year that the age is calculated as of.}

\item{age_range}{Limit the range of possible ages that the name could come from.
This could be useful if you know, for example, that the name is of an adult.
If missing, all ages will be considered.}
}
\value{
Returns a data frame containing the results of predicting the age.
  There will be one row per name found in the \code{babynames} dataset,
  sorted in alphabetical order.
  They include the following:
  \item{name}{The name for which the age has been predicted.}
  \item{n}{Number of people born with the name between the age range for
  the given reference year}
  \item{n_alive}{Estimate of the number of people alive with the name between
  the age range for the given reference year}
  \item{mean, sd, q1, median, q3}{The mean, standard deviation, first quartile,
  median, and third quartile of the age for the names for the given age range and
  reference year.}
}
\description{
Estimate the age of a person based on their first name.
}
\examples{
# age as of 2015
nameage(c("Andrew", "Aleck"), base_year = 2015)
# age as of 1990
nameage(c("Andrew", "Aleck"), base_year = 1990)
# age of adults
nameage(c("Andrew", "Aleck"), base_year = 2015, age_range = c(18, 65))

}

