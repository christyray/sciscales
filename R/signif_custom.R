#' Rounding of numbers to significant digits with options
#'
#' A combination of the the \code{\link[base]{signif}()} and
#' \code{\link[base]{ceiling}()}/\code{\link[base]{floor}()} functions. It
#' allows numbers to be rounded to a provided number of significant digits, but
#' to specifically have \code{\link[base]{ceiling}()} or
#' \code{\link[base]{floor}()} applied for the rounding.
#'
#' @param x Numeric vector to be rounded to set significant figures
#' @param digits Number of significant figures to round to
#' @param option Specific rounding function to apply; options are `ceiling`,
#'   `floor`, `trunc`, or `round`
#'
#' @return Numeric vector of rounded numbers
#' @export
#'
#' @examples
#' signif_custom(1014, digits = 2)
#' signif_custom(67362, digits = 3, option = floor)

signif_custom <- function(x, digits = 1, option = ceiling) {

  # Convert input to consistent number format
  sci <- formatC(x, format = "e", digits = digits)

  # Isolate the specific number representing the exponent
  # Match pattern of single character and any numbers after e; keep just the
  # single character (sign) and numbers, convert to numeric
  exponent <- as.numeric(gsub(
    pattern = ".*e(.{1}[0-9]+)",
    replacement = "\\1",
    sci
  ))

  # Isolate the specific number representing the significand
  # Match pattern of all numbers before e; keep the numbers, convert to numeric
  significand <- gsub(pattern = "([0-9]*)e.*", replacement = "\\1", sci)

  # Calculate the multiple that should be rounded to
  place <- 1 / (10 ^ (digits - 1))

  # Used the specified function to round the significand to the given
  # number of digits
  x <- option(as.numeric(significand) / place) * place

  # Multiply by the original exponent
  x <- x * 10 ^ (as.numeric(exponent))
  x
}
