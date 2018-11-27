quellspell <- function(dict = hunspell::dictionary("en_GB")) {

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
    potentially_wrong_words <- unlist(hunspell::hunspell(good_words, dict = dict))
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

