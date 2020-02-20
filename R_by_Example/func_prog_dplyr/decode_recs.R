
#setwd('~/github/CSCAR_Workshops/R_by_Example/func_prog_dplyr/')

# libraries: -------------------------------------------------------------------
library(tidyverse)

# codebook: --------------------------------------------------------------------
url = paste0(
  'https://www.eia.gov/consumption/residential/data/2015/xls/',
  'codebook_publicv4.xlsx'
)
path = '.' # where to save the codebook
Sys()
codebook_file = sprintf('%s/codebook_publicv4.xlsx', path)


if ( !file.exists(codebook_file) ) {
  codebook = readxl::read_excel(url, skip = 3) %>%
  as.data.frame()
}

codebook = readxl::read_excel(codebook_file, skip = 3) %>%
  as.data.frame()

# clean codebook: --------------------------------------------------------------
codes = 
  codebook %>% 
  transmute(
   variable = `SAS Variable Name`,
   desc = `Variable Description`,
   levels = stringr::str_split(`...5`, pattern = '\\r\\n'),
   labels = stringr::str_split(`Final Response Set`, pattern = '\\r\\n')
  ) %>%
  # to suppress warnings in the function below
  as.data.frame()

decode_recs = function(x, var, codebook = codes ) {
  # transform a recs variable into a factor with labels as given in 
  # the codebook under "Final Response Set".
  # Inputs:
  #  x - a vector of factor levels to be decoded, e.g. a column in recs data
  #  var - a length 1 character vector with names to be decoded
  #  codes - the codebook in which factor levels & labels are found as columns
  #           with those names and a row for which column "variable" matches 
  #           xname
  # Returns: x, transformed to a factor
  
  #if ( xname %in% codes$variable ) {
  #  cat('ok\n')
    #labels = codes[ codes$variable == xname, ]$labels[[1]]
    #levels = codes[ codes$variable == xname, ]$levels[[1]]
    #factor(x, levels = levels, labels = labels)
  #} 
  if ( var %in% codebook$variable ) {
    labels = codebook[ codebook$variable == var, ]$labels[[1]]
    levels = codebook[ codebook$variable == var, ]$levels[[1]]
    factor(x, levels = levels, labels = labels)
  } else {
    msg = sprintf('There is no variable "%s" in the supplied codes.\n', var)
    stop(msg)
  }
}
