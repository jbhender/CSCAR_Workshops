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
stopifnot(length(unique(col_dict)) == length(col_dict))
stopifnot(length(unique(names(col_dict))) == length(names(col_dict)))

# messages list: --------------------------------------------------------------
msgs = list(
  msg_input = '@<##>@ - Plase enter guess number %i:\n',
  too_few = '@<##>@ - The secret is %i colors, you only entered %i.\n',
  too_many = '@<##>@ - The secret is %i colors, but you entered %i.\n',
  bad_guess = paste(
    '@<##>@ - Guesses %s are not valid colors.',
    'Please enter a color (%s) or its abbreviation (%s).\n'
  )  
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

x = request_input(2) 
#Blue, Orange, Green, Red
stopifnot(x == "#Blue, Orange, Green, Red")


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

# clean user input: -----------------------------------------------------------
clean_guess = function(g, dict) {
  # replace abbreviations in guess with values from dict and
  #  allow for capitalization mistakes
  # Inputs:
  #   g - a user guess split at commas as returned by split_guess()
  #   dict - a named dictionary of colors, with names being abbreviations
  # Output: a character vector the same length as `g` with all values not in
  #   `dict` set to `NA`.
  g = stringr::str_to_title(g) 
  g = ifelse(
    g %in% dict,
    g,
    ifelse(
      g %in% names(dict),
      dict[g],
      NA
    )
  )
  g
}

stopifnot(
  c('R', 'gr', 'blue', 'Brown') |> 
    clean_guess(dict = col_dict) %in% c('Red', 'Green', 'Blue', NA)
)

# validate user input: --------------------------------------------------------
validate_guess = function(g, code_length, dict, messages = msgs) {
  # Provide feedback if user guess is invalid in specific ways
  #  Inputs:
  #    g - the cleaned guess as returned by `clean_guess()`
  #    code_length = the length of the secret code
  #    dict - the dictionary of colors used
  #    messages - a list of message templates to use for feedback
  #  Output: Returns TRUE if user guess passes all tests and FALSE otherwise.
  #   When FALSE, a message for the first failed test is passed. 
  
  # Check that guess is the right length
  if ( length(g) < code_length ) {
    sprintf(messages[['too_few']], code_length, length(g)) |> cat()
    return(FALSE)
  }
  
  if ( length(g) > code_length ) {
    sprintf(messages[['too_many']], code_length, length(g)) |> cat()
    return(FALSE)
  }
  
  if ( any(is.na(g)) ) {
    errs = which(is.na(g)) |> paste(collapse = ', ')
    sprintf(
      messages[['bad_guess']], 
      errs, 
      paste(dict, collapse = ', '),
      paste(names(dict), collapse = ', ')
    ) |> 
      cat()
    return(FALSE)
  }
  
  TRUE
}

validate_guess(
  clean_guess(c('R', 'gr', 'blue', 'Brown'), dict = col_dict),
  code_length = 4, 
  dict = col_dict,
  messages = msgs
)

# standard feedback: ----------------------------------------------------------
feedback = function(result, secret, messages = msgs) {
  # Check if user has won the game and provide feedback
  # Inputs:
  #  - result - a list with `n_exact` and `n_color` as returned by 
  #             check_guess()
  #  - secret - the secrete code
  #  - messages - a list with slots for each message to print
  # Output:
  #   Messages are printed as a side effect. The function returns TRUE
  #   if the user wins the game and FALSE otherwise. 
  n = length(secret)
  
  if ( result$n_exact == n ) {
    win_msg = sprintf(messages[['win_msg']], paste(secret, collapse = ', '))
    cat(win_msg)
    return(TRUE)
  } else {
    feedback_msg = 
      with(result,
           sprintf(messages[['feedback_msg']], n_exact, n_color)
      )
    cat(feedback_msg)
  }
  
  return(FALSE)
}

# Tests
stopifnot(
  feedback( 
    result = list(n_exact = 4, n_colors = 4),
    secret = c('Blue', 'White', 'Yellow', 'Gold'),
    messages = msgs
  )
)

stopifnot(
  feedback( 
    result = list(n_exact = 2, n_colors = 3),
    secret = c('Blue', 'White', 'Yellow', 'Gold'),
    messages = msgs
  ) == FALSE
)
# 79: -------------------------------------------------------------------------
