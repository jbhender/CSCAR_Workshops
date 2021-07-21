# RECS data frame methods example
# 
# Author: James Henderson
# Updated: July 20, 2021
# 79: -------------------------------------------------------------------------

# import data: ----------------------------------------------------------------
url_path = 'https://www.eia.gov/consumption/residential/data/2015/csv/'
file = 'recs2015_public_v4.csv' 
url = paste0(url_path, file)
dt = read.table(url, header = TRUE, sep = ',')

# select core variables: ------------------------------------------------------
vars = c(
  'DOEID', 
  'NWEIGHT', 
  'REGIONC', 
  'HEATHOME', 
  'TEMPHOME', 
  'TEMPGONE', 
  'TEMPNITE'
)
clean_names = 
  c('id', 'weight', 'region', 'heathome', 't_home', 't_gone', 't_night')
dt_core = dt[, vars]
names(dt_core) = clean_names
#head(dt_core)

# limit to homes that are heated: ---------------------------------------------
#with(dt_core, table(heathome))
dt_core = subset(dt_core, heathome == 1)
#dim(dt_core)

# using a pipe, for R version > 4.1
dt_core = dt_core |> subset(heathome == 1)

# find weighted average temperatures by region: -------------------------------

## use "re-merging" to get total weight by region 
region_w = aggregate(weight ~ region, data = dt_core, sum)
names(region_w)[2] = 'tot_weight'
dt_core = merge(dt_core, region_w, by = 'region')
dt_core[['w']] = with(dt_core, weight / tot_weight)

## use aggregate to compute weighted sums 
temp_est = aggregate(
  cbind(
    t_home = t_home * w, 
    t_gone = t_gone * w, 
    t_night = t_night * w
  ) ~ region,
  data = dt_core,
  sum
)

# compute standard errors using the balanced repeated replicate weights: ------

## collect replicate weights and ids
brr_cols = grep('^BRR', names(dt), value = TRUE)
weights = dt[, c('DOEID', brr_cols)]
weights[1:5, c(1:2, 97)]

## reshape to a "longer" format so we can aggregate by group
weights_long = 
  reshape(
    weights, 
    direction = 'long',
    varying = brr_cols,
    idvar = 'DOEID',
    sep = '',
    timevar = 'repl'
  )
names(weights_long) = c('id', 'repl', 'brrwt')
#head(weights_long)
#subset(weights_long, DOEID == 10001 & repl == 96)
#dim(weights_long)
#length(brr_cols) * nrow(dt)

## merge temps with long format weight for group aggregation
#dt_long = merge(dt_core, weights_long, by = 'id')
#dim(dt_long)
#nrow(dt_core) * length(brr_cols)
#head(dt_long)

## now aggregate by region and replicate weight group
region_long_w = aggregate(brrwt ~ region + repl, data = dt_long, sum)
names(region_long_w)[3] = 'tot_brrwt'
dt_long = merge(dt_long, region_long_w, by = c('region', 'repl'))
dt_long[['w_brrwt']] = with(dt_long, brrwt / tot_brrwt)

## use aggregate to sum replicate weighted temps
temp_repl = aggregate( 
  cbind(
    t_home_repl = t_home * w_brrwt,
    t_gone_repl = t_gone * w_brrwt,
    t_night_repl = t_night * w_brrwt
  ) ~ region + repl,
  data = dt_long, 
  sum
)
#head(temp_repl)

## compute dispersion of replicate estimates around original point estimate
temp_repl = merge(temp_repl, temp_est, by = 'region')
fay = 1 / (1 - 0.5)^2
head(temp_repl)

temp_var = aggregate( 
  cbind(
    v_home = (t_home_repl - t_home)^2 * fay,
    v_gone = (t_gone_repl - t_gone)^2 * fay,
    v_night = (t_night_repl - t_night)^2 * fay
  ) ~ region,
  data = temp_repl, 
  mean
)

# merge point and variance estimates and form confidence intervals: -----------
temp_var = merge(temp_est, temp_var, by = 'region')
z = qnorm(.975)
ci_template = '%4.1f (%4.1f, %4.1f)'

temp_ci = 
  within(temp_var,
         {
           home_lwr = t_home - z * sqrt(v_home)
           home_upr = t_home + z * sqrt(v_home)
           
           gone_lwr = t_gone - z * sqrt(v_gone)
           gone_upr = t_gone + z * sqrt(v_gone)
           
           night_lwr = t_night - z * sqrt(v_night)
           night_upr = t_night + z * sqrt(v_night)
           
           ci_home = sprintf(ci_template, t_home, home_lwr, home_upr)
           ci_gone = sprintf(ci_template, t_gone, gone_lwr, gone_upr)
           ci_night = sprintf(ci_template, t_night, night_lwr, night_upr)
         }
  ) |> # this is a pipe
  subset(select = c('region', 'ci_home', 'ci_gone', 'ci_night'))

# change region to factor: ----------------------------------------------------
# Refer to the code book at:
 # https://www.eia.gov/consumption/residential/data/2015/xls/
 #    codebook_publicv4.xlsx
temp_ci[['region']] = 
  with(temp_ci, 
       factor(region, 1:4, labels = c('Northeast', 'Midwest', 'South', 'West'))
  )

# 79: -------------------------------------------------------------------------
