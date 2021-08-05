# R Short Course, Part 3 - Programming Tools
# Guess a number game, solution.
# 
# Author: James Henderson, PhD, CSCAR
# Updated: August 5, 2021
# 79: -------------------------------------------------------------------------

# messages and message templates for use by the game: -------------------------
messages = list(
  welcome = "Hi friend!\n",
  range = "I'm thinking of a number from %i to %i. Can you guess which?\n",
  feedback = "Nope it's not %i. You have %i guess%s remaining.\n",
  high_low = "My number is %s than %i.\n",
  ask_guess = 
    "What is your guess? [Enter a whole number, then press return.]\n",
  invalid_guess = 
    "Your guess is invalid. Only whole numbers between %i and %i are valid.\n",
  win = 'You guessed right!',
  lose = 'Better luck next time!'
)

# the game: -------------------------------------------------------------------
guessing_game = function(
  min = 1, 
  max = 10,
  guesses = 5, 
  high_low = FALSE,
  msgs = messages,
  show_target = FALSE
) {
  # A console guessing game
  # Inputs:
  #   min - the minimum range of the number to be guessed, defaults to 1. 
  #   max - the maximum range of the number, defaults to 10.
  #   guesses - the number of allowed guesses, defaults to 5.
  #   high_low - a logical indicating whether to provide feedback on whether
  #              the target number is higher or lower than the previous guess.
  #   msgs - a list of messages for communicating to the player.
  #   show_target - when TRUE the target is printed, useful for debugging. 
  # Outputs: The game is played interactively and this function is not 
  #          generally run for its output. However, a logical indicating 
  #          if the game was won is returned invisibly when assigned. 
  
  # welcome
  cat(msgs[['welcome']])
  range_msg = sprintf(msgs[['range']], min, max)
  cat(range_msg)
  
  # generate a target
  target = sample(min:max, 1)
  if ( show_target == TRUE ) {
    cat(target, '\n') 
  }

  
  n_guesses = 0
  while ( n_guesses < guesses ) {
      # ask for a guess
      cat(msgs[['ask_guess']])
      guess = readLines(n = 1)
      
      # process guess for validity
      g = suppressWarnings(as.numeric(guess))
      valid = (length(g) == 1) && !is.na(g) && (g >= min) && (g <= max) &&
              (g == as.integer(g))
      if ( valid == FALSE ) {
        msg = sprintf(msgs[['invalid_guess']], min, max)
        cat(msg)
        next
      } else {
        n_guesses = n_guesses + 1 
      }
      
      # check if guess is right
      if ( g == target ) {
        cat(msgs[['win']])
        return( invisible(TRUE) )
      } else if (n_guesses < guesses) {
        plural = ifelse((guesses - n_guesses) > 1, 'es', '')
        fb_msg = sprintf(msgs[['feedback']], g, (guesses - n_guesses), plural)
        cat(fb_msg)
        if ( high_low == TRUE ) {
          direction = ifelse( g > target, 'lower', 'higher')
          hl_msg = sprintf(msgs[['high_low']], direction, g)
          cat(hl_msg)
        }
      }
  } # ends while loop
  
  # if player loses
  stopifnot(n_guesses >= guesses)
  cat(msgs[['lose']])
  
  # return invisibly 
  invisible(FALSE)
}

# test the game: --------------------------------------------------------------
if ( FALSE ) {
  guessing_game(guesses = 3, show_target = TRUE)
  1
  pi
  3
  2
  
  guessing_game(guesses = 3, high_low = TRUE, show_target = TRUE)
  1
}

# player version: -------------------------------------------------------------
play_gg = function(min = 1, max = 10, guesses = 5, high_low = FALSE) {
  # A console guessing game
  # Inputs:
  #   min - the minimum range of the number to be guessed, defaults to 1. 
  #   max - the maximum range of the number, defaults to 10.
  #   guesses - the number of allowed guesses, defaults to 5.
  #   high_low - a logical indicating whether to provide feedback on whether
  #              the target number is higher or lower than the previous guess.
  # Outputs: The game is played interactively and this function is not 
  #          generally run for its output. However, a logical indicating 
  #          if the game was won is returned invisibly when assigned.
  guessing_game(min, max, guesses, high_low, messages)
}

## test
if ( FALSE ) {
  play_gg(1, 5, 3, high_low = TRUE)
}

# 79: -------------------------------------------------------------------------
