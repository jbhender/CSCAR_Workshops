# RSC Part 4, Munging Exercise Solution (Partial)
# In this exercise we clean up some artificial field notes on primate 
#  behavior.
#
# Author: James Henderson, PhD
# Updated: August 12, 2021
# 79: -------------------------------------------------------------------------

# libraries: ------------------------------------------------------------------
library(tidyverse)

# data: -----------------------------------------------------------------------

# unique primates being followed 
dt_focal = 
  read_delim(
    'https://jbhender.github.io/Stats506/F17/Stats506_F17_ps2_focal_names.csv',
    delim=',', 
    col_names = "name"
  )

# larger community of primates
dt_comm = 
  read_delim(
    'https://jbhender.github.io/Stats506/F17/Stats506_F17_ps2_all_names.csv',
    delim=',', 
    col_names = "name"
  )

# recorded social interactions
dt_social = 
  read_delim(
    'https://jbhender.github.io/Stats506/F17/Stats506_F17_ps2_interactions.csv',
    delim=','
  )

# separate into pairwise social interactions: ---------------------------------

## determine how many columns we expect to have

## number of columns we need

## separate "toward" into distinct columns

## reshape into a longer format


# check and repair validity of `focal` entries: ------------------------------

# check and repair validity of `toward` entries: ------------------------------

## trim white space and correct capitalization

## remove empty entries after trimming

## record and remove entries with ?

# look for similar names in the reference list: -------------------------------

# use a string distance to look for possible matches: -------------------------

## replace 1 deletion matches in the original data using a "dictionary"

# use a string distance as in `adist()`: --------------------------------------

# construct a data frame of possible matches for remaining: -------------------

# 79: -------------------------------------------------------------------------
