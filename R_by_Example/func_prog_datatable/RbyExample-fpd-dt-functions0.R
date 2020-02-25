# R by Example: Functional Programming using data.table
# Function 0
#
# In this script, we encapsulate the core data.table code from the example
# in a function allowing only the data set to change.  
#
#
# Data Source:
# https://www.eia.gov/consumption/residential/data/2015/index.php?view=microdata
#
# Updated: February 24, 2020
# Author: James Henderson

#setwd('~/github/CSCAR_Workshops/R_by_Example/func_prog_datatable/')
debug = TRUE
if ( debug == TRUE ) { 
  library(tidyverse); library(data.table)
  recs = fread('../recs_datatable/recs2015_public_v4.csv')  
  
  # clean up key variables used in this problem: -------------------------------
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

   # replicate weights, for computing standard errors: -------------------------
  ## pivoted to a longer format to facilitate "vectorization"
  weights_long = 
   recs[, c('DOEID', grep('^BRRWT', names(recs), value = TRUE)),  with = FALSE
  ] %>%
  melt( data = ., id.vars = 'DOEID', patterns('^BRRWT'),
        variable.name = 'replicate', value.name = 'weight') 
  setnames(weights_long, c('id', 'replicate', 'weight'))

  # filter cases to those that use space heating in winter: --------------------

  ## shows why we want to do this, temps are missing if space heating not used
  #recs_core[heat_home == 'No', lapply(.SD, function(x) sum(is.na(x)) ) ]

  recs_core = recs_core[heat_home == 'Yes']
  
  recs_long = melt( recs_core, 
        id.vars = c('id', 'region', 'weight'),
        measure.vars = patterns('^temp_'),
        variable.name = 'type',
        value.name = 'temp'
  )
  
} # ends if (debug == TRUE)

# function to compute point estimates for winter temperatures by region: -------

## initial function
recs_mean0 = function(dt) {
  # computes the weighted mean of "temp" using weights given in "weight" and
  # grouped by "type" and "region"
  #
  # inputs: dt - a data.table with columns temp, weight, type, and region
  #
  # output: a data.table with one row per type/region
  
  # key computation
  dt[, .(avg_temp = sum(temp * weight) / sum(weight)), .(type, region)]
}
#recs_mean0(recs_long)

## add some error checking to recs_mean0
recs_mean1 = function(dt) {
  # computes the weighted mean of "temp" using weights given in "weight" and
  # grouped by "type" and "region"
  #
  # inputs: dt - a data.table with columns temp, weight, type, and region
  #
  # output: a data.table with one row per type/region
  
  ## error checking
  stopifnot( is.data.table(dt) )
  stopifnot( all( c('temp', 'weight', 'type', 'region') %in% names(dt) ) )
  
  # key computation
  dt[, .(avg_temp = sum(temp * weight) / sum(weight)) , .(type, region)]
}
#recs_mean1(recs_long)

## make grouping variable programmable
recs_mean2 = function(dt, by = NULL ) {
  # computes the weighted mean of "temp" using weights given in "weight" and
  # grouped by "type" and "region"
  #
  # inputs: dt - a data.table with columns temp, weight, type, and region
  #
  # output: a data.table with one row per type/region
  
  ## error checking
  stopifnot( is.data.table(dt) )
  
  stopifnot( 'temp' %in% names(dt) )
  stopifnot( 'weight' %in% names(dt) )
  stopifnot( all( by %in% names(dt) ) ) 
  
  # key computation
  dt[, .(avg_temp = sum(temp * weight) / sum(weight)) , by = by]
}
recs_mean2(recs_long, by = c('type', 'region'))

## make target variable and weight variable programmable
recs_mean3 = function(dt, target, weight = 'weight', by = NULL) {
  # computes the weighted mean of "temp" using weights given in "weight" and
  # grouped by "type" and "region"
  #
  # inputs: dt - a data.table with columns temp, weight, type, and region
  #
  # output: a data.table with one row per type/region
  
  ## error checking
  stopifnot( is.data.table(dt) )
  stopifnot( target %in% names(dt) )
  stopifnot( weight %in% names(dt) )
  stopifnot( all( by %in% names(dt) ) ) 
  
  # key computation
  dt[, 
     .(avg = sum(.SD[[..target]] * .SD[[..weight]]) / sum(.SD[[..weight]])),
     by = by]
}
recs_mean3(recs_long, target = 'temp', weight = 'weight', 
           by = c('type', 'region'))
#recs_mean3(recs, target = 'TEMPHOME', weight = 'NWEIGHT', by = 'EQUIPMUSE')

## make name of new variable programmable
recs_mean4 = function(dt, target, weight = 'weight', by = NULL, new_var = NULL) {
  # computes the weighted mean of "temp" using weights given in "weight" and
  # grouped by "type" and "region"
  #
  # inputs: dt - a data.table with columns temp, weight, type, and region
  #
  # output: a data.table with one row per type/region
  
  ## error checking
  stopifnot( is.data.table(dt) )
  
  stopifnot( is.null(new_var) | {length(new_var) == length(var)} )
  stopifnot( target %in% names(dt) )
  stopifnot( weight %in% names(dt) )
  stopifnot( all( by %in% names(dt) ) ) 
  
  # key computation
  out = dt[, 
         .(avg = sum(.SD[[..target]] * .SD[[..weight]]) / sum(.SD[[..weight]])),
         by = by
        ]
  
  # adjust names as needed
  if ( !is.null(new_var) ) {
    setnames(out, c(by, new_var) )
  } else {
    setnames(out, c(by, target) )
  }
  out
}
recs_mean4(recs_long, 
           target = 'temp', 
           by = c('type', 'region')#,
#           new_var = 'avg_temp'
          )
recs_mean4(recs, 
           target = 'TEMPHOME', 
           weight = 'NWEIGHT', 
           by = 'EQUIPMUSE',
           new_var = 'temp_home')

## Allow for multiple targets
recs_mean5 = function(dt, target, weight = 'weight', by = NULL, new_var = NULL) {
  # computes the weighted mean of "temp" using weights given in "weight" and
  # grouped by "type" and "region"
  #
  # inputs: dt - a data.table with columns temp, weight, type, and region
  #
  # output: a data.table with one row per type/region
  
  ## error checking
  stopifnot( is.data.table(dt) )
  
  stopifnot( is.null(new_var) | {length(new_var) == length(var)} )
  stopifnot( target %in% names(dt) )
  stopifnot( weight %in% names(dt) )
  stopifnot( all( by %in% names(dt) ) ) 
  
  # key computation
  if ( length(target) == 1 ) {
    out = dt[, .(avg =
                   sum(.SD[[..target]] * .SD[[..weight]]) / sum(.SD[[..weight]])
                 ),
             by = by
          ]
    
    if ( !is.null(new_var) ) {
      setnames(out, c(by, new_var) )
    } else {
          setnames(out, c(by, target) )
    }
  } else {
    out = dt[, .(avg = sum(.SD[[..target[1]]] * .SD[[..weight]] ) / 
                           sum(.SD[[..weight]])
                ),
             by = by
          ]
    
  }
    for ( tt in target ) {
      out_list    
    }
    
  }
  
  # adjust names as needed
  if ( FALSE * !is.null(new_var) ) {
    setnames(out, c(by, new_var) )
  } else {
#    setnames(out, c(by, target) )
  }
  out
}
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
                        
