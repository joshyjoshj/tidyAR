
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tidyAR

<!-- badges: start -->
<!-- badges: end -->

The tidyAR package is a tool for creating wide format dataframes with
columns as predictor variables for various types of Autoregressive (AR)
models, and also includes functions that output formulas suitable for
fitting these models using the ‘lm’ function or other modeling functions
in R.

## Installation

You can install the development version of tidyAR like so:

``` r
devtools::install_github("tidyAR")
```

## Example

This example will show how to create a HAR model for SP500 volatility.
The first steps are to load the packages and calculate the log returns.

``` r

library(tidyverse)
#> -- Attaching packages --------------------------------------- tidyverse 1.3.1 --
#> v ggplot2 3.3.5     v purrr   0.3.4
#> v tibble  3.1.6     v dplyr   1.0.9
#> v tidyr   1.1.4     v stringr 1.4.0
#> v readr   2.1.1     v forcats 0.5.1
#> Warning: package 'dplyr' was built under R version 4.1.3
#> -- Conflicts ------------------------------------------ tidyverse_conflicts() --
#> x dplyr::filter() masks stats::filter()
#> x dplyr::lag()    masks stats::lag()
library(tidyAR)
## Import SP500 return data from astsa() package and rename the columns
## And calculating the log returns
data <- data.frame(as.numeric(astsa::sp500.gr))%>%rename(returns = 1)%>%mutate(log_returns = log(1+returns))
head(data)
#>        returns  log_returns
#> 1 -0.010608477 -0.010665148
#> 2 -0.026592845 -0.026952831
#> 3 -0.001919660 -0.001921505
#> 4  0.003804892  0.003797672
#> 5  0.009540750  0.009495525
#> 6  0.010264892  0.010212565
```

Now using the `har_df()` function the data will be mutated to include
the predictors for a HAR model.

``` r

har_dataframe <- data%>%har_df("log_returns")
head(har_dataframe)
#>        returns  log_returns        daily        weekly      monthly
#> 1  0.042752964  0.041864296 -0.002909589 -0.0090273854 -0.006296269
#> 2 -0.020186047 -0.020392569  0.041864296  0.0002758314 -0.004608020
#> 3  0.008084703  0.008052197 -0.020392569 -0.0059365987 -0.005686401
#> 4  0.026706184  0.026355799  0.008052197 -0.0018022460 -0.004093652
#> 5 -0.002133430 -0.002135709  0.026355799  0.0105940268 -0.000688870
#> 6  0.014991406  0.014880146 -0.002135709  0.0107488029 -0.001486397
#>      quarterly
#> 1 -0.003278361
#> 2 -0.002444560
#> 3 -0.002340429
#> 4 -0.002182116
#> 5 -0.001824051
#> 6 -0.002008673
```

Using the `%>%` (pipe) operator the whole operation can be conveniently
placed into one call.

``` r
head(data.frame(as.numeric(astsa::sp500.gr))%>%rename(returns = 1)%>%
       mutate(log_returns = log(1+returns))%>%har_df("log_returns"))
#>        returns  log_returns        daily        weekly      monthly
#> 1  0.042752964  0.041864296 -0.002909589 -0.0090273854 -0.006296269
#> 2 -0.020186047 -0.020392569  0.041864296  0.0002758314 -0.004608020
#> 3  0.008084703  0.008052197 -0.020392569 -0.0059365987 -0.005686401
#> 4  0.026706184  0.026355799  0.008052197 -0.0018022460 -0.004093652
#> 5 -0.002133430 -0.002135709  0.026355799  0.0105940268 -0.000688870
#> 6  0.014991406  0.014880146 -0.002135709  0.0107488029 -0.001486397
#>      quarterly
#> 1 -0.003278361
#> 2 -0.002444560
#> 3 -0.002340429
#> 4 -0.002182116
#> 5 -0.001824051
#> 6 -0.002008673
```

A further extension of tidyAR is the formula output function. Setting
`formula == TRUE` will output the formula for the model specified in
addition to the data.

``` r
har_list <-data%>%har_df("log_returns",formula = TRUE)
har_list$Formula
#> log_returns ~ daily + weekly + monthly + quarterly
#> <environment: 0x00000000162ba6f8>
```

The formulas can be placed into standard `r` functions such as
`stats::lm()`, `brms::brm()` and `lme4::glmer()`.
