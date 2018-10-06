library(tidyverse)
library(babynames)

actuarial_data = babynames::lifetables %>%
  mutate(prop = lx / 100000) %>%
  rename(
    age = x,
    birth_year = year
  ) %>%
  select(sex, birth_year, age, prop)

library(ranger)
set.seed(42)
actuarial_rf_model = ranger::ranger(prop ~ ., data = actuarial_data, num.trees = 500, replace = FALSE, mtry = 3)

# works assuming age is between 0 and 119 (whole numbers)
actuarial_data_aug = actuarial_data %>%
  bind_rows(
    actuarial_data %>%
      distinct(sex, birth_year) %>%
      mutate(
        age = max(actuarial_data$age) + 1,
        prop = 0
      )
  )

actuarial_data_interpolation = actuarial_data_aug %>%
  mutate(
    sex = as.character(sex)
  ) %>%
  group_by(sex, age) %>%
  summarize(
    approx_fun = list(approxfun(birth_year, prop, rule = 2))
  ) %>%
  ungroup()

devtools::use_data(actuarial_data_interpolation, internal = TRUE, overwrite = TRUE)

pred_df = expand.grid(
  birth_year = min(actuarial_data$birth_year):2018,
  sex = unique(actuarial_data$sex),
  age = c(18, 50, 75)
) %>% tbl_df() %>%
  mutate(
    random_forest = predict(actuarial_rf_model, .)$predictions
  ) %>%
  left_join(actuarial_data_interpolation, by = c("sex", "age")) %>%
  mutate(
    interpolation1 = map2_dbl(approx_fun, birth_year, ~.x(.y)),
    interpolation2 = mapply(function(.x, .y) .x(.y), .x = approx_fun, .y = birth_year)
  )

pred_df %>%
  select(-approx_fun) %>%
  gather(type, prop, random_forest, interpolation1, interpolation2) %>%
  ggplot(aes(birth_year, prop, color = type)) +
  geom_line() +
  facet_grid(sex ~ age)
