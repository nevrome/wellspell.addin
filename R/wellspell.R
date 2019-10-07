#' @rdname wellspell
#' @export
spellcheck <- function() { return(try(check(find_bad_spelling))) }

#' @rdname wellspell
#' @export
gramcheck <- function() { return(try(check(find_bad_grammar))) } 

#### algorithm functions ####

find_bad_spelling <- function(x) {
  
  # check if hunspell is available
  check_if_packages_are_available("hunspell")
  
  # get all words of current row
  all_words <- unlist(stringr::str_split(x, " "))
  
  # remove words with numbers
  good_words <- stringr::str_subset(all_words, "^[^0-9]*$")
  
  # run spellcheck and get bad words
  hunspell_output <- unlist(hunspell::hunspell(
    good_words, 
    format = Sys.getenv("wellspell_format_hunspell"),
    dict = hunspell::dictionary(Sys.getenv("wellspell_language_hunspell"))
  ))
  
  error_collection <- list()
  error_collection$func <- "find_bad_spelling"
  error_collection$wrong <- hunspell_output
  error_collection$messages <- sapply(
    hunspell_output,
      function(y) {
        a <- stringi::stri_join(sep = " ",
          hunspell::hunspell_suggest(
            y,
            hunspell::dictionary(Sys.getenv("wellspell_language_hunspell"))
          )[[1]],
          collapse = ", "
        )
        res <- stringi::stri_join(
          stringr::str_pad(
            y, 20, side = "right", 
            pad = stringi::stri_unescape_unicode("\u2007")
          ),
          " | ",
          a
        )
        return(res)
      }
    )
    
  return(error_collection)
  
}

find_bad_grammar <- function(x) {
  
  # check if LanguageToolR is available
  check_if_packages_are_available("LanguageToolR")
  
  # run grammar check
  languagetool_output <- LanguageToolR::languagetool(
    x, 
    language = Sys.getenv("wellspell_language_languagetool"),
    quiet = TRUE
  )
  
  if (is.null(languagetool_output)) {
    error_collection <- list()
    error_collection$wrong <- c()
    error_collection$messages <- c()
    return(error_collection)
  } else {
    error_collection <- list()
    error_collection$func <- "find_bad_grammar"
    error_collection$type
    error_collection$wrong <- trimws(
      gsub("^(\\.\\.\\.\\s*)|(\\s*\\.\\.\\.)$", "", languagetool_output$context_text)
    )
    error_collection$messages <- stringi::stri_join(
      stringr::str_pad(
        languagetool_output$rule_category_name, 20, side = "right", 
        pad = stringi::stri_unescape_unicode("\u2007")
      ),
      " | ",
      languagetool_output$message
    )
    return(error_collection)
  }

}

check <- function(find_bad_function) {

  # check if environment variables for configuration are set
  # if not: call set_config() addin
  if (!is_config()) {
    set_config()
  }

  # get selected text from RStudio API
  context <- rstudioapi::getSourceEditorContext()

  # check context
  if (nchar(context$path) == 0) {
    stop("Unknown source file path. Is the file where you apply wellspell saved?")
  }
  if (as.character(unlist(context$selection)["text"]) == "") { 
    stop("No text selected.")  
  }
  
  # extract relevant values from API output
  range.start.row <- as.numeric(unlist(context$selection)["range.start.row"])
  range.start.column <- as.numeric(unlist(context$selection)["range.start.column"])
  range.end.row <- as.numeric(unlist(context$selection)["range.end.row"])
  text <- as.character(unlist(context$selection)["text"])

  # create vectors to work rowwise
  rows <- range.start.row:range.end.row
  start_columns <- c(range.start.column, rep(1, length(rows) - 1))
  row_texts <- unlist(strsplit(text, "\n"))

  # main spellchecking loop: rowwise
  pb <- utils::txtProgressBar(style = 3)
  i <- 1
  range <- list()
  marker <- list()
  for (p1 in 1:length(row_texts)) {
    
    current_row_text <- row_texts[[p1]]
    
    error_collection <- find_bad_function(current_row_text)
    
    potentially_wrong_words <- error_collection$wrong
    error_messages <- error_collection$messages
    
    # stop with run for current row if no words are wrong
    if (length(potentially_wrong_words) == 0) { next }
    
    # find position of wrong words
    positions_raw <- list()
    for (p3 in 1:length(potentially_wrong_words)) {
      x <- potentially_wrong_words[p3]
      if (error_collection$func == "find_bad_spelling") {
        pos <- stringr::str_locate(
          stringi::stri_join(" ", current_row_text, " "),
          # ignore words that are part of other words
          stringi::stri_join("([^\\p{L}])(", x, ")([^\\p{L}])")
        )
      } else if (error_collection$func == "find_bad_grammar") {
        pos <- stringr::str_locate(
          stringi::stri_join(" ", current_row_text, " "),
          stringr::coll(x)
        )
      }
      positions_raw[[p3]] <- pos
      substr(current_row_text, pos[1], pos[1]) <- " "
    }
    positions <- do.call(rbind, positions_raw)
    
    # stop if the wrong words can not be found. That can happen
    # if incomplete words where selected and identified as errors
    # by hunspell
    if (nrow(positions) == 0 | any(is.na(positions))) { next }

    # loop to define the wrong words' positions in a form that 
    # the RStudio API can understand
    # the results are stored in a list of ranges and a list of markers
    for (p2 in 1:nrow(positions)) {
      # range
      start <- rstudioapi::document_position(
        row = rows[p1],
        column = (start_columns[p1] + positions[p2, 1]) - 1
      )
      end <- rstudioapi::document_position(
        row = rows[p1],
        column = (start_columns[p1] + positions[p2, 2]) - 2
      )
      range[[i]] <- rstudioapi::document_range(start, end)
      # marker
      cur_marker <- list()
      cur_marker$type <- "warning"
      cur_marker$file <- context$path
      cur_marker$line <- rows[p1]
      cur_marker$column <- (start_columns[p1] + positions[p2, 1]) - 1
      cur_marker$message <- error_messages[p2]
      marker[[i]] <- cur_marker
      
      i <- i + 1
    }
    
    utils::setTxtProgressBar(pb, p1/length(row_texts))
  }
  close(pb)
  
  # message for user if no errors were found
  if (length(range) == 0) {
    message("wellspell.addin: No errors found.")
    rstudioapi::sourceMarkers(
      name = "wellspell.addin",
      markers = list(list(
        type = "info",
        file = context$path,
        line = range.start.row,
        column = range.start.column,
        message = "wellspell.addin: No errors found."
      ))
    )
    deselect_rstudio_range(context)
    return()
  }
  
  # use range list to select and thereby highlight wrong words 
  rstudioapi::setSelectionRanges(
    range,
    id = context$id
  )
  
  # set markers
  rstudioapi::sourceMarkers(
    name = "wellspell.addin",
    markers = marker
  )
  
}

