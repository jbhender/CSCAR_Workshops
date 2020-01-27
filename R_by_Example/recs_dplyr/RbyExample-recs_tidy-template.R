# [Descriptive title]
# 
#
# [Brief description] 
#
# Data Source:
# https://www.eia.gov/consumption/residential/data/2015/index.php?view=microdata
#
# Updated: [today's date]
# Author: [your name and, maybe, email]
# 80: --------------------------------------------------------------------------

# libraries: -------------------------------------------------------------------
## [use install.packages("tidyverse") if needed]
## [delete this and load the tidyverse]

# data: ------------------------------------------------------------------------

# clean up key variables used in this analysis: --------------------------------

# replicate weights, for computing standard errors: ----------------------------
## pivoted to a longer format to facilite dplyr "vectorization"

# filter cases to those that use space heating in winter: ----------------------

# point estimates for winter temperatures by region: ---------------------------

# replicate winter temperature estimates, for standard errors: -----------------

# compute standard errors and CIs: ---------------------------------------------
## 1. Join replicate and point estimates
## 2. Compute std error using scaled RMSE of replicates around point estimates
## 3. Form confidence intervals using standard methods

## Refer to the link below for std error computations, see page 3
## the standard error is the square root of the variance estimate
## https://www.eia.gov/consumption/residential/data/2015/pdf/microdata_v3.pdf


# visualize the results: -------------------------------------------------------
