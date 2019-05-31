## Code for CSCAR Workshop: Data Management in R with data.table 
## 
## Updated: May 30, 2019
## Author: James Henderson, PhD

# Packages: -------------------------------------------------------------------
library(tidyverse)
library(dbplyr)
library(Lahman)
library(data.table)
#lapply( c('tidyverse', 'RSQLite', 'dbplyr', 'Lahman', 'data.table'), 
#         install.packages)

# Create a local SQLlite database of the Lahman data: ----------------------
lahman = lahman_sqlite()

# Copy the batting table to memory as a tibble: -------------------------------
batting_tbl = lahman %>% 
  tbl("BATTING") %>% 
  collect()
class(batting_tbl)

# Convert the copy in memory to a data.table: ---------------------------------
batting_dt = as.data.table(batting_tbl)
class(batting_dt)

# Select with "j": -----------------------------------------------------------

## data.table
batting_dt[ , .(playerID, yearID, league = lgID, stint)]  

## SQL: SELECT
query = 
  '
SELECT playerID, yearID, lgID as league, stint
FROM BATTING
'
lahman %>% tbl(sql(query)) 

## dplyr: select, rename, transmute
batting_tbl %>%
  transmute(playerID, yearID, league = lgID, stint)

batting_tbl %>%
  select(playerID, yearID, league = lgID, stint)

# Compute with "j": -----------------------------------------------------------

## data.table
batting_dt[ , .(playerID, avg = H / AB)]

## SQL
query = 
'
SELECT playerID, 
       (Cast (H as Float) /  Cast (AB as Float) ) as avg
FROM BATTING
'
lahman %>% tbl(sql(query)) %>% collect()

## dplyr: transmute
batting_tbl %>%
  transmute( playerID, avg = H / AB)

# Aggregate in j: -------------------------------------------------------------

## data.table: aggregate using a valid R expression
batting_dt[, .(max_HBP = max(HBP, na.rm=TRUE))]

## SQL: SELECT with aggregation function
query =
'
SELECT max(HBP) as max_hbp
FROM BATTING
'
lahman %>% tbl(sql(query)) %>% collect()

## dplyr: summarize
batting_tbl %>%
  summarize( max_HBP = max(HBP, na.rm=TRUE))

# Grouping with "by": ---------------------------------------------------------

## data.table: by
#batting_dt[ , .(avg = sum(H) / sum(AB)), by = .(playerID, yearID, lgID)]
batting_dt[ , .(avg = sum(H) / sum(AB)), .(playerID, yearID, lgID)]

## data.table: keyby
# Here the parameter name is required
batting_dt[ , .(avg = sum(H) / sum(AB)), keyby = .(playerID, yearID, lgID)]

##SQL: GROUP BY
query = 
'
SELECT playerID, yearID, lgID,
       ( Cast (sum(H) as Float) / Cast (sum(AB) as Float) ) as avg
FROM BATTING
GROUP BY playerID, yearID, lgID
'
lahman %>% tbl(sql(query)) %>% collect()

## dplyr: group_by
batting_tbl %>% 
  group_by(playerID, yearID, lgID) %>%
  summarize( avg = sum(H) / sum(AB) )

# Select rows in "i": ---------------------------------------------------------

## data.table: logical indexing
batting_dt[ yearID == 2016, .(playerID, HBP)]

## data.table: keys
setkey(batting_dt, 'teamID')
batting_dt['DET', .(playerID, teamID, HBP)]
key(batting_dt)

setkey(batting_dt, 'yearID')
batting_dt[.(2016), .(playerID, yearID, HBP)]

### Compare the difference
batting_dt[2016, .(playerID, yearID, HBP)]

### Remove key for later examples
setkey(batting_dt, NULL)

## SQL: WHERE
query = 
'
SELECT playerID, HBP
FROM BATTING
WHERE yearID = 2016
'
lahman %>% tbl(sql(query)) %>% collect()

## dplyr: filter
batting_tbl %>%
  filter(yearID == 2016) %>%
  select(playerID, HBP)

## base R
batting_tbl[ batting_tbl$yearID == 2016, c("playerID", "yearID", "HBP")]

# chaining: -------------------------------------------------------------------

## data.table: pipes
batting_dt[ yearID > 2000, .(HR = sum(HR)), .(playerID)] %>%
  .[HR > 400]

## data.table: chaining
batting_dt[ yearID > 2000, .(HR = sum(HR)), .(playerID)][HR > 400]

##SQL: nested anonymous table, "HAVING"
query = 
'
SELECT *
FROM (
 SELECT playerID, sum(HR) as HR
 FROM BATTING
 WHERE yearID > 2000
 GROUP BY playerID
) 
WHERE HR > 400
'

## dplyr: Use %>% to chain
batting_tbl %>% 
  filter(yearID > 2000) %>%
  group_by(playerID) %>%
  summarize( HR = sum(HR) ) %>%
  ## Here's the pipe from above
  filter( HR > 400)

# order in "i": ---------------------------------------------------------------

## data.table
batting_dt[ yearID > 2000, .(HR = sum(HR)), .(playerID)][HR > 400][order(-HR)]

## SQL: ORDER BY 
query = 
  '
SELECT *
FROM (
 SELECT playerID, sum(HR) as HR
 FROM BATTING
 WHERE yearID > 2000
 GROUP BY playerID
) 
WHERE HR > 400
ORDER BY -HR
'
lahman %>% tbl(sql(query))  %>% collect()

## dplyr: arrange
batting_tbl %>% 
  filter(yearID > 2000) %>%
  group_by(playerID) %>%
  summarize( HR = sum(HR) ) %>%
  ## Here's the pipe from above
  filter( HR > 400) %>%
  arrange( desc(HR) )

# using ".N": -----------------------------------------------------------------

## data.table: .N and stints example
batting_dt[yearID == 2016 & AB > 99, .N, .(playerID)][N>1]

## data.table: 20-20 example
# data.table
batting_dt[ yearID > 2000 , .(SB = sum(SB), HR = sum(HR)), 
           .(playerID, yearID) ] %>%
  .[SB > 19 & HR > 19] %>%
  .[ , .N, yearID]

## SQL: stints example
query = 
  '
SELECT playerID, COUNT(teamID) as N
FROM BATTING
WHERE yearID = 2016 AND AB > 99
GROUP BY playerID
HAVING N > 1
'
lahman %>% tbl(sql(query)) %>% collect()

## SQL: 20-20
query = 
  '
SELECT yearID, COUNT(playerID) as N
FROM (
 SELECT playerID, yearID, sum(SB) as SB, sum(HR) as HR
 FROM BATTING
 WHERE yearID > 2000
 GROUP BY playerID, yearID
 HAVING SB > 19 AND HR > 19
)
GROUP BY yearID
'
lahman %>% tbl(sql(query)) %>% collect()

## dplyr: n() and stints example
batting_tbl %>% 
  filter(AB > 99 & yearID == 2016) %>%
  group_by(playerID, yearID) %>%
  summarize(N=n()) %>%
  filter(N > 1)

# dplyr: n() and 20-20 example
batting_tbl %>%
  filter( yearID > 2000) %>%
  group_by(yearID, playerID) %>%
  summarize( SB = sum(SB), HR = sum(HR) ) %>%
  filter( SB > 19 & HR > 19) %>%
  summarize( n = n() )

# Thanks for your attention!

