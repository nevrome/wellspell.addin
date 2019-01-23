
<!-- README.md is generated from README.Rmd. Please edit that file -->
wellspell.addin
===============

![](https://github.com/nevrome/wellspell.addin/raw/master/inst/gif/dracula.gif)

Install
-------

``` r
devtools::install_github("nevrome/wellspell.addin")
```

Manual
------

     wellspell is an RStudio Addin to quickly highlight words with  
     spelling errors in text documents. It employs the hunspell spell  
     checking engine via the hunspell package to do this to do this.  

     To use it, you can select an arbitrary amount of text in an text  
     document in RStudio (e.g. a markdown, latex or html document) and  
     run 'spellcheck()'. As the function is registered as an RStudio  
     Addin, it's possible to run it from the Addins dialogue or even  
     with a keyboard shortcut (e.g. Ctrl+Alt+7).  

     At the first run in a new environment, 'spellcheck()' will call  
     'set_config()', which is another Addin with a minimalistic user  
     interface.  It allows you to set two environment variables  
     'wellspell_language' and 'wellspell_format'. These are used to  
     configure 'hunspell::hunspell()'. 'wellspell_language' is fed to  
     'hunspell(dict = dictionary(lang = ...))' and 'wellspell_format'  
     to 'hunspell(format = ...)'.  

     If the environment variables are set, 'spellcheck()' selects and  
     thereby highlights all words identified as wrong by hunspell.  

     The additional functions 'get_config()', 'is_config()' and  
     'rm_config' are for dealing with the environment variables and  
     usually don't have to be called directly.  

     *How to install dictionaries for other languages*  

     RStudio's default installation includes English dictionaries for  
     the US, UK, Canada, and Australia. In addition, dictionaries for  
     many other languages can be installed.  To add these dictionaries,  
     go to the _Spelling_ pane of the _Options_ dialog, and select  
     _Install More Languages..._ from the language dictionary select  
     box. This will download and install all of the available  
     languages. Further instructions can be found here.  If this  
     doesn't work or the relevant languages are not in the default  
     selection you can install languages by copying the dictionary  
     files (.dic + .aff) to one of these locations:  
     'hunspell::dicpath()'.
