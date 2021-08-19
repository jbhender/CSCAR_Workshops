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

# messages list: --------------------------------------------------------------
msgs = list(
 msg_input = 'Plase enter guess number %i:\n'
)

# generate the secret code: ---------------------------------------------------
# n - the number of words in the secret code
# dict - a dictionary from which to choose the code. 
# repeats = FALSE, - should repeats be allowed?
# sep - how to separate words in the code
# based on the R function "sample"

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

# request user input: ---------------------------------------------------------
request_input = function(num_guess = 1, msg_input = msgs[['msg_input']]) {
  
  # Prompt user
  request_str = sprintf(msg_input, num_guess)
  cat(request_str)
  
  # Get input
  guess = readline()
  
  # Return input
  guess
}

if ( interactive() ) {
  x = request_input(2) 
  Blue, Orange, Green, Red
  stopifnot(x == "Blue, Orange, Green, Red")
}

# split input into comma-separated pieces: ------------------------------------
split_guess = function(guess, sep = ','){
  # split user input at each instace of `sep`
  # Inputs: 
  #   guess - the user input
  #   sep - the value to separate on, defaults to ","
  # Returns:
  #   a character vector 
  strsplit(guess, split = sep, fixed = TRUE)[[1]] |>
    stringr::str_trim()
}

guess = "Blue, Orange, Green, Red"
stopifnot(split_guess(guess) == c('Blue', 'Orange', 'Green', 'Red'))

# 79: -------------------------------------------------------------------------
