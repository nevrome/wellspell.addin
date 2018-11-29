#' wellspell_is_config
#'
#' @export
is_config <- function() {
  
  nchar(Sys.getenv("wellspell_language")) != 0 & nchar(Sys.getenv("wellspell_format")) != 0
  
}

#' wellspell_unconfig
#'
#' @export
unconfig <- function() {
  
  Sys.unsetenv(c("wellspell_language", "wellspell_format"))
  
}

#' wellspell_config
#'
#' @export
config <- function() {
  
  ui <- miniUI::miniPage(
    miniUI::gadgetTitleBar("Spellcheck"),
    miniUI::miniContentPanel(
      shiny::textInput(
        inputId = "language_selection",
        label = "Select spellcheck language",
        value = "en_GB",
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
  
  server <- function(input, output, session) {
    
    shiny::observeEvent(input$done, {
      Sys.setenv(
        wellspell_language = input$language_selection,
        wellspell_format = input$format_selection
      )
      invisible(shiny::stopApp())
    })
    
  }
  
  viewer <- shiny::dialogViewer(
    "wellspell_config",
    width = 300,
    height = 300
  )
  shiny::runGadget(ui, server, viewer = viewer)  
  
}
