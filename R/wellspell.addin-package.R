#' @rdname wellspell
#' @title wellspell.addin
#'
#' @description
#'
#' wellspell is an RStudio Addin to quickly highlight
#' spelling or grammar errors in text documents. It employs the
#' \href{http://hunspell.github.io}{hunspell spell checking engine}
#' via the \href{https://github.com/ropensci/hunspell}{hunspell package}
#' and the \href{https://www.languagetool.org}{LanguageTool} grammar checking engine
#' via the \href{https://github.com/nevrome/LanguageToolR}{LanguageToolR package}
#' to do so. Checking works for many languages.
#'
#' \strong{Installation}
#'
#' Install the wellspell.addin R package from Github: \code{devtools::install_github("nevrome/wellspell.addin")}.
#' To enable its features you need additional packages:
#'
#' - Spellcheck
#'   - Install the hunspell R package that contains a standalone version of hunspell: \code{install.packages("hunspell")}
#' - Grammar check
#'   - Install the LanguageToolR R package \code{devtools::install_github("nevrome/LanguageToolR")}. It does not contain LanguageTool
#'   - Install LanguageTool \href{https://github.com/languagetool-org/languagetool}{manually} or with the function \code{LanguageToolR::lato_quick_setup()}
#'   - Restart RStudio
#'
#' \strong{Quickstart guide}
#'
#' To use wellspell.addin, you can select an arbitrary amount of text in a text document
#' in RStudio (e.g. a markdown, latex or html document) and run \code{spellcheck()}
#' or \code{gramcheck()}.
#' As the functions are registered as RStudio Addins, it is possible to run them from
#' the Addins dialogue or even with a keyboard shortcut (e.g. Ctrl+Alt+7 and Ctrl+Alt+8).
#'
#' At the first run in a new environment, \code{spellcheck()} and \code{gramcheck()}
#' will call \code{set_config()}, which is another Addin with a minimalistic user interface.
#' It allows you to set environment variables to control the behaviour of the checking tools.
#' If the environment variables are set, \code{spellcheck()} and \code{gramcheck()}
#' select and thereby highlight all words/expressions identified as wrong.
#'
#' The additional functions \code{get_config()}, \code{is_config()} and \code{rm_config}
#' are for dealing with the environment variables and usually don't have to be called
#' directly.
#'
#' \strong{How to install hunspell dictionaries for other languages?}
#'
#' A default RStudio installation includes English dictionaries for the US, UK, Canada,
#' and Australia. In addition, dictionaries for many other languages can be installed.
#' To add these dictionaries, go to the \emph{Spelling} pane of the \emph{Options} dialog, and
#' select \emph{Install More Languages...} from the language dictionary select box. This will
#' download and install all of the available languages. Further instructions can be found
#' \href{https://support.rstudio.com/hc/en-us/articles/200551916-Spelling-Dictionaries}{here}.
#' If this does not work or the relevant languages are not in the default selection you can
#' install languages by copying the dictionary files (.dic + .aff) to one of these locations:
#' \code{hunspell::dicpath()}.
#'
"_PACKAGE"
