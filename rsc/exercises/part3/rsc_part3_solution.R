
messages = list(
  welcome = "Hi friend!\n",
  ask_guess = 
    "What is your guess? [Enter a whole number, then press return.]\n",
  invalid_guess = 
    "Your guess is invalid. Only whole numbers between %i and %i are valid.",
  win = 'You guessed right!',
  lose = 'Better luck next time!'
)

guessing_game = function(min = 1, max = 10, guesses = 5, msgs = messages) {
  
  cat(msgs[['welcome']])
  
  # generate a target
  target = sample(min:max, 1)
  #cat(target, '\n')
  
  n_guesses = 0
  while ( n_guesses < guesses ) {
      # ask for a guess
      cat(msgs[['ask_guess']])
      guess = readLines(n = 1)
      
      # process guess for validity
      g = as.numeric(guess)
      if ( (length(g) == 1) && !is.na(g) && (g >= min) && (g <= max)) {
        n_guesses = n_guesses + 1 
      } else {
        msg = sprintf(msgs[['invalid_guess']], min, max)
        cat(msg)
        next
      }
      
      # check if guess is right
      if ( g == target ) {
        cat(msgs[['win']])
        return( invisible(TRUE) )
      }
  } # ends while loop
  
  stopifnot(n_guesses >= guesses)
  cat(msgs[['lose']])
  
  # return invisibly 
  invisible(FALSE)
}

guessing_game(guesses = 10)
