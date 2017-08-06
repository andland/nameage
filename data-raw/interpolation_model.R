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

devtools::use_data(actuarial_rf_model, internal = TRUE, overwrite = TRUE)
