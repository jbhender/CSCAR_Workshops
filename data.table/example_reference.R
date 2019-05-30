## Quick examples of updating by reference using data.table
##
## These examples are more abstract than practical.
##
## Updated: May 30, 2019
## Author: James Henderson, PhD (CSCAR)

# libraries: ------------------------------------------------------------------
library(tidyverse); library(data.table)

# create a data.frame and tibble/data.table copies for later user: ------------
n = 1e5
df = data.frame( id = 1:n, 
                 x = rnorm(n), 
                 group = sample(LETTERS, n, replace = TRUE)
      )
df$group = as.character(df$group)

dt = as.data.table(df)
tbl = as_tibble(df)


# Let's investigate the structure of these data frames and there locations in
# memory. 
tracemem(df); sapply(df, tracemem)
tracemem(tbl); sapply(tbl, tracemem)
tracemem(dt); sapply(dt, tracemem)

# The := operation in "j" adds columns by reference to a data.table.
dt[ , sign := {-1}^{x < 0}]
tracemem(dt); sapply(dt, tracemem)

# Can also be used as a function, useful for multiple assignments.
dt[ , `:=`( sign = {-1}^{x < 0}, positive = {x > 0}) ][]

# Use := NULL to delete a column by reference.
dt[ , positive := NULL][]

# Did location of list vector with pointers to columns change? 
tracemem(dt); sapply(dt, tracemem)

# Rename group "G" to "g". What happens to location in G?
dt[ group == 'G', group := 'g' ]
tracemem(dt); sapply(dt, tracemem)

# Compare to data.frame
df$sign = {-1}^{df$x < 0}
tracemem(df); sapply(df, tracemem)

df$group[ df$group == "G" ] = "g"

# Compare to tibble
tracemem(tbl); sapply(tbl, tracemem)
tbl = tbl %>% mutate( sign = {-1}^{x < 0} )
tracemem(tbl); sapply(tbl, tracemem)

tbl = tbl %>% mutate( group = ifelse(group == "G", "g", group) )
tracemem(tbl); sapply(tbl, tracemem)

# data.table breaks R's copy on modify semanitcs, so be careful! 
dt2 = dt

dt2[ group == "A", group := "a"]
dt2[ , .N, group][ order(group) ]
dt[ , .N, group][ order(group) ]

# Use copy to avoid affecting columns with multiple pointers. 
dt3 = copy(dt)
dt3[ group == "B", group := "b"]
dt3[ , .N, group][ order(group) ]
dt[ , .N, group][ order(group) ]
