# R by Example: Analyzing RECS using the Tidyverse
# Intructor example
#
# In this script, I use the 2015 RECS data to examine which US census region
# has the coolest home temperature during winter.
#
# Data Source:
# https://www.eia.gov/consumption/residential/data/2015/index.php?view=microdata
#
# Updated: January 16, 2020
# Author: James Henderson

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

# clean up key variables used in this problem: ---------------------------------
recs_core = 
  recs %>% 
  transmute( 
    # id variables
    id = DOEID,
    weight = NWEIGHT,
    # grouping factor
    region = factor(REGIONC, levels = 1:4, 
                    labels = c('Northeast', 'Midwest', 'South', 'West') ),
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
temps_by_region = 
  recs_core %>% 
  group_by(region) %>%
  summarize( 
    avg_temp_home = sum(temp_home * weight) / sum(weight),
    avg_temp_gone = sum(temp_gone * weight) / sum(weight),
    avg_temp_night = sum(temp_night * weight) / sum(weight)
  )

## scoped variant version
recs_core %>% 
  group_by(region) %>%
  summarize_at(.vars = c('temp_home', 'temp_gone', 'temp_night'),
            .funs = ~ sum(. * weight) / sum(weight)
  )


## functional version
recs_mean = function(df, vars, group = NULL) {
  # Inputs
  #  df: a (possibly grouped) tibble or data.frame object to be summarized
  #      df must have a variable 'weight' for the weighted sums. 
  #  vars: a character vector of numeric variables in 
  #
  # Outputs: a tibble with one row (per group) as returned by summarize_at
  
  if ( !is.null(group) ) {
    if ( length(group) == 1) {
      df = group_by(df, .data[[group]])
    } else {
      df = ungroup(df)
      for ( i in 1:length(group) ) {
       df = group_by(df, .data[[ group[i] ]], add = TRUE)
      }
    }
  }
  
  summarize_at(df, .vars = vars, .funs = ~ sum(. * weight) / sum(weight) )    
}

temps_by_region = recs_core %>% 
  group_by(region) %>%
  recs_mean( vars = c('temp_home', 'temp_gone', 'temp_night') )

recs_mean(recs_core, vars = c('temp_home', 'temp_gone', 'temp_night'),
          group = 'region')

 
## pivot to a longer format
temps_by_type_region =
  recs_core %>%
  pivot_longer( 
    cols = starts_with('temp'),
    names_to = 'type',
    names_prefix = 'temp_',
    values_to = 'temp'
  ) %>%
  #group_by(type, region) %>%
  recs_mean( vars = c('temp'), group = c('type', 'region'))

# replicate winter temperature estimates, for standard errors: -----------------
## 4 regions, 3 types, 96 replicate weights = 1,152 rows
temps_by_type_region_repl =
  ### each row is a temperature type for a single home
  recs_core %>%
  select(id, region, starts_with('temp_') ) %>%
  pivot_longer( 
    cols = starts_with('temp'),
    names_to = 'type',
    names_prefix = 'temp_',
    values_to = 'temp'
  ) %>%
  ### join with repliacte weights, each previous row is now 96 rows
  left_join( weights_long, by = c('id') ) %>%
  group_by(type, region, replicate) %>%
  summarize(  avg_temp_repl = sum(temp * weight) / sum(weight) )

# compute standard errors and CIs: ---------------------------------------------
## 1. Join replicate and point estimates
## 2. Compute std error using scaled RMSE of replicates around point estimates
## 3. Form confidence intervals using stand
## Refer to the link below for std error computations, see page 3
## the standard error is the square root of the variance estimate
## https://www.eia.gov/consumption/residential/data/2015/pdf/microdata_v3.pdf

avg_temp_by_type_region =
 left_join(
   temps_by_type_region_repl, 
   temps_by_type_region, 
   by = c('region', 'type')
 ) %>%
 group_by(type, region) %>%
 summarize( 
   avg_temp = avg_temp[1], # point estimate: unique(avg_temp), first(avg_temp) 
   se = 2 * sqrt( mean( {avg_temp_repl - avg_temp}^2 ) ) 
 ) %>%
 mutate( lwr = avg_temp - qnorm(.975) * se, upr = avg_temp + qnorm(.975) * se )

