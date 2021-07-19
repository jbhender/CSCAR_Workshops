# R's data.frame class 
#
# Updated: September 6, 2020
# Author: James Henderson
# 79: -------------------------------------------------------------------------

# constructor: ----------------------------------------------------------------
df = 
  data.frame( 
    id = 1:10,
    group = sample(0:1, 10, replace = TRUE),
    var1 = rnorm(10),
    var2 = seq(0, 1, length.out = 10),
    var3 = rep(c('a', 'b'), each = 5)
  )

# attributes: -----------------------------------------------------------------
names(df)
colnames(df)
dim(df)
length(df)
nrow(df)
ncol(df)
row.names(df)
class(df)

class(df$var3)
class(df$var1)

# subset like a list: ---------------------------------------------------------
df$id
df[['var3']]

# subset like an array: -------------------------------------------------------
df[1:5, ]
df[, 'var2']

# key property of the data.frame class: ---------------------------------------
lapply(df, length)

# 79: -------------------------------------------------------------------------
