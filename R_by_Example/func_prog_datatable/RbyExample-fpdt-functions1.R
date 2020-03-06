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
                        
