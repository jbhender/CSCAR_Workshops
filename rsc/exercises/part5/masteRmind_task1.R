# A console version of the game mastermind. 
#
# Updated: August 19, 2021
# Author: James Henderson 
# 79: -------------------------------------------------------------------------

# create a dictionary of eight colors: ----------------------------------------
col_dict = c(
  R = 'Red', 
  Gr = 'Green',
  Bu = 'Blue',
  Y = 'Yellow',
  Go = 'Gold', 
  O = 'Orange', 
  Ba = 'Black', 
  W = 'White'
)

# alternately set names after creation: ---------------------------------------
col_dict = 
  c('Red', 'Green', 'Blue', 'Yellow', 'Gold', 'Orange', 'Black', 'White')
names(col_dict) = c('R', 'Gr', 'Bu', 'Y', 'Go', 'O', 'Ba', 'W')

# tests 
stopifnot(length(col_dict) == 8)
stopifnot(typeof(col_dict) == "character")
stopifnot(length(unique(col_dict)) == length(col_dict))
stopifnot(length(unique(names(col_dict))) == length(names(col_dict)))

# 79: -------------------------------------------------------------------------
