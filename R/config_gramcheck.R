#' @rdname wellspell
#' @export
get_config_gramcheck <- function() {
  c(
    wellspell_language_languagetool = Sys.getenv("wellspell_language_languagetool"),
    wellspell_grammar_ignore = Sys.getenv("wellspell_grammar_ignore")
  )
}

#' @rdname wellspell
#' @export
is_config_gramcheck <- function() {
  any(sapply(
    c(
      "wellspell_language_languagetool"
    ),
    function(x) { nchar(Sys.getenv(x)) != 0 }
  ))
}

#' @rdname wellspell
#' @export
rm_config_gramcheck <- function() {
  Sys.unsetenv(
    c(
      "wellspell_language_languagetool",
      "wellspell_grammar_ignore"
    )
  )
}

#' Get the default languagetool dictionary.
#'
#' Get short name of a `languagetool` dictionary for grammar checking.
#' Note that this name usually contains hyphens and not underscores
#' (e.g., `"en-GB"`).
#'
#' @details Function tries to match the default RStudio spelling language first.
#' If no exact match is found, tries to find the match of the first two letters.
#' The next choice is English/Great Britain (`"en-GB"`) if it exists in the lists.
#' Then first language in the list.
#' If the list is empty, empty string `""` is returned.
#'
#' @param languagetool_dicts (character or `NULL`) A list of languagetool dictionaries
#' as a character vector.
#' If `NULL`, the function gets a list of installed dictionaries.
#'
#' @return String with default language or `""`.
#' @keywords internal
#' @noRd
#' @md
get_default_dict_languagetool <- function(languagetool_dicts = NULL) {

  if (is.null(languagetool_dicts)) {
    languagetool_dicts <- tryCatch(
      LanguageToolR::lato_list_languages()$id,
      error = function(e) return("")
    )
  }

  # Try matching default language in RStudio first
  rs_default <- gsub("_", "-", get_default_dict_hunspell())
  if (rs_default %in% languagetool_dicts) {
    rs_default

  } else if (two_letters(rs_default) %in% two_letters(languagetool_dicts)) {
    # Match first two letters, if exact match is not found
    ind_first <- min(which(two_letters(languagetool_dicts) %in% two_letters(rs_default)))
    languagetool_dicts[ind_first]

  } else if ("en-GB" %in% languagetool_dicts) {
    "en-GB"

  } else {
    languagetool_dicts[1]
  }
}

two_letters <- function(str) {
  substr(str, 1, 2)
}

#' @rdname wellspell
#' @export
set_config_gramcheck <- function() {

  show_console() # make visible what's happening in console.

  #### LanguageTool ####
  if (requireNamespace("LanguageToolR", quietly = TRUE) && LanguageToolR::lato_test_setup()) {

    # get and store languagetool language list
    # the list is stored in an environment variable to increase loading performance
    wellspell_languagetool_list <- Sys.getenv("wellspell_languagetool_list")
    if (wellspell_languagetool_list == "") {
      languagetool_dicts <- LanguageToolR::lato_list_languages()$id
      Sys.setenv(wellspell_languagetool_list = stringi::stri_join(languagetool_dicts, collapse = ","))
    } else {
      languagetool_dicts <- strsplit(wellspell_languagetool_list, ",")[[1]]
    }

    default_dict_languagetool <- get_default_dict_languagetool(languagetool_dicts = languagetool_dicts)

    LanguageTool_panel <- miniUI::miniTabPanel(
      "Grammar check", icon = shiny::icon("ruler"),
      miniUI::miniContentPanel(
        shiny::selectInput(
          inputId = "language_selection_languagetool",
          label = "Select grammar check language",
          choices = languagetool_dicts,
          selected = default_dict_languagetool,
          width = "100%"
        )
      )
    )

  } else {

    LanguageTool_panel <- miniUI::miniTabPanel(
      "Grammar check", icon = shiny::icon("ruler"),
      miniUI::miniContentPanel(
        shiny::div(paste0(
          "Grammar cannot be checked as package 'LanguageToolR' is either ",
          "missing or configured incorrectly."))
      )
    )

  }

  ui <- miniUI::miniPage(
    miniUI::gadgetTitleBar("wellspell.addin"),
    miniUI::miniTabstripPanel(
      LanguageTool_panel
    )
  )

  server <- function(input, output, session) {

    shiny::observeEvent(input$cancel, {
      invisible(shiny::stopApp())
    })

    shiny::observeEvent(input$done, {
      Sys.setenv(
        wellspell_language_languagetool = ifelse(is.null(input$language_selection_languagetool), "", input$language_selection_languagetool),
        wellspell_grammar_ignore = paste(input$grammar_ignore, collapse = "/")
      )

      invisible(shiny::stopApp())
    })
  }

  viewer <- shiny::dialogViewer(
    "wellspell_config",
    width = 300,
    height = 430
  )

  suppressPackageStartupMessages({
    shiny::runGadget(ui, server, viewer = viewer, stopOnCancel = FALSE)
  })
}
