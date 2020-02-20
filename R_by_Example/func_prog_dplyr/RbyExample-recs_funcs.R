# R by Example: Functional programming with dplyr
# Functions from our initial adaptation. 
#
# Updated: Februrary 20, 2020
# Author: James Heneerson

# function for pattern 1, decoding factor variables: ---------------------------
decode_recs = function(x, var, codebook = codes ) {
  # transform a recs variable into a factor with labels as given in 
  # the codebook under "Final Response Set".
  # Inputs:
  #  x - a vector of factor levels to be decoded, e.g. a column in recs data
  #  var - a length 1 character vector with names to be decoded
  #  codes - the codebook in which factor levels & labels are found as columns
  #           with those names and a row for which column "variable" matches 
  #           xname
  # Returns: x, transformed to a factor
  
  #if ( xname %in% codes$variable ) {
  #  cat('ok\n')
  #labels = codes[ codes$variable == xname, ]$labels[[1]]
  #levels = codes[ codes$variable == xname, ]$levels[[1]]
  #factor(x, levels = levels, labels = labels)
  #} 
  if ( var %in% codebook$variable ) {
    labels = codebook[ codebook$variable == var, ]$labels[[1]]
    levels = codebook[ codebook$variable == var, ]$levels[[1]]
    factor(x, levels = levels, labels = labels)
  } else {
    msg = sprintf('There is no variable "%s" in the supplied codes.\n', var)
    stop(msg)
  }
}

## add_groups
add_groups = function(df, group = NULL) {
  # adds grouping variables to a data.frame and/or tibble
  # Inputs: 
  #   df - an object inheriting from the data.frame class, commonly a tibble
  #   group - (optional, defaults to NULL) a character vector of column
  #    names in df to form grups by.
  
  if ( !is.null(group) ) {
    stopifnot( all(group %in% names(df) ) )
    if ( length(group) == 1 ) {
      df = group_by(df, .data[[ !!group ]])
    } else {
      df = ungroup(df)
      for ( i in 1:length(group) ) {
        df = group_by(df, .data[[ !!group[i] ]], add = TRUE)
      }
    }
  }

  df 
}
# add_groups(df, c('region', 'type'))

recs_mean = function(df, vars, group = NULL) {
  # Inputs
  #  df: a (possibly grouped) tibble or data.frame object to be summarized
  #      df must have a variable 'weight' for the weighted sums. 
  #  vars: a character vector of numeric variables in 
  #  group: a character vector with variable names to group by. If 
  #         NULL (the default) retains an group structure of `df` as passed.
  #
  # Outputs: a tibble with one row (per group) as returned by summarize_at
  
  # add group structure
  df = add_groups(df, group)
  
  # summarize using weighted mean
  summarize_at(df, .vars = vars, .funs = ~ sum(. * weight) / sum(weight) )    
}

recs_mean_brr = function(df, weights_long, vars, by = 'id', group = NULL,
                          level = .95) {
  # Inputs
  #  df: a (possibly grouped) tibble or data.frame object to be summarized
  #      df must have a variable 'weight' for the weighted sums. 
  #  weights_long: long format replicate weights, will be merged with df
  #     using 'by' and should also have names 'replicate' and 'weight'
  #  by: variables common to df and weigths_long to merge on
  #  var: a character vector of numeric variables to be summarized 
  #  group: a character vector with variable names to group by. If 
  #         NULL (the default) retains an group structure of `df` as passed.
  #
  # Outputs: a tibble with one row (per group) as returned by summarize_at
  
  ## point estimates
  pe = recs_mean(df, vars, group)
  
  ## replicate estimates
  if ( is.null(group) ) {
    group1 = c(groups(df), 'replicate')
    group0 = groups(df)
  } else {
    group1 = c(group, 'replicate')
    group0 = group
  }
  
  re = left_join(
    ungroup(df) %>% select( -weight), 
    weights_long,
    by = by ) %>%
    recs_mean(df = ., vars = vars, group = group1) %>%
    rename_at(.vars = vars, .funs = function(x) paste0(x, '_repl'))

  ## standard errors 
  
  ### revert to base R for differencing
  re = left_join(pe, re, by = c(group0))
  for ( v in vars ) {
    re[[v]] = re[[v]] - re[[ paste0(v, '_repl') ]]
  }
  
  se = re %>%
    add_groups(group = group0) %>%
    summarize_at( 
      .vars = vars,
      .funs = list(
        se = ~ 2 * sqrt( mean( {.}^2 ) )
      )
    )

  ## confidence bounds
  out = left_join(pe, se, by = group0)
  m = qnorm( 1 - {1 - level}/2 )
  for ( v in vars ) {
    lwr = paste0(v, '_lwr')
    upr = paste0(v, '_upr')
    if ( length(vars) > 1) {
      se = paste0(v, '_se')
    } else {
      se = 'se'
    }
    out = mutate(out, !!lwr := .data[[!!v]] - !!m * .data[[!!se]],
                      !!upr := .data[[!!v]] + !!m * .data[[!!se]]
                 )
  }

  ## rearrange variable order if more than one summarized
  if( length(vars) > 1) {
    var_order = group0
    for (v in vars) {
      var_order = c(var_order, grep(v, names(out), value = TRUE))
    }
    
    out = out[var_order]
  }
  
  out
}
#recs_mean_brr(df, weights_long, vars = 'temp', 
#              by = 'id', group = c('region', 'type'))

#recs_mean_brr(recs_core, weights_long,
#              vars = c('temp_home', 'temp_gone', 'temp_night'),
#              by = 'id', group = c('region'))
