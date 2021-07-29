# R Short Course, Part 2
# Exercise Set 2
# 
# Using data from the 2009 RECS, compare the percentage of homes with
# internet access between urban and rural areas.
# 
# Author: James Henderson
# Updated: July 28, 2021
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
weights[['NWEIGHT']] = NULL  # we  don't need this one
names(weights)[1] = 'id'

# key variables for analysis: -------------------------------------------------
vars = c(
  id = 'DOEID',          # Unique ID for each home
  weight = 'NWEIGHT',    # Sample weight
  urban = 'UR',          # Urban (U) or Rural (R)
  internet = 'INTERNET'  # Internet access at home, 1 = Yes, 0 = No, -2 = NA
)

recs = recs_all[, vars]
names(recs) = names(vars)

# subset to homes to which internet is applicable: ----------------------------
# internet
recs = subset(recs, internet >= 0)

# point estimates: ------------------------------------------------------------

## total weights by urban
ur_w = aggregate(cbind(total_weight = weight) ~ urban, data = recs, sum)

## re-merge and compute weights normalized by group
recs = merge(recs, ur_w, by = 'urban')
recs[['w']] = with(recs, weight / total_weight)

## point estimates
pct_internet_urban = aggregate(
  cbind(pct_internet = 100 * w * internet) ~ urban, data = recs, sum
)

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
recs_long = merge(recs, weights_long, by = 'id')
stopifnot( nrow(recs_long) == (nrow(recs) * length(brr_cols)))

## normalize replicate weights
ur_w_repl = aggregate(
  cbind(total_brr = brr) ~ urban + repl, 
  data = recs_long, 
  sum
)
recs_long = merge(recs_long, ur_w_repl, by = c('urban', 'repl'))
recs_long[['brr_w']] = with(recs_long, brr / total_brr)

## replicate estimates
pct_repl = aggregate(
  cbind(pct_repl = 100 * brr_w * internet) ~ urban + repl, 
  data = recs_long,
  sum
)

## variance estimates
pct_repl = merge(pct_repl, pct_internet_urban, by = 'urban')

pct_var = aggregate(
  cbind(pct_var = (pct_repl - pct_internet)^2 * fay) ~ urban,
  data = pct_repl,
  mean
)

# confidence intervals: -------------------------------------------------------
pct_internet_urban = merge(pct_var, pct_internet_urban, by = 'urban')
z = qnorm(0.975)

pct_internet_urban = 
  within(pct_internet_urban,
         {
           lwr = pct_internet - z * sqrt(pct_var)
           upr = pct_internet + z * sqrt(pct_var)
           pct_ci = sprintf('%4.1f (%4.1f, %4.1f)', pct_internet, lwr, upr)
         }
  )

# 79: -------------------------------------------------------------------------
