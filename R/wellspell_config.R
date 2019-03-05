#' @rdname wellspell
#' @export
get_config <- function() {
  c(
    wellspell_language = Sys.getenv("wellspell_language"),
    wellspell_format = Sys.getenv("wellspell_format"),
    wellspell_grammar_ignore = Sys.getenv("wellspell_grammar_ignore")
  )
}

#' @rdname wellspell
#' @export
is_config <- function() {
  nchar(Sys.getenv("wellspell_language")) != 0 & nchar(Sys.getenv("wellspell_format")) != 0
}

#' @rdname wellspell
#' @export
rm_config <- function() {
  Sys.unsetenv(c("wellspell_language", "wellspell_format", "wellspell_grammar_ignore"))
}

#' @rdname wellspell
#' @export
set_config <- function() {

  hunspell_dicts <- hunspell::list_dictionaries()
  default_dict_hunspell <- ifelse("en_GB" %in% hunspell_dicts, "en_GB", hunspell_dicts[1])
  languagetool_dicts <- LanguageToolR::languages()$id
  default_dict_languagetool <- ifelse("en-GB" %in% languagetool_dicts, "en-GB", languagetool_dicts[1])
  
  ui <- miniUI::miniPage(
    miniUI::gadgetTitleBar("wellspell.addin"),
    miniUI::miniTabstripPanel(
      miniUI::miniTabPanel(
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
      ),
      miniUI::miniTabPanel(
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
    )
  )
  
  server <- function(input, output, session) {
    
    shiny::observeEvent(input$done, {
      Sys.setenv(
        wellspell_language_hunspell = input$language_selection_hunspell,
        wellspell_format_hunspell = input$format_selection,
        wellspell_language_languagetool = input$language_selection_languagetool,
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
  shiny::runGadget(ui, server, viewer = viewer)  
  
}
