#' @importFrom utils globalVariables
utils::globalVariables(c("name", "year", "age", "birth_year", "sex", ".", "prop", "n_alive", "n"))

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
#' @param alive_geom Choice of whether to plot as an area or bar chart.
#' @param facet_scales Passed to the \code{scales} argument of \code{facet_wrap}.
#' @param fill_color The color that the number alive gets filled in as.
#' @param line_color The color that the number born is colored.
#'
#' @return A \code{ggplot2} object. It will have one facet per unique name.
#' @export
#'
#' @examples
#' plot_nameage(c("Anna", "Joseph"), type = "age")
#' plot_nameage(c("Anna", "Joseph"), type = "year")
#'
#' @importFrom ggplot2 ggplot aes_string geom_area geom_bar geom_line facet_wrap scale_color_manual scale_fill_manual labs
plot_nameage <- function(names, base_year = 2015, age_range, type =  c("age", "year"),
                         alive_geom = c("area", "bar"), facet_scales = c("free_y", "free_x", "free", "fixed"),
                         fill_color = "#008b8b", line_color = "black") {
  # TODO:
  # - add gender option

  type = match.arg(type)
  alive_geom = match.arg(alive_geom)
  facet_scales = match.arg(facet_scales)

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
    dplyr::mutate(age_match = round(pmin(max(actuarial_data_interpolation$age), age))) %>%
    dplyr::left_join(actuarial_data_interpolation, by = c("sex", age_match = "age")) %>%
    dplyr::mutate(
      prop = mapply(function(.x, .y) .x(.y), .x = approx_fun, .y = birth_year)
    ) %>%
    dplyr::select(-age_match)
  stopifnot(!is.na(actuarial_test_data$prop))
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

  fill_year_df = bn %>%
    dplyr::group_by(name) %>%
    dplyr::summarize(
      min_year = min(year),
      max_year = max(year)
    )

  fill_names = rep(fill_year_df$name, fill_year_df$max_year - fill_year_df$min_year + 1)
  fill_years = Reduce(
    c,
    lapply(seq_len(nrow(fill_year_df)), function(x) {
      seq(fill_year_df[x, ]$min_year, fill_year_df[x, ]$max_year)
    }
    )
  )

  fill_year_df = dplyr::tibble(
    name = fill_names,
    year = fill_years
  )

  bn = fill_year_df %>%
    dplyr::left_join(bn, by = c("name", "year")) %>%
    dplyr::mutate(
      age = base_year - year,
      n = ifelse(is.na(n), 0, n),
      n_alive = ifelse(is.na(n_alive), 0, n_alive)
    )

  # bn_summ = bn %>%
  #   dplyr::arrange(name, age) %>%
  #   dplyr::group_by(name) %>%
  #   dplyr::mutate(
  #     weight = n_alive / sum(n_alive),
  #     ecdf = cumsum(weight)
  #   ) %>%
  #   dplyr::summarize(
  #     n = sum(n),
  #     n_alive = sum(n_alive),
  #     mean = sum(age * weight),
  #     sd = sqrt(sum(weight * (age - mean)^2)),
  #     q1 = weighted_quantile(age, ecdf, probs = 0.25),
  #     median = weighted_quantile(age, ecdf, probs = 0.5),
  #     q3 = weighted_quantile(age, ecdf, probs = 0.75)
  #     # quantiles = list(weighted_quantile(age, ecdf, probs = probs))
  #   )

  plt = ggplot2::ggplot(bn, ggplot2::aes_string(type))
  if (alive_geom == "area") {
    plt = plt + ggplot2::geom_area(stat = "identity", ggplot2::aes(y = n_alive, fill = "Alive"))
  } else {
    plt = plt + ggplot2::geom_bar(stat = "identity", ggplot2::aes(y = n_alive, fill = "Alive"))
  }
  plt + ggplot2::geom_line(ggplot2::aes(y = n, color = "Born"), size = 1) +
    ggplot2::facet_wrap(~ name, scales = facet_scales) +
    ggplot2::scale_color_manual(values = line_color) +
    ggplot2::scale_fill_manual(values = fill_color) +
    ggplot2::labs(fill = NULL, color = NULL, y = NULL)

}
