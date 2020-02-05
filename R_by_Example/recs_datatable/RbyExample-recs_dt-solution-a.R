# R by Example: Analyzing RECS using data.table
# Solution to participant example (a)
#
# In this script, you will use the 2015 RECS data to examine 
# how thermostat behavior impacts the difference between day and night
# temperatures in winter, while someone is home. 
#
# Specifically, this script estimates the national average temperatures, 
# in homes that use space heating,
# during the day when someone is home and at night for
# homes grouped by thermostat behavior.
#
# Data Source:
# https://www.eia.gov/consumption/residential/data/2015/index.php?view=microdata
#
# Updated: Feburary 5, 2020
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


# point estimates for winter temperatures by thermostat behavior: --------------

## method 1, manually type out each temperature type
temps_by_therm = 
  recs_core[,
  .( avg_temp_home = sum(temp_home * weight) / sum(weight),
     avg_temp_night = sum(temp_night * weight) / sum(weight)
   ), therm]

## method 2, pivot to a longer format
temps_by_type_therm =
  melt( recs_core, 
        id.vars = c('id', 'therm', 'weight'),
        measure.vars = patterns('^temp_'),
        variable.name = 'type',
        value.name = 'temp'
  ) %>% 
  .[ , .(avg_temp = sum(temp * weight) / sum(weight)) , .(type, therm)]

# replicate winter temperature estimates, for standard errors: -----------------

## 6 therm values, 2 types, 96 replicate weights = 1152 rows
temps_by_type_therm_repl =
  ### each row is a temperature type for a single home
  melt( recs_core, 
        id.vars = c('id', 'therm'),
        measure.vars = patterns('^temp_'),
        variable.name = 'type',
        value.name = 'temp'
  ) %>%
  ### join with replicate weights, each previous row is now 96 rows
  merge(weights_long, ., by = c('id'), all = FALSE, allow.cartesian = TRUE) %>%
  .[, .(avg_temp_repl = sum(temp * weight) / sum(weight)),
      .(type, therm, replicate)]

# compute standard errors and CIs: ---------------------------------------------
## 1. Join replicate and point estimates
## 2. Compute std error using scaled RMSE of replicates around point estimates
## 3. Form confidence intervals using standard methods

## Refer to the link below for std error computations, see page 3
## the standard error is the square root of the variance estimate
## https://www.eia.gov/consumption/residential/data/2015/pdf/microdata_v3.pdf

avg_temp_by_type_therm =
 merge(
   temps_by_type_therm_repl, 
   temps_by_type_therm, 
   by = c('therm', 'type')
 ) %>%
 .[, .( avg_temp = avg_temp[1],
        se = 2 * sqrt( mean( {avg_temp_repl - avg_temp}^2 ) ) 
      ), 
   .(type, therm)]

avg_temp_by_type_therm[,
    `:=`( lwr = avg_temp - qnorm(.975) * se, 
          upr = avg_temp + qnorm(.975) * se ) ]

# visualize the results: -------------------------------------------------------
## New factor for nice labels
avg_temp_by_type_therm[, 
  `Winter Temperature` := 
            factor(type, 
                   levels = c('temp_gone', 'temp_home', 'temp_night'),
                   labels = c('when no one is home during day',
                              'when someone is home during the day',
                              'at night'
                            )
            )
]

avg_temp_by_type_therm %>%
  ggplot( aes(y = avg_temp, x = therm, color = `Winter Temperature`) ) +
    geom_point( position = position_dodge(width = 0.2)) +
    geom_errorbar( aes(ymin = lwr, ymax = upr), 
                   width = .1, position = position_dodge(width = 0.2)
    ) +
    theme_bw() +
    xlab('Thermostat Behavior') +
    ylab('Average Temperature, ºF') +
    scale_color_manual( values = c("darkred", "orange") ) +
    coord_flip()
