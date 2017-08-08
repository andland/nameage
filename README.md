
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
#> 1      Ava 218673 210756.22  8.295168 11.173480     3      6     9
#> 2     ELLA 281604 162030.93 20.675174 26.450605     4      8    17
#> 3    elmer 129647  43060.31 63.094983 24.373220    52     69    82
#> 4 gertrude 177359  20118.93 72.937538 15.173509    65     75    84
#> 5     Jack 670805 435342.78 41.952064 30.124809    11     46    69
#> 6     liam 155843 154871.52  6.179128  6.826207     2      4     9
#> 7   Violet 127793  52952.24 28.766640 32.488454     3      8    63
```

The average age of people with a given name changes depending on the effective year. People named Violet were in general much older in 1990 than they are today.

``` r
nameage(names, base_year = 1990)
#> # A tibble: 7 × 8
#>       name      n    n_alive     mean        sd    q1 median    q3
#>      <chr>  <int>      <dbl>    <dbl>     <dbl> <dbl>  <dbl> <dbl>
#> 1      Ava  16333  12731.433 34.51864 19.188965    22     34    43
#> 2     ELLA 156965  79019.361 52.66651 17.598272    41     55    66
#> 3    elmer 124568  84292.715 57.10297 17.392310    48     62    70
#> 4 gertrude 177020  73505.317 62.89247 13.372459    56     66    72
#> 5     Jack 489076 400380.078 47.95604 18.365936    36     51    62
#> 6     liam   3108   3057.442 10.70789  9.150351     3      8    16
#> 7   Violet  94798  54096.083 56.94518 17.105129    49     62    69
```

Looking at just working adults.

``` r
nameage(names, base_year = 2015, age_range = c(18, 65))
#> # A tibble: 7 × 8
#>       name      n    n_alive     mean        sd    q1 median    q3
#>      <chr>  <int>      <dbl>    <dbl>     <dbl> <dbl>  <dbl> <dbl>
#> 1      Ava  11473  10234.765 43.92403 15.564642    28     48    58
#> 2     ELLA  22364  19378.151 49.26520 14.290764    41     54    61
#> 3    elmer  16250  15009.057 48.20744 13.928359    39     52    60
#> 4 gertrude   5834   4869.456 55.86964  9.379266    52     59    63
#> 5     Jack 156823 145589.329 46.34761 15.093047    34     51    59
#> 6     liam   9808   9630.748 24.59016  9.033471    19     20    27
#> 7   Violet  10251   9038.958 46.37338 14.613091    34     51    59
```

I also created a function to plot the distribution of the ages for each name. It takes one additional parameter which tells whether to plot by age...

``` r
plot_nameage(c("Joseph", "Anna"), type = "age")
```

![](README-unnamed-chunk-6-1.png)

or by year.

``` r
plot_nameage(c("Joseph", "Anna"), type = "year")
```

![](README-unnamed-chunk-7-1.png)

### To do

-   Add the ability to subset by gender.
