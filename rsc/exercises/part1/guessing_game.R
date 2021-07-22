# R Short Course, Part 1
#
# A very simple Guessing Game that the player always wins.
# Author: James Henderson
# Updated: July 22, 2021
# 79: -------------------------------------------------------------------------

# load messages: --------------------------------------------------------------
foo = load('game_messages.RData') # messages

# the game: -------------------------------------------------------------------
guessing_game = function(messages) {
  # A very simple Guessing Game that the player always wins.
  # Inputs:  messages, a list with text to display to the player.
  # Output: None, the game is played for it's side effects. 
  
  # display welcome message
  cat(messages[['welcome']], '\n')
  
  # display instructions
  cat(messages[['instructions']], '\n')
  
  # wait for player input
  guess = readline()
  
  # repeat player guess
  out = sprintf('You guessed:\n "%s"\n', guess)
  cat(out)
  
  # print win messages
  cat(messages[['win']])
}

# guessing_game(messages)

# 79: -------------------------------------------------------------------------
