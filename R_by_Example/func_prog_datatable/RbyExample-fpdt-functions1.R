# R by Example: Functional Programming using data.table
# Functions recs_mean_brr0 - recs_mean_brrX
#
# In this script, we encapsulate the core data.table code for utilizing the
# replicate weights in a series of increasingly flexible functions.
#
# Data Source:
# https://www.eia.gov/consumption/residential/data/2015/index.php?view=microdata
#
# Updated: March 6, 2020
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

# version 0, just wrap the code we want to repeat in a function: ---------------
recs_mean_brr0 = function( ) {
  # compute weighted mean of "temp" by type and region and then compute
  # standard errors and 95% confidence bounds using
  #
  # Output: a data.table with each row giving the average temperature for a type
  #         and a region along with its standard error and 95% confidence bound
  #         compute using the replicate weight method.
  
  # point estimates
  temps_by_type_region = recs_long %>%
    .[ , .(avg_temp = sum(temp * weight) / sum(weight)) , .(type, region)]

  # replicate estimates
  temps_by_type_region_repl =
    recs_long[, !"weight"] %>%
    ### join with replicate weights, each previous row is now 96 rows
    merge(weights_long, ., by = c('id'), 
          all = FALSE, allow.cartesian = TRUE) %>%
    .[, .(avg_temp_repl = sum(temp * weight) / sum(weight)),
      .(type, region, replicate)]
  
  # merge and compute standard errors
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
  
  # comptue upper and lower confidence bounds
  avg_temp_by_type_region[,
                          `:=`( lwr = avg_temp - qnorm(.975) * se, 
                                upr = avg_temp + qnorm(.975) * se ) ][]
  
  avg_temp_by_type_region
  
}

if ( debug == TRUE ) {
  avg_temp_by_type_region = recs_mean_brr0()
}

# version 1, allow the input data to change: -----------------------------------
recs_mean_brr1 = function(dt, weights_long, on = 'id') {
  # compute weighted mean of "temp" by type and region and then compute
  # standard errors and 95% confidence bounds using
  #
  # Inputs: dt - a data.table with reference data from which to compute
  #              weighted means of various variables
  #         weights_long - a data.table with each row one replicate weight for
  #                        each household in "dt"
  #         on - a character vector identifying the common variable in dt
  #              and weights long on which to join the two
  # 
  # Output: a data.table with each row giving the average temperature for a type
  #         and a region along with its standard error and 95% confidence bound
  #         compute using the replicate weight method.
  
  # error checking
  stopifnot( is.data.table(dt) & is.data.table(weights_long) )
  stopifnot( all( on %in% names(dt) ) & all( on %in% names(weights_long)) )
  
  # point estimates
  pe = dt[ , .(avg_temp = sum(temp * weight) / sum(weight)) , .(type, region)]
  
  # replicate estimates
  pe_repl = merge(weights_long, dt[, !"weight"], by = on,
                  all = FALSE, allow.cartesian = TRUE) %>%
    .[, .(avg_temp_repl = sum(temp * weight) / sum(weight)),
      .(type, region, replicate)]
  
  # merge and compute standard errors
  out =
    merge(
      pe_repl, 
      pe, 
      by = c('region', 'type')
    ) %>%
    .[, .( avg_temp = avg_temp[1],
           se = 2 * sqrt( mean( {avg_temp_repl - avg_temp}^2 ) ) 
    ), 
    .(type, region)]
  
  # comptue upper and lower confidence bounds
  out[, `:=`( lwr = avg_temp - qnorm(.975) * se, 
              upr = avg_temp + qnorm(.975) * se ) ][]
  
  out
  
}

if ( debug == TRUE ) {
  avg_temp_by_type_region = recs_mean_brr1(recs_long, weights_long, on = 'id')
}

