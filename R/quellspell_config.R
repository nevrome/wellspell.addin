#' quellspell_is_config
#'
#' @export
quellspell_is_config <- function() {
  
  nchar(Sys.getenv("quellspell_language")) != 0 & nchar(Sys.getenv("quellspell_format")) != 0
  
}

#' quellspell_unconfig
#'
#' @export
quellspell_unconfig <- function() {
  
  Sys.unsetenv(c("quellspell_language", "quellspell_format"))
  
}


#' quellspell_config
#'
#' @export
quellspell_config <- function() {
  
  # Our ui will be a simple gadget page, which
  # simply displays the time in a 'UI' output.
  ui <- miniUI::miniPage(
    miniUI::gadgetTitleBar("quellspell Spellcheck Configuration"),
    miniUI::miniContentPanel(
      shiny::selectInput(
        inputId = "language_selection",
        label = "Select spellcheck language",
        choices = c("en_GB", "en_US"),
        selected = "en_GB",
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
    
    observeEvent(input$done, {
      Sys.setenv(
        quellspell_language = input$language_selection,
        quellspell_format = input$format_selection
      )
      invisible(stopApp())
    })
    
  }
  
  # We'll use a pane viwer, and set the minimum height at
  # 300px to ensure we get enough screen space to display the clock.
  viewer <- shiny::dialogViewer(
    "quellspell_config",
    width = 400,
    height = 200
  )
  shiny::runGadget(ui, server, viewer = viewer)  
  
}
