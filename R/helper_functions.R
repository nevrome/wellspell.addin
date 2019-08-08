#' check_if_packages_are_available
#'
#' @param x packages that should be available
#'
#' @return NULL - called for side effect stop()
#'
#' @keywords internal
#' @noRd
check_if_packages_are_available <- function(x) {
  if (
    !all(sapply(x, function(x) {requireNamespace(x, quietly = TRUE)}))
  ) {
    stop(
      paste0(
        "R packages ",
        paste(x, collapse = ", "),
        " needed for this function to work. Please install with ",
        "install.packages(c('", paste(x, collapse = "', '"), "'))"
      ),
      call. = FALSE
    )
  }
}
