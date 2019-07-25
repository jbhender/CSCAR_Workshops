#' ---
#' title: 'Spin Class: No Sweat Reports'
#' author: "James Henderson, CSCAR"
#' date: "7/24/2019"
#' output: html_document
#' ---

#+ setup, include=FALSE  
knitr::opts_chunk$set(echo = TRUE)

#' ## R Markdown
#' This is an R Markdown document. Markdown is a simple formatting syntax
#' for authoring HTML, PDF, and MS Word documents. For more details on 
#' using R Markdown see <http://rmarkdown.rstudio.com>.
#' 
#' When you click the **Compile Report** button a document will be generated 
#' that includes both content as well as the output of any embedded R
#' code chunks within the document. You can embed an R code chunk's as regular
#' R code and provide chunk options like this:
  
#+ cars
summary(cars)

#' ## Including Plots
#' 
#' You can also embed plots, for example:
  
#' pressure, echo=FALSE
plot(pressure)

#' Note that the `echo = FALSE` parameter was added to the code chunk to prevent
#' printing of the R code that generated the plot.
