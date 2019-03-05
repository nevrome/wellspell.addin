
<!-- README.md is generated from README.Rmd. Please edit that file -->

# wellspell.addin

![](https://github.com/nevrome/wellspell.addin/raw/master/inst/gif/trump.gif)

### Quickstart

1.  Install the package
    `devtools::install_github("nevrome/wellspell.addin")`

2.  Select text in an open document in RStudio

3.  Run the quick spellcheck or quick grammar check addin

### Manual

``` 
 wellspell is an RStudio Addin to quickly highlight spelling or  
 grammar errors in text documents. It employs the hunspell spell  
 checking engine via the hunspell package and the LanguageTool  
 grammar checking engine via the LanguageToolR package to do so.  
 Checking works for many languages.  

 To use it, you can select an arbitrary amount of text in a text  
 document in RStudio (e.g. a markdown, latex or html document) and  
 run 'spellcheck()' or 'gramcheck()'. As the functions are  
 registered as RStudio Addins, it is possible to run them from the  
 Addins dialogue or even with a keyboard shortcut (e.g. Ctrl+Alt+7  
 and Ctrl+Alt+8).  

 At the first run in a new environment, 'spellcheck()' and  
 'gramcheck()' will call 'set_config()', which is another Addin  
 with a minimalistic user interface. It allows you to set  
 environment variables to control the behaviour of the checking  
 tools. If the environment variables are set, 'spellcheck()' and  
 'gramcheck()' select and thereby highlight all words/expressions  
 identified as wrong.  

 The additional functions 'get_config()', 'is_config()' and  
 'rm_config' are for dealing with the environment variables and  
 usually don't have to be called directly.  

 *How to install hunspell dictionaries for other languages?*  

 RStudio's default installation includes English dictionaries for  
 the US, UK, Canada, and Australia. In addition, dictionaries for  
 many other languages can be installed. To add these dictionaries,  
 go to the _Spelling_ pane of the _Options_ dialog, and select  
 _Install More Languages..._ from the language dictionary select  
 box. This will download and install all of the available  
 languages. Further instructions can be found here. If this doesn't  
 work or the relevant languages are not in the default selection  
 you can install languages by copying the dictionary files (.dic +  
 .aff) to one of these locations: 'hunspell::dicpath()'.  
```
