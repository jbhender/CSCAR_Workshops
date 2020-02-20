# R by Example: Analyzing RECS using the Tidyverse
# Solution to participant example (b)
#
# In this script, you will use the 2015 RECS data to examine 
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
# Updated: January 30, 2020
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
#
recs_core = 
  recs %>% 
  transmute( 
    # id variables
    id = DOEID,
    weight = NWEIGHT,
    # grouping factor
    therm = factor(EQUIPMUSE, levels = c(1:5, 9), 
             labels = c('Set one temp', 
                        'Manually adjust',
                        'Program thermostat',
                        'Turn equipment on/off',
                        'No control',
                        'Other',
                        )
            ),
    # case selection
    heat_home = factor(HEATHOME, 0:1, c('No', 'Yes') ),
    # temp variables
    temp_home = TEMPHOME, 
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

# point estimates for winter temperatures by thermostat behavior: --------------

diff_by_therm = 
 recs_core %>%
 mutate( delta = temp_home - temp_night ) %>%
 group_by(therm) %>%
 summarize( avg_delta = sum(delta * weight) / sum(weight) )

# replicate winter temperature estimates, for standard errors: -----------------

## 6 therm values, 2 types, 96 replicate weights = 1152 rows
diff_by_therm_repl =
  ### each row is a temperature type for a single home
  recs_core %>%
  transmute(id, therm, delta = temp_home - temp_night ) %>%
  ### join with repliacte weights, each previous row is now 96 rows
  left_join( weights_long, by = c('id') ) %>%
  group_by(therm, replicate) %>%
  summarize(  avg_delta_repl = sum(delta * weight) / sum(weight) )

# compute standard errors and CIs: ---------------------------------------------
## 1. Join replicate and point estimates
## 2. Compute std error using scaled RMSE of replicates around point estimates
## 3. Form confidence intervals using standard methods

## Refer to the link below for std error computations, see page 3
## the standard error is the square root of the variance estimate
## https://www.eia.gov/consumption/residential/data/2015/pdf/microdata_v3.pdf

avg_diff_by_therm =
 left_join(
   diff_by_therm,
   diff_by_therm_repl,
   by = c('therm')
 ) %>%
 group_by(therm) %>%
 summarize( 
   avg_delta = avg_delta[1], # point estimate: unique(avg_temp), first(avg_temp) 
   se = 2 * sqrt( mean( {avg_delta_repl - avg_delta}^2 ) ) 
 ) %>%
 mutate( 
   lwr = avg_delta - qnorm(.975) * se, 
   upr = avg_delta + qnorm(.975) * se 
 )

# visualize the results: -------------------------------------------------------
avg_diff_by_therm %>%
  ggplot( aes(y = avg_delta, x = therm) ) + 
    geom_point() + 
    geom_errorbar( aes(ymin = lwr, ymax = upr), width = .1) + 
    theme_bw() +
    xlab('Thermostat Behavior') +
    ylab('Avg Night Less Day Temp Difference when Home, ºF') +
    geom_hline( yintercept = 0, lty = 'dashed', color = 'darkgrey')
