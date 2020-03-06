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
# Updated: March 5, 2020
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
if ( debug == TRUE ) recs_mean0(recs_long)

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
if ( debug == TRUE ) recs_mean1(recs_long)

## make grouping variable programmable
recs_mean2 = function(dt, by = NULL ) {
  # computes the weighted mean of "temp" using weights given in "weight" and
  # grouped by "type" and "region"
  #
  # inputs: dt - a data.table with columns temp, weight, type, and region
  #         by - a character vector of column names in dt to group by
  # output: a data.table with one row per type/region
  
  ## error checking
  stopifnot( is.data.table(dt) )
  
  stopifnot( 'temp' %in% names(dt) )
  stopifnot( 'weight' %in% names(dt) )
  stopifnot( all( by %in% names(dt) ) ) 
  
  # key computation
  dt[, .(avg_temp = sum(temp * weight) / sum(weight)) , by = by]
}
if ( debug == TRUE )  recs_mean2(recs_long, by = c('type', 'region'))

## make target variable and weight variable programmable
recs_mean3 = function(dt, target, weight = 'weight', by = NULL) {
  # computes the weighted mean of "temp" using weights given in "weight" and
  # grouped by "type" and "region"
  #
  # inputs: dt - a data.table with columns temp, weight, type, and region
  #         target - the column whose (weighted) mean is desired as a 
  #                  length 1 character vector
  #         weight - a length 1 character vector identifying the column
  #                  of weights
  #         by - a character vector of column names in dt to group by
  # output: a data.table with one row per type/region
  
  ## error checking
  stopifnot( is.data.table(dt) )
  stopifnot( length(target) == 1 & length(weight) == 1)
  stopifnot( target %in% names(dt) )
  stopifnot( weight %in% names(dt) )
  stopifnot( all( by %in% names(dt) ) ) 
  
  # key computation
  dt[, 
     .(avg = sum(.SD[[..target]] * .SD[[..weight]]) / sum(.SD[[..weight]])),
     by = by]
}
if ( debug == TRUE ) {
  recs_mean3(recs_long, target = 'temp', weight = 'weight', 
           by = c('type', 'region'))
  recs_mean3(recs, target = 'TEMPHOME', weight = 'NWEIGHT', by = 'EQUIPMUSE')
}

## make name of new variable programmable
recs_mean4 = function(dt, target, weight = 'weight', by = NULL, new_var = NULL) {
  # computes the weighted mean of `target` using weights given in `weight` and
  # grouped by `by`
  #
  # inputs: dt - a data.table
  #         target - the column whose (weighted) mean is desired as a 
  #                  length 1 character vector
  #         weight - a length 1 character vector identifying the column
  #                  of weights
  #         by - a character vector of column names in dt to group by
  #         new_var - when NULL (the default) the new variable will be
  #                   named "avg". If not NULL, should be a length 1
  #                   character vector.
  # output: a data.table with one row per type/region
  
  ## error checking
  stopifnot( is.data.table(dt) )
  stopifnot( is.null(new_var) | {length(new_var) == length(target)} )
  stopifnot( length(target) == 1 & length(weight) == 1)
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
if ( debug == TRUE ) {
 recs_mean4(recs_long, 
           target = 'temp', 
           by = c('type', 'region'),
           new_var = 'avg_temp'
          )
  
 recs_mean4(recs, 
           target = 'TEMPHOME', 
           weight = 'NWEIGHT', 
           by = 'EQUIPMUSE',
           new_var = 'temp_home')
}

## Allow for multiple targets
recs_mean5 = function(dt, target, weight = 'weight', by = NULL, new_var = NULL) {
  # computes the weighted mean of each `target` variable grouped using `by`
  #
  # inputs: dt - a data.table
  #         target - a character vector identifying the columns whose (weighted)
  #                  means are to be computed 
  #         weight - a length 1 character vector identifying the column
  #                  of weights
  #         by - a character vector of column names in dt to group by
  #         new_var - when NULL (the default) the weighted means will retain
  #                   the names of the original variables. If not, must
  #                   be the same length as `target`
  # output: a data.table with one row per type/region and columns for the
  #         weighted mean of each target variable as well group identifiers.
  
  ## error checking
  stopifnot( is.data.table(dt) )
  stopifnot( is.null(new_var) | {length(new_var) == length(target)} )
  stopifnot( all(target %in% names(dt)) )
  stopifnot( weight %in% names(dt) )
  stopifnot( all( by %in% names(dt) ) ) 
  
  # key computation
  cols = c(target, weight)
  out = dt[, lapply(1:{ncol(.SD)-1}, function(i) {
                sum(.SD[[i]]*.SD[[..weight]]) / sum(.SD[[..weight]])}),
           by = by,
           .SDcols = cols]
  
  # adjust names as needed
  if ( is.null(new_var) ) {
    new_names = c(by, target)
  } else {
    new_names = c(by, new_var)
  }
  setnames(out, new_names)
  out
}
if ( debug == TRUE ) {
  recs_mean5( recs_core,
              target = c('temp_home', 'temp_gone', 'temp_night'),
              by = 'region',
              weight = 'weight',
              new_var = c('home', 'gone', 'night')
            )
  
}
