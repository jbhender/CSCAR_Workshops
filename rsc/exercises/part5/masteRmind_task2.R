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

# tests 
stopifnot(length(col_dict) == 8)
stopifnot(typeof(col_dict) == "character")
stopifnot(length(unique(scol_dict)) == length(col_dict))
stopifnot(length(unique(names(col_dict))) == length(names(col_dict)))

# generate the secret code: ---------------------------------------------------
gen_code = function(n, dict, repeats = FALSE) {
  # generate a sequence of colors for the secret code in mastermind
  # Inputs:
  #   n - the number of words in the secret code
  #   dict - a dictionary from which to choose the code. 
  #   repeats = FALSE, - should repeats be allowed?
  # Output: a character vector of length n
  sample(dict, n, replace = repeats)
}

# tests that it works
stopifnot(length(gen_code(4, col_dict)) == 4)
stopifnot(all(gen_code(4, col_dict) %in% col_dict))