# version 1, allow the input data to change: -----------------------------------
recs_mean_brr1 = function(dt, weights_long, on = 'id') {
  # compute weighted mean of "temp" by type and region and then compute
  # standard errors and 95% confidence bounds using
  #
  # Inputs: dt - a data.table with reference data from which to compute
  #              weighted means of various variables
  #         weights_long - a data.table with each row one replicate weight for
  #                        each household in "dt"
  #         on - a character vector identifying the common variable in dt
  #              and weights long on which to join the two
  # 
  # Output: a data.table with each row giving the average temperature for a type
  #         and a region along with its standard error and 95% confidence bound
  #         compute using the replicate weight method.
  
  # error checking
  stopifnot( is.data.table(dt) & is.data.table(weights_long) )
  stopifnot( all( on %in% names(dt) ) & all( on %in% names(weights_long)) )
  
  # point estimates
  pe = dt[ , .(avg_temp = sum(temp * weight) / sum(weight)) , .(type, region)]
  
  # replicate estimates
  pe_repl = merge(weights_long, dt[, !"weight"], by = on,
                  all = FALSE, allow.cartesian = TRUE) %>%
    .[, .(avg_temp_repl = sum(temp * weight) / sum(weight)),
      .(type, region, replicate)]
  
  # merge and compute standard errors
  out =
    merge(
      pe_repl, 
      pe, 
      by = c('region', 'type')
    ) %>%
    .[, .( avg_temp = avg_temp[1],
           se = 2 * sqrt( mean( {avg_temp_repl - avg_temp}^2 ) ) 
    ), 
    .(type, region)]
  
  # comptue upper and lower confidence bounds
  out[, `:=`( lwr = avg_temp - qnorm(.975) * se, 
              upr = avg_temp + qnorm(.975) * se ) ][]
  
  out
  
}

if ( debug == TRUE ) {
  avg_temp_by_type_region = recs_mean_brr2(recs_long, weights_long)
}

# version 1, allow the input data to change: -----------------------------------
recs_mean_brr1 = function(dt, weights_long, on = 'id') {
  # compute weighted mean of "temp" by type and region and then compute
  # standard errors and 95% confidence bounds using
  #
  # Inputs: dt - a data.table with reference data from which to compute
  #              weighted means of various variables
  #         weights_long - a data.table with each row one replicate weight for
  #                        each household in "dt"
  #         on - a character vector identifying the common variable in dt
  #              and weights long on which to join the two
  # 
  # Output: a data.table with each row giving the average temperature for a type
  #         and a region along with its standard error and 95% confidence bound
  #         compute using the replicate weight method.
  
  # error checking
  stopifnot( is.data.table(dt) & is.data.table(weights_long) )
  stopifnot( all( on %in% names(dt) ) & all( on %in% names(weights_long)) )
  
  # point estimates
  pe = dt[ , .(avg_temp = sum(temp * weight) / sum(weight)) , .(type, region)]
  
  # replicate estimates
  pe_repl = merge(weights_long, dt[, !"weight"], by = on,
                  all = FALSE, allow.cartesian = TRUE) %>%
    .[, .(avg_temp_repl = sum(temp * weight) / sum(weight)),
      .(type, region, replicate)]
  
  # merge and compute standard errors
  out =
    merge(
      pe_repl, 
      pe, 
      by = c('region', 'type')
    ) %>%
    .[, .( avg_temp = avg_temp[1],
           se = 2 * sqrt( mean( {avg_temp_repl - avg_temp}^2 ) ) 
    ), 
    .(type, region)]
  
  # comptue upper and lower confidence bounds
  out[, `:=`( lwr = avg_temp - qnorm(.975) * se, 
              upr = avg_temp + qnorm(.975) * se ) ][]
  
  out
  
}

if ( debug == TRUE ) {
  avg_temp_by_type_region = recs_mean_brr1(recs_long, weights_long, on = 'id')
}

