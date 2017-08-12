#' @importFrom utils globalVariables
utils::globalVariables(c("name", "year", "age", "birth_year", "sex", ".", "prop", "weight", "ecdf"))

# saves time by assuming x is sorted and using ecdf
weighted_quantile <- function(x, ecdf, probs) {
  quants = numeric(length(probs))
  for (prob in probs) {
    quants[prob == probs] = x[ecdf >= prob][1]
  }
  quants
}


#' nameage
#'
#' Estimate the age of a person based on their first name.
#'
#' @param names First names as a character vector. Names are case insensitive.
#' @param base_year Year that the age is calculated as of.
#' @param age_range Limit the range of possible ages that the name could come from.
#'   This could be useful if you know, for example, that the name is of an adult.
#'   If missing, all ages will be considered.
#'
#' @return Returns a data frame containing the results of predicting the age.
#'   There will be one row per name found in the \code{babynames} dataset,
#'   sorted in alphabetical order.
#'   They include the following:
#'   \item{name}{The name for which the age has been predicted.}
#'   \item{n}{Number of people born with the name between the age range for
#'   the given reference year}
#'   \item{n_alive}{Estimate of the number of people alive with the name between
#'   the age range for the given reference year}
#'   \item{mean, sd, q1, median, q3}{The mean, standard deviation, first quartile,
#'   median, and third quartile of the age for the names for the given age range and
#'   reference year.}
#' @export
#' @examples
#' # age as of 2015
#' nameage(c("Andrew", "Aleck"), base_year = 2015)
#' # age as of 1990
#' nameage(c("Andrew", "Aleck"), base_year = 1990)
#' # age of adults
#' nameage(c("Andrew", "Aleck"), base_year = 2015, age_range = c(18, 65))
#'
#' @importFrom stats predict
#' @importFrom ranger ranger
# @import babynames
#' @importFrom magrittr %>%
#' @importFrom dplyr mutate select inner_join filter rename group_by summarize ungroup
nameage <- function(names, base_year = 2015, age_range) {
  # TODO:
  # - add gender option
  # - let user choose quantiles, e.g. probs = c(0.25, 0.5, 0.75)

  bn_year_range = range(babynames::babynames$year)

  if (!missing(age_range)) {
    stopifnot(length(age_range) == 2, min(age_range) >= 0)
    stopifnot(min(base_year - age_range) >= bn_year_range[1], max(base_year - age_range) <= bn_year_range[2])
  } else {
    age_range = c(0, Inf)
    stopifnot(base_year >= (bn_year_range[1] + 20), base_year <= (bn_year_range[2] + 5))
  }

  names_df = dplyr::tibble(name = unique(names), name_lower = tolower(unique(names)))
  bn = babynames::babynames %>%
    dplyr::mutate(name_lower = tolower(name)) %>%
    dplyr::select(-name) %>%
    dplyr::inner_join(names_df, by = "name_lower") %>%
    dplyr::mutate(age = base_year - year) %>%
    dplyr::filter(
      age >= min(age_range), age <= max(age_range)
    ) %>%
    dplyr::rename(birth_year = year) %>%
    dplyr::select(birth_year, age, name, sex, n)

  actuarial_test_data = bn %>%
    dplyr::select(birth_year, age, sex) %>%
    unique() %>%
    dplyr::mutate(prop = predict(actuarial_rf_model, .)[["predictions"]])
  stopifnot(min(actuarial_test_data$prop) >= 0, max(actuarial_test_data$prop) <= 1)

  bn = bn %>%
    dplyr::inner_join(actuarial_test_data, by = c("birth_year", "age", "sex"))

  bn = bn %>%
    dplyr::mutate(n_alive = n * prop) %>%
    dplyr::group_by(name, age) %>%
    dplyr::summarize(
      n = sum(n),
      n_alive = sum(n_alive)
    ) %>%
    dplyr::ungroup()

  bn_summ = bn %>%
    dplyr::arrange(name, age) %>%
    dplyr::group_by(name) %>%
    dplyr::mutate(
      weight = n_alive / sum(n_alive),
      ecdf = cumsum(weight)
    ) %>%
    dplyr::summarize(
      n = sum(n),
      n_alive = sum(n_alive),
      mean = sum(age * weight),
      sd = sqrt(sum(weight * (age - mean)^2)),
      q1 = weighted_quantile(age, ecdf, probs = 0.25),
      median = weighted_quantile(age, ecdf, probs = 0.5),
      q3 = weighted_quantile(age, ecdf, probs = 0.75)
      # quantiles = list(weighted_quantile(age, ecdf, probs = probs))
    )

  bn_summ
}
