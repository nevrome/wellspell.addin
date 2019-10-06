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
      stringi::stri_join(
        "R packages ",
        stringi::stri_join(x, collapse = ", "),
        " needed for this function to work. Please install with ",
        "install.packages(c('", stringi::stri_join(x, collapse = "', '"), "'))"
      ),
      call. = FALSE
    )
  }
}

# simple test if hunspell works as expected
test_hunspell <- function() {
  hunspell::hunspell("pantoffel")[[1]] == "pantoffel"
}
