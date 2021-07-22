## R Short Course, Part 1: Exercises

### Agenda

+ Welcome [2-2:05]
+ Workshop Overview [2:05-2:10]
+ Questions about Part 1 Material [2:10-2:30]
+ Exercise Set 1
  - Breakout [2:30-2:45]
  - Discussion [2:45-2:55]
+ Exercise Set 2 
   - Breakout [2:55-3:10]

- Discussion [3:10-3:20]
+ Exercise Set 3 (time permitting)
+ Wrap up [3:20-3:30]

If we end early, consider playing a game of Master Mind to prepare you
for the practicum.

https://www.webgamesonline.com/mastermind/

### (Set 1) R Basics & Arithmetic

For each snippet of **R** code below, compute the value of `z` without using
**R**.  Use **R** to check your work when done.  

```r
# 1.  What is the value of `z`?

x = 10
y = c(9, 9)
z = x
z = y
z = sum(z)
```

```r
# 2.  What is the value of `z`?

x = -1:1
y = rep(1, 10)
z = mean(x * y)
```

```r
# 3. Which do you think is larger `e0` or `e1`? Why?
#    What is the value of `z`?

x0 = 1:10000
y0 = x0 * pi / max(x0)
e0 = sum( abs( cos(y0)^2 + sin(y0)^2 - 1 ) )

x1 = 1:100000
y1 = x1 * pi / max(x1)
e1 = sum( abs( cos(y1)^2 + sin(y1)^2 - 1 ) )

z = floor( e1 / e0 )
```

### (Set 2) A simple game

This set of exercises is preparatory for the practicum in part 5. In
this exercise we will write a trivial game in which the player always
wins after entering anything at all.  

4. Write an R script that does the following:  
  + creates a list "messages" with elements:  
    - 'welcome' - a message welcoming a player to the game,
    - 'instructions' - A question along the lines of
       "What am I thinking? Enter your response below.",
    - 'win' - A message to be printed when the player "wins" by
       entering anything at all.  
  + saves that list as `game_messages.RData` in a
    folder dedicated to this workshop.

5. Download the script [simple_game.R](./simple_game.R) and
   move it the folder you created in exercise 4. Modify the script
   in the locations indicated to:  
   - load the list of messages you created in exercise 4,
   - write the welcome message from your list to the console,
   - write the "win" message to the console.

### (Set 3) Installing R Packages

This set of exercises is focused on working with packages.
We will do these exercises only if the previous parts finish early. 

6. Find the default location for R packages on
   the computer you're on now.

7. Try to install the following R packages:
  - [rio](https://rdrr.io/cran/rio/f/README.md)
  - [tidyverse](https://www.tidyverse.org/): a collection of packages developed
    by Hadley Wickham and the RStudio team.
  - If these are already installed, help others in your group troubleshoot.

What, if any, issues do you encounter? Did your groupmates provide any advice
that helped you to solve them?

