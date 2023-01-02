#' Create a list of quosures.
#'
#' This function creates a list of n quosures containing the dplyr formula for creating lags. This can be passed into [dplyr::mutate()] to create new \code{data.frame} columns.
#'
#' @importFrom magrittr %>%
#' @param var Name of the variable that is to be lagged.
#' @param var Number of lags.
#' @returns A named list of quosures.
#' @noRd




lags <- function(var, n) {
  var <- as.name(var)
  var <- rlang::enquo(var)

  indices <- seq_len(n)
  purrr::map(indices, ~ rlang::quo(dplyr::lag(!!var, !!.x))) %>%
    rlang::set_names(sprintf("lag_%s_%02d", rlang::as_label(var), indices))
}


#' Mean of a list of columns
#'
#' This function takes a list of column names and calculates the mean of these columns across rows
#'
#'@param cols A character list of column names
#'@param na.rm Boolean: True (Defalcate) removes missing values from calculation
#'
#'


col_mean <- function(cols, na.rm = TRUE) {
  rowMeans(dplyr::across(tidyselect::all_of(cols)), na.rm = na.rm)
}





