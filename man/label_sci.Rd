% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/label_sci.R
\name{label_sci}
\alias{label_sci}
\title{Add formatted scientific notation labels to ggplot}
\usage{
label_sci(
  digits = 2,
  max_cut = 10^5,
  min_cut = 10^-3,
  common = FALSE,
  factor = NULL,
  trailing = TRUE,
  units = NULL
)
}
\arguments{
\item{digits}{Number of significant figures to display in the converted
output}

\item{max_cut}{Above this number, values will be converted into scientific
format (inclusive)}

\item{min_cut}{Below this number, values will be converted into scientific
format (exclusive)}

\item{common}{Should the formatted numbers share a common exponential factor?}

\item{factor}{Provides a value for the common exponential factor; if \code{NULL},
the most occurring exponent will be used}

\item{trailing}{Should trailing zeros be included in the formatted number?}

\item{units}{If provided, adds units to the converted output}
}
\value{
Labels to use inside a scale_*() function for a ggplot2 object
}
\description{
This function takes the scale breaks as input and uses the
\code{\link{to_scientific}()} function to convert the scale breaks to
formatted scientific notation.
}
\details{
The labels argument of the \code{\link[ggplot2]{ggplot2}}
\link[ggplot2:scale_x_continuous]{scale functions} can accept a character
vector providing the names or a function that takes the breaks as input and
returns the labels as output. The axis breaks cannot be accessed as a named
variable, but they are the provided input if a function is used for the
labels argument.

This setup is based on the
\href{https://github.com/r-lib/scales/blob/master/R/label-scientific.R}{\code{label_scientific()}
function} in the
\href{https://scales.r-lib.org/reference/index.html}{\code{scales} package}.
}
\examples{
library(ggplot2)

df <- data.frame(x = seq(1000, 5000, by = 1000), y = 1:5)

if (requireNamespace("ggplot2", quietly = TRUE)) {
p <- ggplot(df, aes(x, y)) +
    geom_point() +
    scale_x_continuous(labels = label_sci(max_cut = 10))
}

}
