## Example solutions for CSCAR Workshop: Data Management in R with data.table 
## 
## Updated: May 30, 2019
## Author: James Henderson, PhD

# Write data.table code to match each of the SQL or dplyr queries given.

# 1. Find the 2016 average for all playerID with team "DET" and at least 100 AB.
# solution:
batting_dt[ teamID == 'DET' & yearID == 2016 & AB >= 100, 
            .(playerID, avg = H / AB)]

# 2. Find the playerID from team "DET" with the highest average in 2016, with
#    a minimum of 100 AB.
# solution:
batting_dt[ teamID == 'DET' & yearID == 2016 & AB >= 100, 
            .(playerID, avg = H / AB)][avg==max(avg)]

# 3. Find the playerID who hit the most total HRs between 2001 and 2010.
# solution:
batting_dt[yearID %in% 2001:2010, .(HR = sum(HR)), .(playerID)] %>%
  .[which.max(HR)]

# 4. Find all playerIDs with at least 200 hits in 2016 (across all stints)
#    sorted in descending order.
# solution:
# data.table
batting_dt[yearID==2016, .(H = sum(H)), .(playerID) ][ H>=200 ][ order(-H) ]

# 5. Find the number of playerIDs with at least 200 hits in each year since 2000. 
# solution: 
batting_dt[yearID > 1999, .(H = sum(H)), .(playerID, yearID) ][ H>=200 ] %>%
  .[ , .N, yearID] %>% .[order(-yearID)]

