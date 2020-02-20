# R by Example: Functional programming with dplyr
# Example 2 - adaptation of earlier script
#
# In this script, we adapt RbyExample-recs_tidy-example.R 
#  by encapsulating repeated patters within functions.
#
# Data Source:
# https://www.eia.gov/consumption/residential/data/2015/index.php?view=microdata
#
# Updated: February 20, 2020
# Author: James Henderson

# libraries: -------------------------------------------------------------------
library(tidyverse)

# functions: -------------------------------------------------------------------
source('./RbyExample-recs_funcs.R')

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

# clean up key variables used in this problem: ---------------------------------
recs_core = 
  recs %>% 
  transmute( 
    # id variables
    id = DOEID,
    weight = NWEIGHT,
    # grouping factor
    region = decode_recs(REGIONC, 'REGIONC'),
    # case selection
    heat_home = factor(HEATHOME, 0:1, c('No', 'Yes') ),
    # temp variables
    temp_home = TEMPHOME, 
    temp_gone = TEMPGONE,
    temp_night = TEMPNITE
  ) %>%
  # Convert negative numbers to missing, for temps. 
  mutate_if(is.numeric, function(x) ifelse(x < 0, NA, x))

# replicate weights, for computing standard errors: ----------------------------
## pivoted to a longer format to facilite dplyr "vectorization"
weights_long = 
  recs %>% 
  select( id = DOEID, BRRWT1:BRRWT96 ) %>%
  pivot_longer( 
    cols = BRRWT1:BRRWT96, 
    names_to = 'replicate', 
    values_to = 'weight'
  )

# filter cases to those that use space heating in winter: ----------------------

## shows why we want to do this, temps are missing if space heating not used
#recs_core %>% 
#  filter(heat_home == 'No') %>%
#  summarize_all( .funs = function(x) sum(is.na(x)) )

recs_core = filter(recs_core, heat_home == 'Yes')

# point estimates for winter temperatures by region: ---------------------------

## manually type out
temps_by_region0 = 
  recs_core %>% 
  group_by(region) %>%
  summarize( 
    avg_temp_home = sum(temp_home * weight) / sum(weight),
    avg_temp_gone = sum(temp_gone * weight) / sum(weight),
    avg_temp_night = sum(temp_night * weight) / sum(weight)
  )

## scoped variant
temps_by_region1 = recs_core %>% 
  group_by(region) %>%
  summarize_at(
    .vars = c('temp_home', 'temp_gone', 'temp_night'),
    .funs = ~ sum(. * weight) / sum(weight)
  )

## functional version
recs_mean0 = function(df, vars) {
  # Inputs
  #  df: a (possibly grouped) tibble or data.frame object to be summarized
  #      df must have a variable 'weight' for the weighted sums. 
  #  vars: a character vector of numeric variables in 
  #
  # Outputs: a tibble with one row (per group) as returned by summarize_at
  
  summarize_at(df, .vars = vars, .funs = ~ sum(. * weight) / sum(weight) )    
}

# Don't be afraid to do some of the work outside the function
temps_by_region = recs_core %>% 
  group_by(region) %>%
  recs_mean0( vars = c('temp_home', 'temp_gone', 'temp_night') )

## functional version with groups
recs_mean1 = function(df, vars, group = NULL) {
  # Inputs
  #  df: a (possibly grouped) tibble or data.frame object to be summarized
  #      df must have a variable 'weight' for the weighted sums. 
  #  vars: a character vector of numeric variables in 
  #  group: a character vector with variable names to group by. If 
  #         NULL (the default) retains an group structure of `df` as passed.
  #
  # Outputs: a tibble with one row (per group) as returned by summarize_at
  
  # add group structure
  if ( !is.null(group) ) {
    if ( length(group) == 1) {
      df = group_by(df, .data[[ !!group ]])
    } else {
      df = ungroup(df)
      for ( i in 1:length(group) ) {
        df = group_by(df, .data[[ !!group[i] ]], add = TRUE)
      }
    }
  }
  
    # summarize using weighted mean
  summarize_at(df, .vars = vars, .funs = ~ sum(. * weight) / sum(weight) )    
}

## Example uses
recs_mean1(recs_core, vars = c('temp_home', 'temp_gone', 'temp_night') )

recs_core %>%
  group_by(region) %>%
  recs_mean1( vars = c('temp_home', 'temp_gone', 'temp_night'))

recs_mean1(recs_core, vars = c('temp_home', 'temp_gone', 'temp_night'),
           group = 'region')


## pivot to a longer format
df = 
  recs_core %>%
  select(id, weight, region, starts_with('temp_') ) %>%
  pivot_longer( 
    cols = starts_with('temp'),
    names_to = 'type',
    names_prefix = 'temp_',
    values_to = 'temp'
  )

temps_by_type_region =
  df %>%
  #group_by(type, region) %>% recs_mean1( vars = 'temp' )
  recs_mean1( vars = c('temp'), group = c('type', 'region'))

# replicate winter temperature estimates, for standard errors: -----------------
avg_temp_by_type_region = 
  recs_mean_brr(df, weights_long, vars = c('temp'), 
                by = c('id'), group = c('region', 'type') )


