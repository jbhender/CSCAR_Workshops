# R by Example: Analyzing RECS using data.table
# Intructor example
#
# In this script, I use the 2015 RECS data to examine which US census region
# has the coolest home temperature during winter.
#
# Data Source:
# https://www.eia.gov/consumption/residential/data/2015/index.php?view=microdata
#
# Updated: February 5, 2020
# Author: James Henderson

#setwd('~/github/CSCAR_Workshops/R_by_Example/recs_datatable/')
  
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
     region = factor(REGIONC, levels = 1:4, 
                     labels = c('Northeast', 'Midwest', 'South', 'West') ),
     # case selection
     heat_home = factor(HEATHOME, 0:1, c('No', 'Yes') ),
     # temp variables
     temp_home = neg_to_na(TEMPHOME), 
     temp_gone = neg_to_na(TEMPGONE),
     temp_night = neg_to_na(TEMPNITE)
    ) ] 

# replicate weights, for computing standard errors: ----------------------------
## pivoted to a longer format to facilitate "vectorization"
weights_long = 
  recs[, c('DOEID', grep('^BRRWT', names(recs), value = TRUE)),  with = FALSE
  ] %>%
  melt( data = ., id.vars = 'DOEID', patterns('^BRRWT'),
        variable.name = 'replicate', value.name = 'weight') 
setnames(weights_long, c('id', 'replicate', 'weight'))

# filter cases to those that use space heating in winter: ----------------------

## shows why we want to do this, temps are missing if space heating not used
#recs_core[heat_home == 'No', lapply(.SD, function(x) sum(is.na(x)) ) ]

recs_core = recs_core[heat_home == 'Yes']

# point estimates for winter temperatures by region: ---------------------------

## method 1, manually type out each temperature type
temps_by_region = 
  recs_core[,
  .( avg_temp_home = sum(temp_home * weight) / sum(weight),
     avg_temp_gone = sum(temp_gone * weight) / sum(weight),
     avg_temp_night = sum(temp_night * weight) / sum(weight)
   ), region]

## method 2, pivot to a longer format
temps_by_type_region =
  melt( recs_core, 
        id.vars = c('id', 'region', 'weight'),
        measure.vars = patterns('^temp_'),
        variable.name = 'type',
        value.name = 'temp'
  ) %>% 
  .[ , .(avg_temp = sum(temp * weight) / sum(weight)) , .(type, region)]

# replicate winter temperature estimates, for standard errors: -----------------

## 4 regions, 3 types, 96 replicate weights = 1,152 rows
temps_by_type_region_repl =
  ### each row is a temperature type for a single home
  melt( recs_core, 
        id.vars = c('id', 'region'),
        measure.vars = patterns('^temp_'),
        variable.name = 'type',
        value.name = 'temp'
  ) %>%
  ### join with replicate weights, each previous row is now 96 rows
  merge(weights_long, ., by = c('id'), all = FALSE, allow.cartesian = TRUE) %>%
  .[, .(avg_temp_repl = sum(temp * weight) / sum(weight)),
      .(type, region, replicate)]

# compute standard errors and CIs: ---------------------------------------------
## 1. Join replicate and point estimates
## 2. Compute std error using scaled RMSE of replicates around point estimates
## 3. Form confidence intervals using stand
## Refer to the link below for std error computations, see page 3
## the standard error is the square root of the variance estimate
## https://www.eia.gov/consumption/residential/data/2015/pdf/microdata_v3.pdf

avg_temp_by_type_region =
 merge(
   temps_by_type_region_repl, 
   temps_by_type_region, 
   by = c('region', 'type')
 ) %>%
 .[, .( avg_temp = avg_temp[1],
        se = 2 * sqrt( mean( {avg_temp_repl - avg_temp}^2 ) ) 
      ), 
   .(type, region)]

avg_temp_by_type_region[,
    `:=`( lwr = avg_temp - qnorm(.975) * se, 
          upr = avg_temp + qnorm(.975) * se ) ]

# visualize the results: -------------------------------------------------------

## New factor for nice labels
avg_temp_by_type_region[, 
  `Winter Temperature` := 
            factor(type, 
                   levels = c('temp_gone', 'temp_home', 'temp_night'),
                   labels = c('when no one is home during day',
                              'when someone is home during the day',
                              'at night'
                            )
            )
]

## Plot 1, organized by region
avg_temp_by_type_region %>%
  ggplot( aes(y = avg_temp, x = region, color = `Winter Temperature`) ) +
    geom_point( position = position_dodge(width = 0.2)) +
    geom_errorbar( aes(ymin = lwr, ymax = upr), 
                   width = .1, position = position_dodge(width = 0.2)
    ) +
    theme_bw() +
    xlab('US Census Region') +
    ylab('Average Temperature, ºF') +
    scale_color_manual( values = c("darkblue", "darkred", "orange") )

## Plot 2, organized by type
avg_temp_by_type_region %>%
  ggplot( aes(y = avg_temp, x = `Winter Temperature`, color = region) ) +
    geom_point( position = position_dodge(width = 0.2)) +
    geom_errorbar( aes(ymin = lwr, ymax = upr), 
                   width = .1, position = position_dodge(width = 0.2)
    ) +
    theme_bw() +
#    xlab('US Census Region') +
    ylab('Average Temperature, ºF') +
    scale_color_manual( values = c("darkblue", "purple", "darkred", "orange")) +
  coord_flip()
                        
