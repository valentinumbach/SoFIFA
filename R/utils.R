#' @importFrom magrittr %>%
NULL

#' @importFrom utils head
NULL

is_error <- function(x) {
  "try-error" %in% class(x)
}
