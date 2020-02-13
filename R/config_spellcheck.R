#' @rdname wellspell
#' @export
get_config_spellcheck <- function() {
  c(
    wellspell_language_hunspell = Sys.getenv("wellspell_language_hunspell"),
    wellspell_format_hunspell = Sys.getenv("wellspell_format_hunspell")
  )
}

#' @rdname wellspell
#' @export
is_config_spellcheck <- function() {
  any(sapply(
    c(
      "wellspell_language_hunspell",
      "wellspell_format_hunspell"
    ),
    function(x) { nchar(Sys.getenv(x)) != 0 }
  ))
}

#' @rdname wellspell
#' @export
rm_config_spellcheck <- function() {
  Sys.unsetenv(
    c(
      "wellspell_language_hunspell",
      "wellspell_format_hunspell"
    )
  )
}

#' Get default hunspell dictionary.
#'
#' Get short name of a Hunspell dictionary for spellchecking.
#' Note that this name usually contains underscores and not hyphens,
#' e.g., `"en_GB"`.
#'
#' @details Function tries to match the default RStudio spelling language first.
#' If it is not on the list, then English/Great Britain (`"en_GB"`) is the second choice.
#' If it is not present, the first language in the list is selected.
#' If the list is empty, empty string `""` is returned.
#'
#' @param hunspell_dicts (character or `NULL`) A list of hunspell dictionaries
#' as a character vector.
#' If `NULL`, the function gets a list of installed dictionaries.
#'
#' @return String with default language or `""`.
#' @keywords internal
#' @noRd
#' @md
get_default_dict_hunspell <- function(hunspell_dicts = NULL) {
  if (is.null(hunspell_dicts)) {
    hunspell_dicts <- tryCatch(
      hunspell::list_dictionaries(),
      error = function(e) return("")
    )
  }

  rs_default <-
    if (exists(".rs.readUiPref")) {
      # Reads default RStudio spellchecking language
      .rs.readUiPref("spelling_dictionary_language")
    } else {
      ""
    }

  if (rs_default %in% hunspell_dicts) {
    rs_default

  } else if ("en_GB" %in% hunspell_dicts) {
    "en_GB"

  } else {
    hunspell_dicts[1]
  }
}

#' @rdname wellspell
#' @export
set_config_spellcheck <- function() {

  show_console() # make visible what's happening in console.

  #### hunspell ####
  if (requireNamespace("hunspell", quietly = TRUE) && test_hunspell()) {

    hunspell_dicts <- hunspell::list_dictionaries()
    default_dict_hunspell <-
      get_default_dict_hunspell(hunspell_dicts = hunspell_dicts)

    hunspell_panel <- miniUI::miniTabPanel(
      "Spellcheck", icon = shiny::icon("language"),
      miniUI::miniContentPanel(
        shiny::selectInput(
          inputId = "language_selection_hunspell",
          label = "Select spellcheck language",
          choices = hunspell_dicts,
          selected = default_dict_hunspell,
          width = "100%"
        ),
        shiny::selectInput(
          inputId = "format_selection",
          label = "Select document format",
          choices = c("text", "man", "latex", "html", "xml"),
          selected = "text",
          width = "100%"
        )
      )
    )

  } else {

    hunspell_panel <- miniUI::miniTabPanel(
      "Spellcheck", icon = shiny::icon("language"),
      miniUI::miniContentPanel(
        shiny::div(paste0(
          "Spelling cannot be checked as package 'hunspell' is either ",
          "missing or works incorrectly."))
      )
    )

  }

  ui <- miniUI::miniPage(
    miniUI::gadgetTitleBar("wellspell.addin"),
    miniUI::miniTabstripPanel(
      hunspell_panel
    )
  )

  server <- function(input, output, session) {

    shiny::observeEvent(input$cancel, {
      invisible(shiny::stopApp())
    })

    shiny::observeEvent(input$done, {
      Sys.setenv(
        wellspell_language_hunspell = ifelse(is.null(input$language_selection_hunspell), "", input$language_selection_hunspell),
        wellspell_format_hunspell = ifelse(is.null(input$format_selection), "", input$format_selection)
      )
      # Change default RStudio spelling language
      # (to match the language of the tool called by <F7> button)
      if (exists(".rs.writeUiPref")) {
        new_default_lang <- input$language_selection_hunspell
        if (.rs.readUiPref("spelling_dictionary_language") != new_default_lang) {
          message(
            "\nNOTE: The default RStudio spellchecking language was changed to ",
            new_default_lang,
            ".\n"
          )

          .rs.writeUiPref("spelling_dictionary_language", new_default_lang)
        }
      }

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
