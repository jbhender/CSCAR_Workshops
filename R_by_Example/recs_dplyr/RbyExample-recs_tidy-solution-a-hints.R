#'---
#' title: "R by Example: Analyzing RECS using Tidyverse (Solution a)"
#' author: James Henderson, CSCAR
#' date: "`r format.Date( Sys.Date(), '%B %d, %Y')`"
#' output:
#'   html_document:
#'     theme: "united"
#'     toc: true
#'     toc_depth: 2
#'     code_folding: hide
#'---

#' ## Step 1 - Header and libaries
#' Before beginning, state your goals and use a header to document our work.
#' 
#'  1. Open the template script 
#'  1. Update the title, description, author, and date information.
#'  1. Use `library` to add `"tidyverse"` to the search path. 

#' Here is an example header. 
#+ r_header
# R by Example: Analyzing RECS using the Tidyverse
# Solution to participant example (a)
#
# In this script, you will use the 2015 RECS data to examine 
# how thermostat behavior impacts the difference between day and night
# temperatures in winter, while someone is home. 
#
# Specifically, this sript estimates the national average temperatures, in homes
# that use space heating, during the day when someone is home and at night for
# homes grouped by thermostat behavior.
#
# Data Source:
# https://www.eia.gov/consumption/residential/data/2015/index.php?view=microdata
#
# Updated: January 30, 2020
# Author: James Henderson
# 80: --------------------------------------------------------------------------

#' Always load libraries at the top of your script.
#+ libraries, message = FALSE, warning = FALSE
# libraries: -------------------------------------------------------------------
library(tidyverse)

#' ## Step 2 - Read data
#' ### Read data
#' First, read the data using a flag to decide whether to read from the url
#' or a local file. 
#' 
 
#+ data_reading, message = FALSE
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

#' ## Step 3 - Prepare Data
#' ### Select and format variables
#' Next, format the data for analysis (as `recs_core`) by selecting key variables and giving
#' them names that are easy for you to remember and type. My convention is to
#' always use `snake_case` and lower case. Below are what the first few rows of 
#' the solution look like. 
#' 
#' For this section you'll want to use `transmute()` or `selct()` followed
#' by `mutate()`. To add labels, use `factor()`. 
#' 
#' Here are the core variables we'll need:
#' 
#'   - DOEID (`id`)
#'   - NWEIGHT (`weight`)
#'   - HEATHOME (`heat_home`)
#'   - EQUIPMUSE (`therm`)
#'   - TEMPHOME (`temp_home`)
#'   - TEMPNITE (`temp_night`).

#+ data_prep
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
                        'Other'
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

recs_core

#' ### Filter cases
#' Reduce `recs_core` to those cases/homes that use space heating in winter.

#+ filter
# filter cases to those that use space heating in winter: ----------------------

## shows why we want to do this, temps are missing if space heating not used
#recs_core %>% 
#  filter(heat_home == 'No') %>%
#  summarize_all( .funs = function(x) sum(is.na(x)) )
recs_core = filter(recs_core, heat_home == 'Yes')

#' ### Replicate Weights
#' Finally, set aside the replicate weights for later use and pivot them to
#'  a longer format using `pivot_longer()`:
#'  
#'   - DOEID (`id`)
#'   - BRRWT1-BRRWT96

#+ replicate_weights
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

weights_long

#' ## Step 3 - Point Estimates
#' In this analysis, the first step is to form point estimates of the average
#' national day with someone home and night temperatures. Do that by forming
#' weighted (NWEIGHT/`weight`) means of these temperatures (TEMPHOME/`temp_home`,
#' TEMNITE/`temp_night`) by group (EQUIPMUSE/`therm`). 
#' 
#' To produce the plot at the end of this analysis, we'll want the temperatures
#' in a longer format -- this is a good time to achieve that using
#'  `pivot_longer()`.

#+ point_estimates

# point estimates for winter temperatures by thermostat behavior: --------------

## method 1, manually type out each temperature type
temps_by_therm = 
  recs_core %>% 
  group_by(therm) %>%
  summarize( 
    avg_temp_home = sum(temp_home * weight) / sum(weight),
    avg_temp_night = sum(temp_night * weight) / sum(weight)
  )

## method 2, pivot to a longer format
temps_by_type_therm =
  recs_core %>%
  pivot_longer( 
    cols = starts_with('temp'),
    names_to = 'type',
    names_prefix = 'temp_',
    values_to = 'temp'
  ) %>%
  group_by(type, therm) %>%
  summarize( avg_temp = sum(temp * weight) / sum(weight) )

