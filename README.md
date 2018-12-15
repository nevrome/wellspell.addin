# wellspell.addin

wellspell.addin is an RStudio Addin to quickly highlight words with spelling errors in text documents. It employs the [hunspell spell checking engine](http://hunspell.github.io) via the [hunspell package](https://github.com/ropensci/hunspell) to do this. You can install wellspell.addin with 

```
devtools::install_github("ropensci/hunspell")
devtools::install_github("nevrome/wellspell.addin")
```

![](https://github.com/nevrome/wellspell.addin/raw/master/inst/gif/dracula.gif)

To use it, you can select an arbitrary amount of text in a text document in RStudio (e.g. a markdown, latex or html document) and run `spellcheck()`. As the function is registered as an RStudio Addin, it's possible to run it from the Addins dialogue or even with a [keyboard shortcut](https://rstudio.github.io/rstudioaddins/#keyboard-shorcuts) (e.g. <kbd>CTRL</kbd>+<kbd>ALT</kbd>+<kbd>7</kbd>). 

At the first run in a new environment, `spellcheck()` will call `set_config()`, which is another Addin with a minimalistic user interface. It allows you to set two environment variables `wellspell_language` and `wellspell_format`. These are used to configure `hunspell::hunspell()`. `wellspell_language` is fed to `hunspell(dict = dictionary(lang = ...))` and `wellspell_format` to `hunspell(format = ...)`. 

If the environment variables are set, `spellcheck()` selects and thereby highlights all words identified as wrong by hunspell.

The additional functions `get_config()`, `is_config()` and `rm_config` are for dealing with the environment variables and usually don't have to be called directly. 

## How to install dictionaries for other languages

RStudio's default installation includes English dictionaries for the US, UK, Canada, and Australia. In addition, dictionaries for many other languages can be installed. To add these dictionaries, go to the **Spelling** pane of the **Options** dialog, and select **Install More Languages...** from the language dictionary select box. This will download and install all of the available languages. Further instructions can be found [here](https://support.rstudio.com/hc/en-us/articles/200551916-Spelling-Dictionaries). If this doesn't work or the relevant languages are not in the default selection you can install languages by copying the dictionary files (.dic + .aff) to one of these locations: `hunspell::dicpath()`.
