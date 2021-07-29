# R Short Course, Part 2
# Exercise Set 2
# 
# Using data from the 2009 RECS, compare the percentage of homes with
# internet access between urban and rural areas.
# 
# Author: <your name here>
# Updated: <today's date here>
# 79: -------------------------------------------------------------------------

# data: -----------------------------------------------------------------------

## core data
path = 'https://www.eia.gov/consumption/residential/data/2009/csv/'
file = 'recs2009_public.csv'
url = paste0(path, file)
recs_all = read.table(url, sep = ',', header = TRUE, skip = 0)

## replicate weights
file_w = 'recs2009_public_repweights.csv'
url_w = paste0(path, file_w)
weights = read.table(url_w, sep = ',', header = TRUE)
weights[['NWEIGHT']] = NULL  # we don't need this one
names(weights)[1] = 'id'

# key variables for analysis: -------------------------------------------------
vars = c(
  id = 'DOEID',          # Unique ID for each home
  weight = 'NWEIGHT',    # Sample weight
  urban = 'UR',          # Urban (U) or Rural (R)
  internet = 'INTERNET'  # Internet access at home, 1 = Yes, 0 = No, -2 = NA
)

# <4a - create recs from recs_all, selecting only the variables in vars>
# <4b - use the names of vars as the names of recs> 

# subset to homes to which internet is applicable: ----------------------------
# internet < 0 is not-applicable
# <5 - subset to cases with internet = 0 or 1.>

# point estimates: ------------------------------------------------------------

## total weights by urban
# <6a - use aggregate to sum weight within levels of urban>
# <6b - name the summed weight variable `total_weight`>

## re-merge and compute weights normalized by group
# <6c - merge the total weights above into recs, merging on `urban`>
# <6d - compute the normalized weights>

## point estimates
# <7 - use aggregate to compute the percentage of homes with home internet
#      access within levels of urban>

# pivot weights to long for variance estimation: ------------------------------
brr_cols =  grep('^brr', names(weights), value = TRUE)

weights_long = 
  reshape(
    weights, 
    direction = 'long',
    varying = brr_cols,
    idvar = 'id',
    sep = '_weight_',
    timevar = 'repl'
  )
stopifnot( dim(weights_long)[1] == (nrow(recs_all) * length(brr_cols)) )

# variance estimation: --------------------------------------------------------
fay = 1 / (1 - 0.5)^2

## merge to facilitate replicate estimates
# <9 - merge recs and replicate weights>

## normalize replicate weights
# <10a - use aggregate to sum the replicate weights within levels of
#        urban and repl>
# <10b - call the summed replicate weights total_brr>
# <10c - merge the summed replicate weights with the long data from step 9>
# <10d - create a column `brr_w` of normalized weights>

## replicate estimates
# <11 - use aggregate to compute replicate estimates of the percent of homes
#       with home internet access (similar to step 7)

## variance estimates
# <12 - merge the replicate estimates and the point estimates>

# <13 - compute the variance as the mean squared deviation of the replicate
#       estimates from the point estimates, times the Fay adjustment, within
#       levels of urban>
# confidence intervals: -------------------------------------------------------
# <14 - merge the variance and point estimates into a single data frame>
z = qnorm(0.975)

#<15 - use `within()` to create lower and upper bounds for the 95% CI as 
#      point estimate +/- z * se, where the standard error se is the square 
#      root of the variance from step 13 and z is given above.> 

# 79: -------------------------------------------------------------------------
