## Lahman examples of joins
##
## Updated: May 28, 2019

# Packages: -------------------------------------------------------------------
library(tidyverse); library(dbplyr); library(Lahman); library(data.table)
#lapply( c('tidyverse', 'dbplyr', 'Lahman', 'data.table'), install.packages)

# Create a local SQLlite database of the Lahman data: -------------------------
lahman = lahman_sqlite()

# Copy the batting table to memory as a tibble: -------------------------------
batting_tbl = lahman %>% 
  tbl("BATTING") %>% 
  collect()

# Convert the copy in memory to a data.table: ---------------------------------
batting_dt = as.data.table(batting_tbl)

# Question: Find the names and teams of the players who had 200 or more hits
#           in 2016.
tab1 = batting_dt[yearID == 2016, .(H = sum(H), teamID), .(playerID) ] %>% 
  .[ H >= 200 ] %>%
  .[ order(-H) ]

master_dt = as.data.table(Master)

# An explicit merge
merge(tab1, master_dt[,.(playerID, nameFirst, nameLast)], 
      by = 'playerID', all.x = TRUE) %>%
  .[ , .(player = paste(nameFirst, nameLast), team = teamID, `# of hits` = H) ]

# An implicit merge    
master_dt[ tab1, 
      .(player = paste(nameFirst, nameLast), team = teamID, `# of hits` = H),
      on = 'playerID']  
# Question: Which player has the most lifetime home runs (HR) without being in the Hall of Fame or ever playing in an All-Star game?

query = 
'
SELECT awardID A, count(yearID) N
FROM AwardsPlayers
GROUP BY awardID
'
lahman %>% 
  tbl( sql(query) ) %>%
  collect() %>%
  as.data.table()

tables(lahman)  
  
