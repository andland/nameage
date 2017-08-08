#' plot_nameage
#'
#' Plot the distribution of the age for a person based on name.
#'
#' @param names First names as a character vector. Names are case insensitive.
#' @param base_year Year that the age is calculated as of.
#' @param age_range Limit the range of possible ages that the name could come from.
#'   This could be useful if you know, for example, that the name is of an adult.
#'   If missing, all ages will be considered.
#' @param type Whether to plot age or year on the x-axis.
#'
#' @return A ggplot2 object. It will have one facet per unique name.
#' @export
#'
#' @examples
#' plot_nameage("Joseph", type = "age")
#' plot_nameage("Joseph", type = "year")
#'
#' @import ggplot2
plot_nameage <- function(names, base_year = 2015, age_range, type =  c("age", "year")) {
  # TODO:
  # - add gender option

  type = match.arg(type)

  names = unique(names)
  if (length(names) > 12) {
    warning("There are more than 12 names. Only the first 12 will be plotted.")
    names = names[1:12]
  }

  bn_year_range = range(babynames::babynames$year)

  if (!missing(age_range)) {
    stopifnot(length(age_range) == 2, min(age_range) >= 0)
    stopifnot(min(base_year - age_range) >= bn_year_range[1], max(base_year - age_range) <= bn_year_range[2])
  } else {
    age_range = c(0, Inf)
    stopifnot(base_year >= (bn_year_range[1] + 20), base_year <= (bn_year_range[2] + 5))
  }

  names_df = dplyr::tibble(name = names, name_lower = tolower(names))
  bn = babynames::babynames %>%
    mutate(name_lower = tolower(name)) %>%
    select(-name) %>%
    inner_join(names_df, by = "name_lower") %>%
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
    dplyr::group_by(name, birth_year, age) %>%
    dplyr::summarize(
      n = sum(n),
      n_alive = sum(n_alive)
    ) %>%
    dplyr::ungroup() %>%
    dplyr::rename(year = birth_year)

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

  ggplot2::ggplot(bn, ggplot2::aes_string(type)) +
    ggplot2::geom_area(stat = "identity", ggplot2::aes(y = n_alive, fill = "Alive")) +
    ggplot2::geom_line(ggplot2::aes(y = n, color = "Born"), size = 1) +
    ggplot2::facet_wrap(~ name, scales = "free_y") +
    ggplot2::scale_color_manual(values = "black") +
    ggplot2::scale_fill_manual(values = "#008b8b") +
    ggplot2::labs(fill = NULL, color = NULL, y = NULL)

}
