# wellspell.addin

wellspell.addin is an RStudio Addin to quickly highlight words with spelling errors in text documents. It employs the [hunspell spell checking engine](http://hunspell.github.io) to do this. You can install wellspell.addin with 

```
devtools::install_github("nevrome/wellspell.addin")
```

![](https://github.com/nevrome/wellspell.addin/raw/master/inst/gif/Peek 2018-12-02 23-38.gif)

To use it, you can select an arbitrary amount of text in a text document in RStudio (e.g. a markdown, latex or html document) and run `spellcheck()`. As the function is registered as an RStudio Addin, it's possible to run it from the Addins dialogue or even with a [keyboard shortcut](https://rstudio.github.io/rstudioaddins/#keyboard-shorcuts) (e.g. <kbd>CTRL</kbd>+<kbd>ALT</kbd>+<kbd>7</kbd>). 

At the first run in a new environment, `spellcheck()` will call `set_config()`, which is another Addin with a minimalistic user interface. It allows you to set two environment variables `wellspell_language` and `wellspell_format`. These are used to configure `hunspell::hunspell()`. `wellspell_language` is fed to `hunspell(dict = dictionary(lang = ...))` and `wellspell_format` to `hunspell(format = ...)`. 

If the environment variables are set, `spellcheck()` selects and thereby highlights all words identified as wrong by hunspell.

The additional functions `get_config()`, `is_config()` and `rm_config` are for dealing with the environment variables and usually don't have to be called directly. 