# version 2, allow the grouping variables to change: ---------------------------
recs_mean_brr2 = function(dt, weights_long, on = 'id', by = NULL) {
  # compute weighted mean of "temp" by type and region and then compute
  # standard errors and 95% confidence bounds using
  #
  # Inputs: dt - a data.table with reference data from which to compute
  #              weighted means of various variables
  #         weights_long - a data.table with each row one replicate weight for
  #                        each household in "dt"
  #         on - a character vector identifying the common variable in dt
  #              and weights long on which to join the two
  #         by - a character vector identifying the variables in dt on which 
  #              to group
  # 
  # Output: a data.table with each row giving the average temperature for a type
  #         and a region along with its standard error and 95% confidence bound
  #         compute using the replicate weight method.
  
  # error checking
  stopifnot( is.data.table(dt) & is.data.table(weights_long) )
  stopifnot( all( on %in% names(dt) ) & all( on %in% names(weights_long)) )
  stopifnot( all( by %in% names(dt) ) )
  
  # point estimates
  pe = dt[ , .(avg_temp = sum(temp * weight) / sum(weight)) , by = by]
  
  # replicate estimates
  pe_repl = merge(weights_long, dt[, !"weight"], by = on,
                  all = FALSE, allow.cartesian = TRUE) %>%
    .[, .(avg_temp_repl = sum(temp * weight) / sum(weight)),
      .(type, region, replicate)]
  
  # merge and compute standard errors
  out =
    merge(
      pe_repl, 
      pe, 
      by = by
    ) %>%
    .[, .( avg_temp = avg_temp[1],
           se = 2 * sqrt( mean( {avg_temp_repl - avg_temp}^2 ) ) 
    ), 
    by]
  
  # comptue upper and lower confidence bounds
  out[, `:=`( lwr = avg_temp - qnorm(.975) * se, 
              upr = avg_temp + qnorm(.975) * se ) ][]
  
  out
  
}

if ( debug == TRUE ) {
  avg_temp_by_type_region = 
    recs_mean_brr2(recs_long, weights_long, by = c('type', 'region'))
}

# version 3, make the names of target, weight, and replicate programmable: -----
recs_mean_brr3 = function(dt, weights_long, on = 'id', by = NULL,
                          target, weight = 'weight', replicate = 'replicate'
                          ) {
  # compute weighted mean of "temp" by type and region and then compute
  # standard errors and 95% confidence bounds using
  #
  # Inputs: dt - a data.table with reference data from which to compute
  #              weighted means of various variables
  #         weights_long - a data.table with each row one replicate weight for
  #                        each household in "dt"
  #         on - a character vector identifying the common variable in dt
  #              and weights long on which to join the two
  #         by - a character vector identifying the variables in dt on which 
  #              to group
  #         target - a length one character vector identifying the variable in
  #                  dt to summarize
  #         dt_weight_var - the name of the weight variable in dt
  #         wl_weight_var - the name of the weight variable in weights_long
  #         replicate - the name of the column grouping the replicate weights in
  #                     weights_long
  #              
  # 
  # Output: a data.table with each row giving the average temperature for a type
  #         and a region along with its standard error and 95% confidence bound
  #         compute using the replicate weight method.
  
  # error checking
  stopifnot( is.data.table(dt) & is.data.table(weights_long) )
  stopifnot( all( on %in% names(dt) ) & all( on %in% names(weights_long)) )
  stopifnot( all( by %in% names(dt) ) )
  stopifnot( dt_weight_var %in% names(dt) )
  stopifnot( all( c(wl_weight_var, replicate) %in% names(weights_long) ) )
  
  # point estimates
  pe = dt[ , .(avg_temp = sum(temp * weight) / sum(weight)) , by = by]
  
  # replicate estimates
  pe_repl = merge(weights_long, dt[, !"weight"], by = on,
                  all = FALSE, allow.cartesian = TRUE) %>%
    .[, .(avg_temp_repl = sum(temp * weight) / sum(weight)),
      .(type, region, replicate)]
  
  # merge and compute standard errors
  out =
    merge(
      pe_repl, 
      pe, 
      by = by
    ) %>%
    .[, .( avg_temp = avg_temp[1],
           se = 2 * sqrt( mean( {avg_temp_repl - avg_temp}^2 ) ) 
    ), 
    by]
  
  # comptue upper and lower confidence bounds
  out[, `:=`( lwr = avg_temp - qnorm(.975) * se, 
              upr = avg_temp + qnorm(.975) * se ) ][]
  
  out
  
}

if ( debug == TRUE ) {
  avg_temp_by_type_region = 
    recs_mean_brr2(recs_long, weights_long, by = c('type', 'region'))
}

