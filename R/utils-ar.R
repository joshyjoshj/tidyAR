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
