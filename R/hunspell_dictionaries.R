#' @rdname spellcheck
#' @export
get_available_hunspell_dictionaries <- function() {
  hunspell_paths <- hunspell::dicpath()
  
  dic_file <- list.files(hunspell_paths, pattern = "\\.dic$")
  aff_file <- list.files(hunspell_paths, pattern = "\\.aff$")
  
  dic_name <- substr(dic_file, 1 , nchar(dic_file) - 4)
  aff_name <- substr(aff_file, 1 , nchar(aff_file) - 4)
  
  return(intersect(dic_name, aff_name))
}
