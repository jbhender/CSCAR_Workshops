# Using .SD and .SDcols in data.table
#
# In this example, we use the special symbol .SD and the related data.table 
# argument .SDcols to faciliate finding the MLB team leaders in each of a number
# of categories.  In the process, we also touch on adding columns by reference
# and efficient reshaping using the "melt" and "dcast" methods for data.tables.
#
# Updated: May 30, 2019
# Author: James Henderson, PhD (CSCAR)

# Packages: -------------------------------------------------------------------
library(tidyverse)
library(dbplyr)
library(Lahman)
library(data.table)
#lapply( c('tidyverse', 'dbplyr', 'Lahman', 'data.table'), install.packages)

# Create a local SQLlite database of the Lahman data: ----------------------
lahman = lahman_sqlite()

# Copy the batting table to memory as a tibble: -------------------------------
batting_tbl = lahman %>% 
  tbl("BATTING") %>% 
  collect()

# Convert the copy in memory to a data.table: ---------------------------------
batting_dt = as.data.table(batting_tbl)

# Goal: Find the teams which led each leauge in the following categories
#       for each year from 2010-2016.
categories = c('HR', 'RBI', 'R', 'BB', 'SB', 'SO')

## Step 1, find team totals for each category by year.
team_totals = 
  batting_dt[ yearID %in% 2010:2016, lapply(.SD, sum), 
              keyby = .(yearID, lgID, teamID), .SDcols = categories]

## Step 2, find maximum values for each year, league, and category.
team_max = 
  team_totals[ , lapply(.SD, max), .(yearID, lgID), .SDcols = categories]

## Step 3, reshape data to long format
team_max_long = 
  melt(team_max, id.vars = c('yearID', 'lgID'), 
                 variable.name = 'stat', value.name = 'max')

## Step 4, remerge teamID

### Reshape team totals to re-merge.
### We rename "total" to "max" to facilitate merging.
team_totals_long = 
  melt(team_totals, id.vars = c('yearID', 'lgID', 'teamID'),
       variable.name = 'stat', value.name = 'max')

team_max_long = 
  merge(team_max_long, team_totals_long, by = c('yearID', 'lgID', 'stat', 'max'),
      all.x = TRUE)

## Note dimensions.
#length(categories) * 7 * 2
team_max_long[ , .N, keyby = .(yearID, lgID, stat)][N > 1]

## Two alternatives to steps 2-4. 

### Rename "max" to "total" for clarity
setnames(team_totals_long, c( names(team_totals_long)[1:4], 'total' ) ) 

### This is similar to a "having" approach in SQL
team_max_long =
  team_totals_long[ , .(teamID, max = max(total), total = total), 
                  .(yearID, lgID, stat) ] %>% 
  .[ total == max, !"total" ]

### Similar approach, but add max by reference prior to subsetting.
team_totals_long[ , max := max(total), .(yearID, lgID, stat)]
team_max_long = team_totals_long[ total == max, -"total" ]

## Step 5, aggregrate ties
team_max_long[ , .(teamID = paste(teamID, collapse='/'), max = unique(max)),
               .(yearID, lgID, stat)]

## Step 6, organize into a nicer form for viewing
team_max_wide = 
  team_max_long %>%
  dcast(stat + yearID ~ lgID, value.var = c('teamID', 'max'))


# SQL approach (w/o pivoting): ------------------------------------------------
## Here is an SQL approach for a single statistic.
query = 
'
SELECT yearID, lgID, teamID, max(SO) M
FROM (
 SELECT yearID, lgID, teamID, sum(SO) as SO
 FROM batting
 WHERE yearID > 2009
 GROUP BY yearID, lgID, teamID
) 
GROUP BY yearID, lgID
HAVING M == SO
'

lahman %>%
  tbl(sql(query)) %>%
  collect()

# dplyr approach: -------------------------------------------------------------
mc = categories
names(mc) = paste0('max_', mc)

teams_max_long_tbl = 
  batting_tbl %>%
  filter( yearID >= 2010 ) %>%
  group_by( yearID, lgID, teamID) %>%
  summarize_at(.vars = categories, .funs = 'sum') %>%
  gather(key = 'stat', value = 'total', HR:SO) %>%
  group_by( yearID, lgID, stat) %>%
  mutate( max = max(total) ) %>%
  filter( total == max ) %>%
  summarize( teamID = paste(teamID, collapse='/'), max = unique(max) ) %>% 
  ungroup() 

teams_max_long_tbl %>%
  select(yearID, lgID, stat, m = max) %>%
  spread( lgID, value = m) %>%
  arrange(stat, yearID)
