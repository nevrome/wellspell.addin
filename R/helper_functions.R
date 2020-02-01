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
        "\nR package(s) ",
        stringi::stri_join(x, collapse = ", "),
        " needed for this function to work. \nPlease install with ",
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

#' Deselect text in RStudio document.
#'
#' @param context The resut of rstudioapi::getSourceEditorContext()
#' @keywords internal
#' @noRd
deselect_rstudio_range <- function(context) {
    pos <- context$selection[[1]]$range[["start"]]
    rng <- rstudioapi::document_range(pos, end = pos)
    rstudioapi::setSelectionRanges(ranges = rng, id = context$id)
}

# Show console window, if hidden, and move focus to it
show_console <- function() {
  if (rstudioapi::isAvailable(version_needed = "1.2.1261")) {
    rstudioapi::executeCommand("activateConsole", quiet = TRUE)
  }
}

# Show source editor's window, if hidden, and move focus to it
show_source_editor <- function() {
  if (rstudioapi::isAvailable(version_needed = "1.2.1261")) {
    rstudioapi::executeCommand("activateSource", quiet = TRUE)
  }
}
