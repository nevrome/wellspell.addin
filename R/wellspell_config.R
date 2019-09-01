#' @rdname wellspell
#' @export
get_config <- function() {
  c(
    wellspell_language_hunspell = Sys.getenv("wellspell_language_hunspell"),
    wellspell_format_hunspell = Sys.getenv("wellspell_format_hunspell"),
    wellspell_language_languagetool = Sys.getenv("wellspell_language_languagetool"),
    wellspell_grammar_ignore = Sys.getenv("wellspell_grammar_ignore")
  )
}

#' @rdname wellspell
#' @export
is_config <- function() {
  any(sapply(
    c(
      "wellspell_language_hunspell", 
      "wellspell_format_hunspell", 
      "wellspell_language_languagetool"
    ),
    function(x) { nchar(Sys.getenv(x)) != 0 }
  ))
}

#' @rdname wellspell
#' @export
rm_config <- function() {
  Sys.unsetenv(
    c(
      "wellspell_language_hunspell", 
      "wellspell_format_hunspell", 
      "wellspell_language_languagetool", 
      "wellspell_grammar_ignore"
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
#' @md
get_default_dict_languagetool <- function(languagetool_dicts = NULL) {
  if (is.null(languagetool_dicts)) {
    languagetool_dicts <- tryCatch(
      LanguageToolR::lato_list_languages()$id,
      error = function(e) return("")
    )
  }
  
  
  two_letters <- function(str) {
    substr(str, 1, 2)
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




#' @rdname wellspell
#' @export
set_config <- function() {
  
  #### hunspell ####
  if (requireNamespace("hunspell", quietly = TRUE) & test_hunspell()) {
    
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
        shiny::div("hunspell is not installed correctly.")
      )
    )
    
  }
  
  #### LanguageTool ####
  if (requireNamespace("LanguageToolR", quietly = TRUE) & LanguageToolR::lato_test_setup()) {
    
    languagetool_dicts <- LanguageToolR::lato_list_languages()$id
    default_dict_languagetool <- 
      get_default_dict_languagetool(languagetool_dicts = languagetool_dicts)
    
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
        shiny::div("LanguageTool is not installed correctly.")
      )
    )
    
  }
  
  ui <- miniUI::miniPage(
    miniUI::gadgetTitleBar("wellspell.addin"),
    miniUI::miniTabstripPanel(
      hunspell_panel,
      LanguageTool_panel
    )
  )
  
  server <- function(input, output, session) {
    
    shiny::observeEvent(input$done, {
      Sys.setenv(
        wellspell_language_hunspell = ifelse(is.null(input$language_selection_hunspell), "", input$language_selection_hunspell),
        wellspell_format_hunspell = ifelse(is.null(input$format_selection), "", input$format_selection),
        wellspell_language_languagetool = ifelse(is.null(input$language_selection_languagetool), "", input$language_selection_languagetool),
        wellspell_grammar_ignore = paste(input$grammar_ignore, collapse = "/")
      )
      # Change default RStudio spelling language 
      # (to match the language of the tool called by <F7> button)
      if (exists(".rs.writeUiPref")) {
        .rs.writeUiPref("spelling_dictionary_language", input$language_selection_hunspell)
      } 
      
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
