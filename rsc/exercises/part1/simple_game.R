# A very simple Guessing Game that the player always wins.
#
# Author: <your name>
# Updated: <today>
# 79: -------------------------------------------------------------------------

# load messages: --------------------------------------------------------------
# <load messages here>

# the game: -------------------------------------------------------------------
guessing_game = function(messages) {
  # A very simple Guessing Game that the player always wins.
  # Inputs:  messages, a list with text to display to the player.
  # Output: None, the game is played for it's side effects. 
  
  # display welcome message
  # <display the welcome message>
  
  # display instructions
  cat(messages[['instructions']], '\n')
  
  # wait for player input
  guess = readline()
  
  # repeat player guess
  out = sprintf('You guessed:\n "%s"\n', guess)
  cat(out)
  
  # print win messages
  # <display the win message>
}

# To play, call the function as below. 
# guessing_game(messages)

# 79: -------------------------------------------------------------------------
