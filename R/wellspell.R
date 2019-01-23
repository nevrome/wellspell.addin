#' @rdname spellcheck
#' @title wellspell.addin
#' 
#' @description wellspell is an RStudio Addin to quickly highlight words with
#' spelling or grammer errors in text documents. It employs the
#' \href{http://hunspell.github.io}{hunspell spell checking engine}
#' via the \href{https://github.com/ropensci/hunspell}{hunspell package}
#' and the \href{https://github.com/btford/write-good}{write-good} linter
#' via the \href{https://github.com/ropenscilabs/gramr}{gramr package}
#' to do so. Spellchecking works for many languages, grammer checking is limited
#' to english text.
#' 
#' To use it, you can select an arbitrary amount of text in a text document
#' in RStudio (e.g. a markdown, latex or html document) and run \code{spellcheck()}
#' or \code{gramcheck()}.
#' As the functions are registered as RStudio Addins, it is possible to run them from
#' the Addins dialogue or even with a keyboard shortcut (e.g. Ctrl+Alt+7 and Ctrl+Alt+8).
#' 
#' At the first run in a new environment, \code{spellcheck()} and \code{gramcheck()}
#' will call \code{set_config()}, which is another Addin with a minimalistic user interface.
#' It allows you to set three environment variables \code{wellspell_language},
#' \code{wellspell_format} and \code{wellspell_grammer_ignore}.
#' These are used to configure \code{hunspell::hunspell()} and \code{gramr::check_grammar()}.
#' \code{wellspell_language} is fed to \code{hunspell(dict = dictionary(lang = ...))},
#' \code{wellspell_format} to \code{hunspell(format = ...)} and
#' \code{wellspell_grammer_ignore} to \code{check_grammar(options = ...)}
#' 
#' If the environment variables are set, \code{spellcheck()} and \code{gramcheck()}
#' select and thereby highlight all words/expressions identified as wrong.
#' 
#' The additional functions \code{get_config()}, \code{is_config()} and \code{rm_config}
#' are for dealing with the environment variables and usually don't have to be called
#' directly.
#' 
#' \strong{How to install hunspell dictionaries for other languages?}
#'   
#' RStudio's default installation includes English dictionaries for the US, UK, Canada,
#' and Australia. In addition, dictionaries for many other languages can be installed.
#' To add these dictionaries, go to the \emph{Spelling} pane of the \emph{Options} dialog, and
#' select \emph{Install More Languages...} from the language dictionary select box. This will
#' download and install all of the available languages. Further instructions can be found
#' \href{https://support.rstudio.com/hc/en-us/articles/200551916-Spelling-Dictionaries}{here}.
#' If this doesn't work or the relevant languages are not in the default selection you can
#' install languages by copying the dictionary files (.dic + .aff) to one of these locations:
#' \code{hunspell::dicpath()}.
#' 
"_PACKAGE"

#' @rdname spellcheck
#' @export
spellcheck <- function() { return(check(find_bad_spelling)) }

#' @rdname spellcheck
#' @export
gramcheck <- function() { return(check(find_bad_grammer)) } 

#### algorithm functions ####

find_bad_spelling <- function(x) {
  
  # get all words of current row
  all_words <- unlist(stringr::str_split(x, " "))
  
  # remove words with numbers
  good_words <- stringr::str_subset(all_words, "^[^0-9]*$")
  
  # run spellcheck and get bad words
  hunspell_output <- unlist(hunspell::hunspell(
    good_words, 
    format = Sys.getenv("wellspell_format"),
    dict = hunspell::dictionary(Sys.getenv("wellspell_language"))
  ))
  
  return(hunspell_output)
  
}

find_bad_grammer <- function(x) {
  
  # set ignore options based on global variable
  options <- unlist(strsplit(Sys.getenv("wellspell_grammer_ignore"), "/"))
  option_list <- lapply(options, function(x) { FALSE })
  names(option_list) <- options
  
  # run grammer check
  gramr_output <- gramr::check_grammar(
    x,
    options = option_list
  )
  
  if (is.null(gramr_output)) {
    return(c())
  } else {
    # print messages
    for (y in gramr_output) {
      message(y)
    }
    # get bad words
    return(unique(sapply(strsplit(gramr_output, "\""), function(x) { x[2] })))
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

  # stop with there is no text for current row
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
  range <- list()
  i <- 1
  for (p1 in 1:length(row_texts)) {
    
    potentially_wrong_words <- find_bad_function(row_texts[[p1]])
    
    # stop with run for current row if no words are wrong
    if (length(potentially_wrong_words) == 0) { next }
    
    # find position of wrong words
    positions_raw <- stringr::str_locate_all(
      paste0(" ", row_texts[p1], " "),
      # ignore words that are part of other words
      paste0("([^\\p{L}])(", potentially_wrong_words, ")([^\\p{L}])")
    )
    positions <- do.call(rbind, positions_raw)
    
    # stop if the wrong words can not be found. That can happen
    # if half words where selected and identified as errors
    # by hunspell
    if (nrow(positions) == 0) { next }
    
    # loop to define the wrong words' positions in a form that 
    # the RStudio API can understand
    # the results are stored in a list of ranges
    for (p2 in 1:nrow(positions)) {
      start <- rstudioapi::document_position(
        row = rows[p1],
        column = (start_columns[p1] + positions[p2, 1]) - 1
      )
      end <- rstudioapi::document_position(
        row = rows[p1],
        column = (start_columns[p1] + positions[p2, 2]) - 2
      )
      range[[i]] <- rstudioapi::document_range(start, end)
      i <- i + 1
    }
  }

  # use range list to select and thereby highlight wrong words 
  rstudioapi::setSelectionRanges(
    range,
    id = context$id
  )

  # message for user if no errors were found
  if (length(range) == 0) {
    message("No errors found.")
  }
  
  message("")
  
}

