#' Create HAR model data.frame
#'
#' `har_df()` Creates new columns from a data-frame or creates a data-frame which contain the predictor variables for an Heterogenous Autoregressive model with standard time lags of
#' 1 (Daily), 5 (Weekly), 21 (Monthly) and 63 (Quarterly).
#'  In addition a formula object can be returned which can be used in standard fit functions such as: [stats::lm()], [lme4::glmer()] and [brms::brm()].
#' @param data A \code{data.frame} or something coercible to one.
#' @param y If `data` is a \code{data.frame} then this is the character name of the column of the output variable. This does not need to be specified for other types of input.
#' @param sort If `data` is a \code{data.frame} then this is the character name of the column by which to order the data using [dplyr::arrange()].
#' This does not need to be specified for other types of input.
#' @param formula A boolean:
#'   * `TRUE`: In addition to the \code{data.frame}, a formula object will be returned with containing the specified model formula.
#'   * `FALSE` (the default): Just \code{data.frame} returned.
#' @param na.rm A boolean:
#'   * `TRUE` (the default): Removes missing values from the \code{data.frame} using [tidyr::drop_na()].
#'   * `FALSE`: Missing values are returned in \code{data.frame}.
#' @return A \code{data.frame} or \code{list}.
#' @export
#'
har_df <- function(data, y = NULL, sort = NULL, formula = FALSE, na.rm = TRUE) {
  # Creating Data.frame
  dataframe <- as.data.frame(data)

  # Arranging if specified
  if (is.null(sort) == FALSE) {
    dataframe <- dataframe %>% dplyr::arrange(sort)
  }

  # Finding the target
  ifelse(
    {
      is.null(y)
    },
    {
      target <- colnames(dataframe)[1]
    },
    {
      target <- y
    }
  )

  # Checking Target exists within dataframe
  if (target %in% colnames(dataframe) == FALSE) {
    stop("The y value does not exist in the dataframe")
  }

  # Creating the lag functions
  func <- lags(target, 63)

  # Mutating the dataframe
  dataframe <- dataframe %>%
    dplyr::mutate(!!!func) %>%
    dplyr::mutate(
      weekly := !!rlang::parse_expr(paste0(names(func)[1:5], collapse = "+")),
      monthly := !!rlang::parse_expr(paste0(names(func)[1:21], collapse = "+")),
      quarterly := !!rlang::parse_expr(paste0(names(func), collapse = "+"))
    ) %>%
    dplyr::mutate(weekly = 1 / 5 * weekly, monthly = 1 / 21 * monthly, quarterly = 1 / 63 * quarterly) %>%
    dplyr::select(!!!rlang::parse_exprs(paste("-", names(func)[2:63]))) %>%
    dplyr::rename(daily = paste("lag_", "_01", sep = target))

  # NA Dropping
  if (na.rm == TRUE) {
    dataframe <- dataframe %>% tidyr::drop_na()
  }

  # Formula
  if (formula == TRUE) {
    fmla <- formula(paste(paste(target, "~"), paste(c("daily", "weekly", "monthly", "quarterly"), collapse = "+")))
  }

  # Returns

  ifelse(
    {
      formula == TRUE
    },
    {
      out <- list(dataframe, fmla) %>% rlang::set_names(c("Data", "Formula"))
    },
    {
      out <- dataframe
    }
  )

  out
}
