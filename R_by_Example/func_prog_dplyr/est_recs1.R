est_recs = function(df, weights, fay = .5, m = qnorm(.975), 
                    ci_format = '%4.1f (%4.1f, %4.1f)'){
  # function to compute the weighted mean sum(w*x)/sum(w) in df
  # and it associated standard error using replicate weights in weights
  #
  # Args:
  #  weights: a tibble with columns: id, repl, w
  #  df: a (possibly grouped) tibble with columns: id, w, x
  #  m: a multipler for computing a confidence interval: xbar +/- m*se
  #
  # Details: The weighted sum of `x`` in `df`` is first computed and then its
  # standard error is found by joining against the replicate weights `weights`
  # and recomputing for each unique value of `repl`
  #
  # Returns: 
  #  A tibble with columns:
  #   - est: weighted mean of column "x"
  #   - se:  standard error determined by replicate weights and Fay coefficient
  #   - ci:  est +/- m*se
  
  # Point estimate
  pe = df %>% summarize(est = sum(w*x)/sum(w))
  
  # Replicate estimates
  pe_r = df %>% 
    select(-w) %>%
    left_join( weights, by = 'id' )
  
  pe_r = pe_r %>% 
    group_by(repl, add=TRUE) %>%
    summarize( r = sum(w*x)/sum(w))

  # Join to point estimate
  if( is_grouped_df(df) ){
    pe_r = pe_r %>% 
      left_join(pe, by = as.character( groups(df) ) )
  } else {
    pe_r = pe_r %>% mutate(est = pe$est)
  }

  # Compute std error and confidence interval
  pe_r %>%
    summarize( est = est[1], 
               se = 1/fay * sqrt( mean( {r - est}^2 ) )
    ) %>%
    mutate( ci = sprintf(ci_format, est, est - m*se, est + m*se) )

}


#est_recs(df %>% mutate(x = 100*x), weights)
