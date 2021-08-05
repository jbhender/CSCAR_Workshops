## R Short Course, Part 3: Exercises

### Agenda

+ Welcome [2-2:05]
+ Questions about Part 3 [2:05-2:20]
+ Exercise Set 1
  - Live coding [2:20-3:20] *or*
  - Breakout 1 [2:20-2:35]
  - Discussion [2:35-2:50]
  - Breakout 2 [2:50-3:10]
  - Discussion [3:10-3:25]
+ Closing questions [3:25-3:30]

## Exercise

In this exercise we will use programming tools to build a functional guessing
game that can be played a the R console. This will be a simple game in which
the player attempts to guess a randomly generated number in a chosen range 
within an allotted number of guesses. We will also program the game to offer an
option to provide feedback on whether a guess was too high or too low.  

Starting with step 4, call the function to play the game once or twice after
each step to check for syntax errors or bugs (unexpected behavior).

```
1. Download and open the template [here](./rsc_part3_gg_template.R) 
   and update the header.
2. Create a list `messages` with slots `welcome`, `win` and `lose` each 
   containing a string. The `welcome` message will be displayed at the start of
   the game and the `win` or `lose` message displayed when the player
   wins by guessing correctly or loses by exceeding the allotted guesses. 
3. Define a function `guessing_game` with the following parameters:
   + `min` - the lower end of the range of the number to be guessed,
   + `max` - the upper end of the range of the number to be guessed,
   + `guesses` - the allotted number of guesses,
   + `show_target` - a logical indicating whether to display the target
      number for testing purposes. 
   + `msgs` - a list of messages to be displayed at appropriate times. 
4. Choose appropriate defaults for the parameters above, set `guesses=1`. 
5. Use comments within the function body to document the function's purpose
   and inputs.
6. At the start of the function, use `cat()` to display the `welcome` message. 
7. Use the function `sample()` to generate `target` - the number to be guessed.
   When `show_target` is true, display the target for the purpose of testing.
8. Add a slot `range` to the `messages` list to tell the player what range
   the number lies in.  Use placeholders `%i` to be filled in later by `min`
   and `max`.
9. In your function, use `sprintf()` and the `range` template from the previous
   step to create `range_msg` telling the player that the target number lies 
   between `min` and `max`.  Use `cat()` to display this message after the
   welcome.
10. Add a slot `ask_guess` to `messages` and cat this within your function to
    prompt the player for a guess. Consider adding instructions like, 
    "Enter your guess as a whole number and press return."
11. Create a counter `n_guesses` starting at zero to track the number of 
    guesses a player has made.  
12. Use the construction `guess = readLines(n = 1)` to allow the player to 
   enter a guess. 
13. Coerce the guess to numeric using `g = as.numeric(guess)` to ensure a valid
    guess. Validate the guess by checking that `g` is not `NA` (use `is.na()`),
    that `g` has length 1, that `g` is between `min` and `max` (inclusive), and
    that g is an integer (`g == as.integer(g)`.) Use an `if` statement to print
    a message about an invalid guess if any of these conditions are not true. 
14. When a valid guess is entered, increment `n_guesses` by 1. Hint, add an
    `else` statement to the code written for 13.
15. Check if the guess `g` is correct (equal to `target`). If so, print the
    `win` message and use an explicit early `return()`. You may wish to return
    `TRUE` invisibly. 
16. Use a `while()` loop containing the code from steps 12-15 that stops when
    the number of guesses a player has made exceeds the allotted number 
    (`guesses`). Increase the default for `guesses` in the function definition. 
17. Outside of the `while()` loop, use `cat()` to print the `lose` message when
    a player exceeds the allotted guesses. Consider having your function
    invisibly return `FALSE` in this case. 
18. Add an `else` statement to step 15 to provide feedback to a player after
    an incorrect guess. In the feedback, repeat the player's guess and tell
    them how many guesses are remaining. Hint: add slots to `messages` that
    use placeholders as in the `range_msg` from step 9, then use `sprintf()`. 
19. Add a logical parameter `high_low` to the function definition and update 
    the documentation comments. When `high_low` is `TRUE`, the feedback from
    the previous step should also include whether the current guess was too
    high or too low. Hint: Add a `high_low` slot to messages to be updated
    within the function body by `sprintf()` when requested. 
20. Create a wrapper to your function that does not contain the `msgs` slot
    or the `show_target` option. The wrapper should call your function with
    `show_target = FALSE` and `msgs = messages` (from the global environment)
    and pass other parameters as is. 
21. Test your function under various circumstances and consider upgrades. 
```
