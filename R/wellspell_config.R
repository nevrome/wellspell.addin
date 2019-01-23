#' @rdname spellcheck
#' @export
get_config <- function() {
  c(
    wellspell_language = Sys.getenv("wellspell_language"),
    wellspell_format = Sys.getenv("wellspell_format"),
    wellspell_grammar_ignore = Sys.getenv("wellspell_grammar_ignore")
  )
}

#' @rdname spellcheck
#' @export
is_config <- function() {
  nchar(Sys.getenv("wellspell_language")) != 0 & nchar(Sys.getenv("wellspell_format")) != 0
}

#' @rdname spellcheck
#' @export
rm_config <- function() {
  Sys.unsetenv(c("wellspell_language", "wellspell_format", "wellspell_grammar_ignore"))
}

#' @rdname spellcheck
#' @export
set_config <- function() {

  hunspell_dicts <- hunspell::list_dictionaries()
  default_dict <- ifelse("en_GB" %in% hunspell_dicts, "en_GB", hunspell_dicts[1])
  
  ui <- miniUI::miniPage(
    miniUI::gadgetTitleBar("wellspell.addin"),
    miniUI::miniTabstripPanel(
      miniUI::miniTabPanel(
        "Spellcheck", icon = shiny::icon("language"),
        miniUI::miniContentPanel(
          shiny::selectInput(
            inputId = "language_selection",
            label = "Select spellcheck language",
            choices = hunspell_dicts,
            selected = default_dict,
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
        "grammar check", icon = shiny::icon("ruler"),
        miniUI::miniContentPanel(
          shiny::HTML("<i>Only works with english text.</i>"),
          shiny::checkboxGroupInput(
            inputId = "grammar_ignore",
            label = "Should any grammar errors be ignored?",
            choiceNames = list(
              "Passive Voice",
              "Duplicate words (the the)",
              "'So' at start of sentence",
              "'There is/are; at start of sentence",
              "Avoid weasel words",
              "Wordiness",
              "Problematic Adverbs",
              "Cliches",
              "Avoid 'Being' words"
            ),
            choiceValues = list(
              "passive", "illusion", "so", "thereIs", "weasel",
              "adverb", "toWordy", "cliches", "eprime"
            )
          )
        )
      )
    )
  )
  
  server <- function(input, output, session) {
    
    shiny::observeEvent(input$done, {
      Sys.setenv(
        wellspell_language = input$language_selection,
        wellspell_format = input$format_selection,
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
