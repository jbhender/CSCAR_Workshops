# R by Example: Functional programming with dplyr
# Example 1 - adaptation of decoding variables for earlier script
#
# In this script, we adapt RbyExample-recs_tidy-example.R 
#  by encapsulating repeated patters within functions.
#
# Data Source:
# https://www.eia.gov/consumption/residential/data/2015/index.php?view=microdata
#
# Updated: February 20, 2020
# Author: James Henderson

#setwd('~/github/CSCAR_Workshops/R_by_Example/func_prog_dplyr/')

# libraries: -------------------------------------------------------------------
library(tidyverse)

# data: ------------------------------------------------------------------------
url = paste0(
  'https://www.eia.gov/consumption/residential/data/2015/csv/',
  'recs2015_public_v4.csv'
)
local_file = './recs2015_public_v4.csv'

# use local file if it exists, if not use url and save locally
if ( !file.exists(local_file) ) {
  recs = read_delim(url, delim = ',')
  write_delim(recs, path = local_file, delim = ',')
} else {
  recs = read_delim(local_file, delim = ',')
}

# codebook: --------------------------------------------------------------------
#https://www.eia.gov/consumption/residential/data/2015/xls/codebook_publicv4.xlsx
path = '.' # where to find the codebook
codebook_file = sprintf('%s/codebook_publicv4.xlsx', path)

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
#filter(codes, variable == 'REGIONC')
#filter(codes, variable == 'REGIONC')$labels

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

# example data prep: -----------------------------------------------------------
mutate(recs,
       region = decode_recs(REGIONC, 'REGIONC', codebook = codes)
) %>% select(region)
