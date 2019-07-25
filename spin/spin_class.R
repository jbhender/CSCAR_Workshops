#'---
#' title: "Spin Class: No Sweat Reports in R"
#' author: James Henderson, CSCAR
#' date: "`r format.Date( Sys.Date(), '%B %d, %Y')`"
#' output: 
#'   html_document: 
#'     code_folding: hide
#'---

#' ## Components of an Rmarkdown Document
#' 
#' ### The YAML Header
#' Every Rmarkdown document begins with a YAML header, which tells the program 
#' pandoc how to render the markdown file created after running the R chunks. 
#' YAML stands for "yet another markdown language."
#' 

#' For example, below is the header used to create this document. 
#' 
#' ```
#' ---
#' title: Spin Class: No Sweat Reports in R
#' author: James Henderson, CSCAR
#' date: "`r format.Date( Sys.Date(), '%B %d, %Y')`"
#' output: html_document
#' ---
#' ```

#' ### Text Formatted with Markdown
#' What separates Rmdarkdown from a standard R script is the desire to include
#' text explaining your analysis and results. To format this text we use markdown,
#' which is a language for expressing text formatting while maintaining readable
#' plain text. For more on formatting text with markdown see some resources below: 
#' 
#' 1. [Markdown Wiki](https://en.wikipedia.org/wiki/Markdown)
#' 1. [Rmarkdown in Rstudio](https://rmarkdown.rstudio.com/)
#' 1. [Rmarkwon Cheatsheet](https://www.rstudio.com/wp-content/uploads/2016/03/rmarkdown-cheatsheet-2.0.pdf)
#' 1. [Github flavored markdown](https://guides.github.com/features/mastering-markdown/)
#' 1. Michael Clark's [Introduction to Rmarkdown](https://m-clark.github.io/Introduction-to-Rmarkdown/)
#' 1. [Chapter 24](https://r4ds.had.co.nz/r-markdown.html) in R for Data Science

#' ### R Chunks
#' Generally, the reason to write a report in Rmarkdown rather than your favorite
#' word processing application is a desire to include output such as figures, tables,
#' or statistics from an analysis performed in R.  In Rmarkdown, we indicate 
#' executable code using *R chunks*:
#' 

#+ chunks, results = "verbatim", comment = ""
cat('```{r chunk_name}\n # R code goes here\n```')

#' Chunks should always be *named* to keep your code organized and can be passed
#' options to control which output is included and how it is formatted.

#' We can use chunks to execute code, but also to include plots and tables. We
#' will look at examples in our first spin template.
#' 

#' ## Spin
#' The function `spin()` in the `knitr` package can be used to turn a regular
#' R script into an Rmarkdown document (as well as other formats). Thus, when 
#' we use the "compile report button" in Rstudio, our R script is used to produce
#' an Rmarkdown document (.Rmd) which is then compiled into the document type
#' of our choice. 
#' 
#' There are two key things we need to know to use `spin()` to create reports:
#' 
#' 1. *roxygen comments* `#'` are converted to plain text in the `.Rmd` file.
#' 1. *chunk options* for R code are written after `#+`.
#' 
#' It's that simple!
#' 
#' See below for some additonal resource:
#' 
#' 1. Yihui Xie's [demo](https://yihui.name/knitr/demo/stitch/) 
#' (he is the author of `knitr`).
#' 1. [Knitr's best hidden gem](https://deanattali.com/2015/03/24/knitrs-best-hidden-gem-spin/)
#' 
#' ## Examples
#' 1. We'll convert the default Rmarkdown template into a spin template.
