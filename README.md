
<!-- README.md is generated from README.Rmd. Please edit that file -->
nameage
-------

### Description

This packages uses the U.S. Social Security Administration's baby names dataset and actuarial tables to estimate the age of an American based on their first name. It uses datasets conveniently collected in the [babynames](http://github.com/hadley/babynames) package and follows the same general format as the [gender](https://github.com/ropensci/gender) package.

The most famous example of using names to estimate age probably comes from [FiveThirtyEight](https://fivethirtyeight.com/features/how-to-tell-someones-age-when-all-you-know-is-her-name/).

### Installation

To install from Github, use the following commands.

``` r
# install.packages("devtools")
devtools::install_github("andland/nameage")
```

### Using the package

The main function is `nameage()` which takes a vector of `names` as the first argument. There are two additional arguments:

-   `base_year`: Calculate the age effective at this year. It defaults to the last year of the SSA data (2015).
-   `age_range`: A range of ages to subset the analysis by. This can be useful if you know, for example, that the person is an adult.

The function returns a data frame with a row for each name it can find. It includes a summary of the age distribution, including the mean, standard deviation, first quartile, median, and third quartile. In addition, it includes the number of people born with the names, as well as an estimate of the number of people still alive at the reference year.

To start off, we will get the age of some names as of 2015. The `names` argument is not case sensitive.

``` r
library(nameage)
names = c("Ava", "liam", "Jack", "ELLA", "gertrude", "elmer", "Violet")

nameage(names, base_year = 2015)
#> # A tibble: 7 × 8
#>       name      n   n_alive      mean        sd    q1 median    q3
#>      <chr>  <int>     <dbl>     <dbl>     <dbl> <dbl>  <dbl> <dbl>
#> 1      Ava 218673 210753.18  8.294741 11.171882     3      6     9
#> 2     ELLA 281604 161998.27 20.663280 26.439171     4      8    17
#> 3    elmer 129647  43057.38 63.093804 24.373373    52     69    82
#> 4 gertrude 177359  20088.78 72.920919 15.176870    65     75    84
#> 5     Jack 670805 435333.58 41.951320 30.124535    11     46    69
#> 6     liam 155843 154870.93  6.179169  6.826197     2      4     9
#> 7   Violet 127793  52927.93 28.742202 32.474662     3      8    63
```

The average age of people with a given name changes depending on the effective year. People named Violet were in general much older in 1990 than they are today.

``` r
nameage(names, base_year = 1990)
#> # A tibble: 7 × 8
#>       name      n    n_alive     mean        sd    q1 median    q3
#>      <chr>  <int>      <dbl>    <dbl>     <dbl> <dbl>  <dbl> <dbl>
#> 1      Ava  16333  12729.379 34.51354 19.184864    22     34    43
#> 2     ELLA 156965  78986.602 52.65791 17.595504    41     55    66
#> 3    elmer 124568  84237.507 57.09422 17.394958    48     62    70
#> 4 gertrude 177020  73446.494 62.88282 13.372109    56     66    72
#> 5     Jack 489076 400256.872 47.94869 18.364396    36     51    62
#> 6     liam   3108   3057.406 10.70788  9.150348     3      8    16
#> 7   Violet  94798  54067.752 56.93661 17.104666    49     62    69
```

Looking at just working adults.

``` r
nameage(names, base_year = 2015, age_range = c(18, 65))
#> # A tibble: 7 × 8
#>       name      n    n_alive     mean        sd    q1 median    q3
#>      <chr>  <int>      <dbl>    <dbl>     <dbl> <dbl>  <dbl> <dbl>
#> 1      Ava  11473  10235.054 43.92543 15.565532    28     48    58
#> 2     ELLA  22364  19379.495 49.26734 14.291413    41     54    61
#> 3    elmer  16250  15008.410 48.20726 13.928635    39     52    60
#> 4 gertrude   5834   4870.340 55.87213  9.379237    52     59    63
#> 5     Jack 156823 145583.034 46.34723 15.093314    34     51    59
#> 6     liam   9808   9630.839 24.58994  9.033423    19     20    27
#> 7   Violet  10251   9039.500 46.37529 14.614003    34     51    59
```

Looking at just people that are not of legal age.

``` r
nameage(names, base_year = 2015, age_range = c(0, 17))
#> # A tibble: 7 × 8
#>       name      n     n_alive     mean       sd    q1 median    q3
#>      <chr>  <int>       <dbl>    <dbl>    <dbl> <dbl>  <dbl> <dbl>
#> 1      Ava 200382 199010.2201 5.960100 3.905668     3      6     9
#> 2     ELLA 122435 121560.9346 6.429290 4.013496     3      6    10
#> 3    elmer   3589   3564.4290 8.998820 4.937470     5      9    13
#> 4 gertrude    265    263.0687 7.232624 5.125877     3      7    11
#> 5     Jack 159808 158750.1411 8.367376 4.944295     4      8    12
#> 6     liam 146030 145236.0101 4.956585 4.494245     1      4     7
#> 7   Violet  31913  31720.2956 4.354899 3.890027     1      3     7
```

### To do

A few things I want to add:

-   Add the ability to subset by gender.
-   Create a plotting function to show the full distribution.
