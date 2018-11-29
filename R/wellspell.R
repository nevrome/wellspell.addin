#' @rdname spellcheck
#' 
#' @description wellspell is an Rstudio Addin to quickly highlight words with 
#' spelling errors in text documents. It uses the hunspell spell checking engine
#' to do this.
#' 
#' To use it, you can select an arbitrary amount of text in an open text document 
#' in Rstudio (e.g. a markdown, latex or html document) an run \code{spellcheck()}.
#' As the function is registered as an RStudio Addin, it's possible to run it from
#' the Addins dialogue or even with a keyboard shortcut. 
#' 
#' At the first run in a new environemt, \code{spellcheck()} will call 
#' \code{set_config}, which is an RStudio Addin with a minimalistic user interface. 
#' It allows you to set two environment variables \code{wellspell_language} and
#' \code{wellspell_format}. These are used to configure \code{hunspell::hunspell()}.
#' \code{wellspell_language} is fed to \code{hunspell(dict = dictionary(lang = ...))}
#' and \code{wellspell_format} to \code{hunspell(format = ...)}. 
#' 
#' If the environment variables are set, \code{spellcheck()} selects and thereby 
#' highlights all words identified as wrong by hunspell.
#' 
#' The additional functions \code{get_config()}, \code{is_config()}, and \code{rm_config}
#' are for dealing with the environment variables and usually don't have to be called 
#' directly. 
#' 
"_PACKAGE"

#' @rdname spellcheck
#' @export
spellcheck <- function() {

  if (!is_config()) {
    set_config()
  }

  context <- rstudioapi::getSourceEditorContext()

  range.start.row <- as.numeric(unlist(context$selection)["range.start.row"])
  range.start.column <- as.numeric(unlist(context$selection)["range.start.column"])
  range.end.row <- as.numeric(unlist(context$selection)["range.end.row"])
  text <- as.character(unlist(context$selection)["text"])

  rows <- range.start.row:range.end.row
  start_columns <- c(range.start.column, rep(1, length(rows) - 1))
  row_texts <- unlist(strsplit(text, "\n"))

  range <- list()
  i <- 1
  for (p1 in 1:length(row_texts)) {
    all_words <- unlist(stringr::str_split(row_texts[[p1]], " "))
    good_words <- stringr::str_subset(all_words, "^[^0-9]*$")
    # run spellcheck
    potentially_wrong_words <- unlist(hunspell::hunspell(
      good_words, 
      format = Sys.getenv("wellspell_format"),
      dict = hunspell::dictionary(Sys.getenv("wellspell_language"))
    ))
    if (length(potentially_wrong_words) == 0) { next }
    positions_raw <- stringr::str_locate_all(
      row_texts[p1],
      paste0("([^\\p{L}])(", potentially_wrong_words, ")([^\\p{L}])")
    )
    positions <- do.call(rbind, positions_raw)
    if (nrow(positions) == 0) { next }
    for (p2 in 1:nrow(positions)) {
      start <- rstudioapi::document_position(
        row = rows[p1],
        column = start_columns[p1] + positions[p2, 1]
      )
      end <- rstudioapi::document_position(
        row = rows[p1],
        column = (start_columns[p1] + positions[p2, 2]) - 1
      )
      range[[i]] <- rstudioapi::document_range(start, end)
      i <- i + 1
    }
  }

  rstudioapi::setSelectionRanges(
    range,
    id = context$id
  )

}