temps_by_type_therm

#' ### Step 5 - Replicate Estimates

#' Recall that this is survey data and not an identically distributed sample of
#' US households. As such, to estimate standard errors we will use the replicate
#' weights method in which we repeatedly recomptue the estimates from step 4, 
#' each time replacing NWEIGHT/`weight` with one of the 96 replicate weights. 
#' To do this efficiently:
#' 
#'  1. Create a dataset where each row is a home (id), 
#'  temperature type, and replicate weight. This dataset will have 96 rows for
#'   each row of the dataset in step 4. To do this, join the longer format
#'    weights from step 1 with the dataset from step 4.
#'  1. Next, re-compute point estimates for each set of replicate weights. To do
#'  this, re-use the code from step 4 and add the identifier for the replicate
#'  weights to the `group_by` statement.
#' 
#' The result should have rows giving the weighted average temperature for each 
#' unique combination of thermostat behavior, temperature type, and set 
#' of replicate weights. 

#+ replicate_estimates
# replicate winter temperature estimates, for standard errors: -----------------

## 6 therm values, 2 types, 96 replicate weights = 1152 rows
temps_by_type_therm_repl =
  ### each row is a temperature type for a single home
  recs_core %>%
  select(id, therm, starts_with('temp_') ) %>%
  pivot_longer( 
    cols = starts_with('temp'),
    names_to = 'type',
    names_prefix = 'temp_',
    values_to = 'temp'
  ) %>%
  ### join with repliacte weights, each previous row is now 96 rows
  left_join( weights_long, by = c('id') ) %>%
  group_by(type, therm, replicate) %>%
  summarize(  avg_temp_repl = sum(temp * weight) / sum(weight) )
temps_by_type_therm_repl

#' ## Step 6 - Standard Errors and confidence bounds
#' Once we have the replicate estimates for our quantities of interest, we
#' estimate the variance of the point estimates from step 4 using the sum of
#' squared deviations of the replicate estimates around the original point
#' estimates, scaling up by a factor determined in the process of formulating
#' the replicate weights. The standard error is the square root of this
#' variance estimate.
#' 
#' To accomplish this:
#' 
#'  1. Join the point estimates from step 4 with the replicate estimates
#'    from step 5.
#'  1. Estimate the standard error for each point estimate, using the same
#'   grouping structure as used in step 4 to form the point estimates.
#'  1. Add columns `lwr` and `upr` for, respectively, the lower and upper 95% 
#'  confidence bounds using the point estimate +/- $\Phi^{-1}(.975)$ (or 1.96) 
#'  times the standard error.

#+ std_errors
# compute standard errors and CIs: ---------------------------------------------
## 1. Join replicate and point estimates
## 2. Compute std error using scaled RMSE of replicates around point estimates
## 3. Form confidence intervals using standard methods

## Refer to the link below for std error computations, see page 3
## the standard error is the square root of the variance estimate
## https://www.eia.gov/consumption/residential/data/2015/pdf/microdata_v3.pdf

avg_temp_by_type_therm =
 left_join(
   temps_by_type_therm_repl, 
   temps_by_type_therm, 
   by = c('therm', 'type')
 ) %>%
 group_by(type, therm) %>%
 summarize( 
   avg_temp = avg_temp[1], # point estimate: unique(avg_temp), first(avg_temp) 
   se = 2 * sqrt( mean( {avg_temp_repl - avg_temp}^2 ) ) 
 ) %>%
 mutate( lwr = avg_temp - qnorm(.975) * se, upr = avg_temp + qnorm(.975) * se )

#' ## Step 7 - Plot the results
#' Create a plot of the results using ggplot2 and following the template from
#' the example.
#'

#+ visualize
# visualize the results: -------------------------------------------------------
avg_temp_by_type_therm %>%
  mutate( `Winter Temperature` = 
            factor(type, 
                   levels = c('home', 'night'),
                   labels = c('when someone is home during the day',
                              'at night'
                            )
            )
  ) %>%
  ggplot( aes(y = avg_temp, x = therm, color = `Winter Temperature`) ) +
    geom_point( position = position_dodge(width = 0.2)) +
    geom_errorbar( aes(ymin = lwr, ymax = upr), 
                   width = .1, position = position_dodge(width = 0.2)
    ) +
    theme_bw() +
    # w/o coord_flip below, may want to rotate labels
    #theme( axis.text.x = element_text(angle = 90) ) + 
    xlab('Thermostat Behavior') +
    ylab('Average Temperature, ºF') +
    scale_color_manual( values = c("darkred", "orange") ) +
    coord_flip() 
