# R by Example: Analyzing RECS using data.table
# Solution to participant example (b)
#
# In this script, we use the 2015 RECS data to examine 
# how thermostat behavior impacts the difference between day and night
# temperatures in winter, while someone is home. 
#
# Specifically, this sript estimates the national average difference between
# temperatures during the day when someone is home and at night
# grouped by thermostat behavior, among homes that that use space heating.
#
# Data Source:
# https://www.eia.gov/consumption/residential/data/2015/index.php?view=microdata
#
# Updated: February 6, 2020
# Author: James Henderson

# libraries: -------------------------------------------------------------------
library(tidyverse); library(data.table)

# data: ------------------------------------------------------------------------
url = paste0(
  'https://www.eia.gov/consumption/residential/data/2015/csv/',
  'recs2015_public_v4.csv'
)
local_file = './recs2015_public_v4.csv'

# use local file if it exists, if not use url and save locally
if ( !file.exists(local_file) ) {
  recs = fread(url)
  fwrite(recs, file = local_file)
} else {
  recs = fread(local_file)
}

# clean up key variables used in this problem: ---------------------------------
neg_to_na = function(x) {
  ifelse( x < 0, NA, x)
}

recs_core = 
  recs[, 
       .(
         # id variables
         id = DOEID,
         weight = NWEIGHT,
         # grouping factor
         therm = factor(EQUIPMUSE, levels = c(1:5, 9), 
                        labels = c(
                          'Set one temp', 
                          'Manually adjust',
                          'Program thermostat',
                          'Turn equipment on/off',
                          'No control',
                          'Other'
                        )
         ),
         # case selection
         heat_home = factor(HEATHOME, 0:1, c('No', 'Yes') ),
         # temp variables
         temp_home = neg_to_na(TEMPHOME), 
         temp_night = neg_to_na(TEMPNITE)
       ) ] 

# filter cases to those that use space heating in winter: ----------------------

## shows why we want to do this, temps are missing if space heating not used
#recs_core[heat_home == 'No', lapply(.SD, function(x) sum(is.na(x)) ) ]
recs_core = recs_core[heat_home == 'Yes']

# replicate weights, for computing standard errors: ----------------------------
## pivoted to a longer format to facilitate "vectorization"
weights_long = 
  recs[, c('DOEID', grep('^BRRWT', names(recs), value = TRUE)),  with = FALSE
       ] %>%
  melt( data = ., id.vars = 'DOEID', patterns('^BRRWT'),
        variable.name = 'replicate', value.name = 'weight') 
setnames(weights_long, c('id', 'replicate', 'weight'))

# point estimates for diff in winter temperatures by thermostat behavior: ------
recs_core[ , delta := temp_home - temp_night]
diff_by_therm = recs_core[, .(avg_delta = sum(delta * weight) / sum(weight)), 
                          .(therm)]

# replicate winter temperature estimates, for standard errors: -----------------

## 6 therm values, 96 replicate weights = 576 rows
### join with replicate weights, each previous row is now 96 rows
diff_by_therm_repl =
  merge( weights_long, 
         recs_core[, .(id, therm, delta)], 
         by = c('id'), 
         all = FALSE, 
         allow.cartesian = TRUE
  ) %>%
  .[, .(avg_delta_repl = sum(delta * weight) / sum(weight)),
    .(therm, replicate)]

# compute standard errors and CIs: ---------------------------------------------
## 1. Join replicate and point estimates
## 2. Compute std error using scaled RMSE of replicates around point estimates
## 3. Form confidence intervals using standard methods

## Refer to the link below for std error computations, see page 3
## the standard error is the square root of the variance estimate
## https://www.eia.gov/consumption/residential/data/2015/pdf/microdata_v3.pdf

avg_diff_by_therm =
 merge(
   diff_by_therm,
   diff_by_therm_repl,
   by = c('therm'),
   all = TRUE
 ) %>%
 .[, .(avg_delta = avg_delta[1], 
       se = 2 * sqrt( mean( {avg_delta_repl - avg_delta}^2 ) )
       ), .(therm)] 

avg_diff_by_therm[ , `:=`( lwr = avg_delta - qnorm(.975) * se,
                           upr = avg_delta + qnorm(.975) * se 
                         )]
 
# visualize the results: -------------------------------------------------------
avg_diff_by_therm %>%
  ggplot( aes(y = avg_delta, x = therm) ) + 
    geom_point() + 
    geom_errorbar( aes(ymin = lwr, ymax = upr), width = .1) + 
    theme_bw() +
    xlab('Thermostat Behavior') +
    ylab('Avg Night Less Day Temp Difference when Home, ºF') +
    geom_hline( yintercept = 0, lty = 'dashed', color = 'darkgrey')
