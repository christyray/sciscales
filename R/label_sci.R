#' Add formatted scientific notation labels to ggplot
#'
#' This function takes the scale breaks as input and uses the
#' \code{\link{to_scientific}()} function to convert the scale breaks to
#' formatted scientific notation.
#'
#' The labels argument of the \code{\link[ggplot2]{ggplot2}}
#' \link[ggplot2:scale_x_continuous]{scale functions} can accept a character
#' vector providing the names or a function that takes the breaks as input and
#' returns the labels as output. The axis breaks cannot be accessed as a named
#' variable, but they are the provided input if a function is used for the
#' labels argument.
#'
#' This setup is based on the
#' \href{https://github.com/r-lib/scales/blob/master/R/label-scientific.R}{`label_scientific()`
#' function} in the
#' \href{https://scales.r-lib.org/reference/index.html}{`scales` package}.
#'
#' @inheritParams to_scientific
#'
#' @return Labels to use inside a scale_*() function for a ggplot2 object
#' @export
#'
#' @examples
#' library(ggplot2)
#'
#' df <- data.frame(x = seq(1000, 5000, by = 1000), y = 1:5)
#'
#' if (requireNamespace("ggplot2", quietly = TRUE)) {
#' p <- ggplot(df, aes(x, y)) +
#'     geom_point() +
#'     scale_x_continuous(labels = label_scientific(max_cut = 10))
#' }
#'
label_sci <- function(digits = 2,
                      max_cut = 10^5,
                      min_cut = 10^-3,
                      common = FALSE,
                      factor = NULL,
                      trailing = TRUE,
                      units = NULL) {

  # Defines a new function that takes x as input, but x was not input into the
  # function or defined inside the function. When this occurs, R looks one level
  # up for the value, so it will find the breaks provided by the ggplot scale
  # function and set those to x. Then it will call to_scientific() with the
  # provided input for x
  function(x) {
    to_scientific(
      x,
      digits = digits,
      max_cut = max_cut,
      min_cut = min_cut,
      common = common,
      factor = factor,
      trailing = trailing,
      units = units
    )
  }
}
