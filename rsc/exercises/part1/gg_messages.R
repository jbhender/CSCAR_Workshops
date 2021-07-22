# R Short Course, Part 1
# Exercise 4, Solution
# 
# Messages for a simple guessing game.
#
# Author: James Henderson
# Updated: July 22, 2021
# 79: -------------------------------------------------------------------------

# construct the list of messages: ---------------------------------------------
messages = 
  list(
    welcome = "Fancy yourself a mind-reader, eh? Welcome to Guessing Game!",
    instructions = "What am I thinking? Enter your response below.",
    win = "That's right! How did you know? I'm impressed!!"
  )

# save: -----------------------------------------------------------------------
save(messages, file = 'game_messages.RData')

# 79: -------------------------------------------------------------------------
