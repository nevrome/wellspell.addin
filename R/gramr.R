#' @rdname spellcheck
#' @export
gramcheck <- function() {

  # get selected text from RStudio API
  context <- rstudioapi::getSourceEditorContext()
  
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
    
    # run grammer check
    gramr_output <- gramr::check_grammar(row_texts[p1])
    
    # stop with run for current row if nothing is wrong
    if (is.null(gramr_output)) { next }
    
    # get potentially_wrong_words
    potentially_wrong_words <- unique(sapply(strsplit(gramr_output, "\""), function(x) { x[2] }))
    
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
    message("No spelling errors found.")
  }

}