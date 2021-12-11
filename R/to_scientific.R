#' Convert numbers into formatted scientific notation expressions
#'
#' This function converts a vector of numbers to formatted scientific notation
#' expressions. It is called by \code{\link{label_scientific}()} to convert the
#' \code{\link[ggplot2]{ggplot2}} scale function labels to scientific format.
#'
#' @param x Numeric vector, gives numbers to convert to scientific notation
#' @param digits Number of significant figures to display in the converted
#'   output
#' @param max_cut Above this number, values will be converted into scientific
#'   format (inclusive)
#' @param min_cut Below this number, values will be converted into scientific
#'   format (exclusive)
#' @param common Should the formatted numbers share a common exponential factor?
#' @param factor Provides a value for the common exponential factor; if `NULL`,
#'   the most occurring exponent will be used
#' @param trailing Should trailing zeros be included in the formatted number?
#' @param units If provided, adds units to the converted output
#'
#' @return An expression containing the input numbers in scientific format
#' @export
#'
#' @examples
#' a <- c(NA, 10657, 0.00187, 0.0005, 102, 0)
#' to_scientific(a)

to_scientific <- function(x,
                          digits = 2,
                          max_cut = 10^5,
                          min_cut = 10^-3,
                          common = FALSE,
                          factor = NULL,
                          trailing = TRUE,
                          units = NULL) {

  # Convert input to consistent number format
  x <- as.numeric(as.character(x))

  # Fix NA values
  if (any(is.na(x))) {

    # To fix NAs in unspecified positions, find location and remove
    x_na <- x # Store original input for recovery later
    x <- x[!is.na(x)] # Remove NA values
  }

  # Round all numbers to specified number of digits (not scientific format)
  x <- signif(x, digits = digits)

  # Find indices for plain and scientific format numbers
  sci_idx <- which(abs(x) >= max_cut | abs(x) < min_cut)
  plain_idx <- which(abs(x) < max_cut & abs(x) >= min_cut)

  # Select numbers outside of range and convert numbers into characters
  # in consistent scientific format
  # formatC converts to 0.00e+00 format; digits argument gives digits after
  # decimal
  x[sci_idx] <- formatC(x[sci_idx], format = "e", digits = digits - 1)

  # Select numbers inside of range and convert numbers into characters with
  # correct number of digits; remove trailing decimal point
  x[plain_idx] <- formatC(
    as.numeric(x[plain_idx]),
    digits = digits,
    format = "fg",
    flag = "#"
  )
  x[plain_idx] <- gsub(pattern = "\\.$", replacement = "", x[plain_idx])

  # If all of the numbers should have a common exponential factor, find most
  # common exponential factor and apply it to all scientific format numbers
  if (common) {

    # Find all exponent values: match pattern of single character and any
    # numbers after e; keep just the single character (sign) and numbers,
    # convert to numeric
    exponents <- as.numeric(gsub(
      pattern = ".*e(.{1}[0-9]+)",
      replacement = "\\1",
      x[sci_idx]
    ))

    # If exponent is given, use it; otherwise, find the most common number
    if (is.numeric(factor)) {
      most <- factor
    } else {
      # Find the mode of the exponent values
      ux <- unique(exponents)
      tab <- tabulate(match(exponents, ux))
      most <- ux[tab == max(tab)]

      # If there are multiple modes, take the maximum one for common exponent
      if (length(most) > 1) {
        most <- max(most)
      }
    }

    # Difference between exponent and common exponent, used as multiplication
    # factor
    diff <- exponents - most

    # Find all significand values; match pattern of all numbers before e; keep
    # the numbers, convert to numeric
    significands <- as.numeric(gsub(
      pattern = "(.*)e.*",
      replacement = "\\1",
      x[sci_idx]
    ))

    # Scale significands appropriately for common exponent
    significands <- significands * 10^diff

    # Format significands to correct number of digits after decimal point and
    # remove trailing decimal point
    significands <- formatC(
      significands,
      digits = digits - 1,
      format = "f",
      flag = "#"
    )
    significands <- gsub(pattern = "\\.$", replacement = "", significands)

    # Convert exponent to formatted text string for combining with significands
    most <- formatC(
      most,
      digits = ifelse(nchar(abs(most)) == 1, 2, nchar(abs(most))),
      flag = "+0"
    )

    # Combine significands, e, and exponents to form scientific notation
    x[sci_idx] <- paste0(significands, "e", most)
  }

  # Replace scientific format zeros with plain zeros
  pattern <- paste(rep(0, digits - 1), sep = "", collapse = "")
  pattern <- paste0("^0.", pattern, "e\\+[0-9]*$") # Makes pattern to find 0
  x <- gsub(pattern = pattern, replacement = "0", x)

  # Convert scientific notation into a math expression
  # First, wrap the significand in quotes to preserve trailing zeros
  if (trailing) {
    # Match pattern of any characters at the start of the string prior to e;
    # replace with the matched characters wrapped in quotes followed by e
    x <- gsub(pattern = "(^.*)e", replacement = "'\\1'e", x)

    # For plain numbers, wrap entire number in additional quotes
    x[plain_idx] <- gsub(pattern = "(.*)", replacement = "'\\1'", x[plain_idx])
  }

  # Next, replace the "e+00" notation with math expression for "x 10^0"
  # Match pattern of e + or - 0 (one or zero 0s); replace with x 10^+ or -
  x <- gsub(pattern = "e\\+0?", replacement = " %*% 10^", x)
  x <- gsub(pattern = "e\\-0?", replacement = " %*% 10^-", x)

  # Add units if given; tilde means space in math expression
  if (is.character(units)) {
    x <- paste0(x, "~", units)
  }

  # If the original vector had any NA values, put them back in the same
  # locations
  if (exists("x_na")) {
    x_na[!is.na(x_na)] <- x # Find values that are not NA, place x values there
    x <- x_na
  }

  # Convert text into expression format
  x <- parse(text = x)
  x
}
