
<!-- README.md is generated from README.Rmd. Please edit that file -->
nameage
-------

### Description

This packages uses the U.S. Social Security Administration's baby names dataset and actuarial tables to estimate the age of an American based on their first name. It uses datasets conveniently collected in the [babynames](http://github.com/hadley/babynames) package and follows the same general format as the [gender](https://github.com/ropensci/gender) package.

### Installation

To install from Github, use the following commands.

``` r
# install.packages("devtools")
devtools::install_github("andland/nameage")
```

### Using the package

The main function is `nameage()` which takes a vector of names as the first argument. There are two additional arguments:

-   `base_year`: Calculate the age effective at this year. It defaults to the last year of the SSA data (2015).
-   `age_range`: A range of ages to subset the analysis by. This can be useful if you know, for example, that the person is an adult.

The function returns a data frame with a row for each name it can find. It includes a summary of the age distribution, including the mean, standard deviation, first quartile, median, and third quartile. In addition, it includes the number of people born with the names, as well as an estimate of the number of people still alive at the reference year.

To start off, we will get the age of some names as of 2015. The `name` argument is not case sensitive.

``` r
library(nameage)
names = c("Andrew", "andy", "DREW", "Aleck", "alec", "ALEX")

nameage(names, base_year = 2015)
#> # A tibble: 6 × 8
#>     name       n      n_alive     mean       sd    q1 median    q3
#>    <chr>   <int>        <dbl>    <dbl>    <dbl> <dbl>  <dbl> <dbl>
#> 1   alec   51236   49267.4685 18.81676 11.64257    13     18    22
#> 2  Aleck    1100     698.3757 23.34816 25.05095     7     14    24
#> 3   ALEX  272855  243652.9640 23.72513 17.77180    12     20    29
#> 4 Andrew 1270972 1146680.3858 28.76860 17.70667    16     26    38
#> 5   andy   87465   77156.5696 30.69923 21.39837    12     27    49
#> 6   DREW   79177   76575.6488 23.07689 15.72099    11     20    30
```

The average age of people with a given name changes depending on the effective year. People named Aleck were in general much older in 1990 than they are today.

``` r
nameage(names, base_year = 1990)
#> # A tibble: 6 × 8
#>     name      n    n_alive     mean       sd    q1 median    q3
#>    <chr>  <int>      <dbl>    <dbl>    <dbl> <dbl>  <dbl> <dbl>
#> 1   alec   8498   7796.208 19.23637 21.52090     2      9    30
#> 2  Aleck    567    397.408 54.88680 22.25067    41     65    71
#> 3   ALEX 116854 104061.394 22.89748 23.24943     3     14    37
#> 4 Andrew 755541 700090.808 19.38415 19.35372     5     12    28
#> 5   andy  50529  45929.581 26.85732 18.48474    13     25    35
#> 6   DREW  32614  31616.782 14.24753 14.32227     4      8    24
```

Looking at just working adults.

``` r
nameage(names, base_year = 2015, age_range = c(18, 65))
#> # A tibble: 6 × 8
#>     name      n    n_alive     mean        sd    q1 median    q3
#>    <chr>  <int>      <dbl>    <dbl>     <dbl> <dbl>  <dbl> <dbl>
#> 1   alec  25436  24953.882 24.43011  9.006311    19     21    25
#> 2  Aleck    210    202.564 30.94715 14.941172    20     23    38
#> 3   ALEX 134490 130629.226 30.43399 11.736454    22     26    35
#> 4 Andrew 805131 778271.095 33.70660 11.848651    25     30    41
#> 5   andy  46309  44068.655 39.91016 13.461351    28     40    52
#> 6   DREW  45372  43978.513 31.50230 11.938214    22     28    36
```

Looking at just people that are not of legal age.

``` r
nameage(names, base_year = 2015, age_range = c(0, 17))
#> # A tibble: 6 × 8
#>     name      n     n_alive      mean       sd    q1 median    q3
#>    <chr>  <int>       <dbl>     <dbl>    <dbl> <dbl>  <dbl> <dbl>
#> 1   alec  23895  23713.1002 11.463555 4.963408     8     13    16
#> 2  Aleck    419    416.1988  8.506827 5.070711     4      9    13
#> 3   ALEX 103253 102517.1411  9.717361 4.868862     6     10    14
#> 4 Andrew 323304 320999.4471  9.838054 4.932512     6     10    14
#> 5   andy  28550  28354.2261  8.992259 4.895511     5      9    13
#> 6   DREW  31606  31379.7419  9.399166 5.030058     5     10    14
```

### To do

A few things I want to add:

-   Add the ability to subset by gender.
-   Create a plotting function to show the full distribution.
