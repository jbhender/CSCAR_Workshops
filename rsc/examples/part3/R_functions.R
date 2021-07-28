# R functions 
#
# Updated: July 27, 2021
# Author: James Henderson
# 79: -------------------------------------------------------------------------

# Function arguments: ---------------------------------------------------------

## arguments can be passed by name or position
w = runif(5, min = 0, max = 1)
x = runif(n = 5, min = 0, max = 1)
y = runif(5, 0, 1)
z = runif(5)
round(cbind(x, y, z), 1)

## you can (but shouldn't) passed named arguments out of order
w = runif(min = 0, max = 1, n = 5)
u = runif(min = 0, max = 1, 5) # This also works but is bad style. 
a = runif(
  n = 5, 
  max = 5
)
round(rbind(u = u, w = w), 1)

# writing functions: ----------------------------------------------------------

# Principal: Use functions to avoid repeating yourself (DRY)

## 1st function to compute z-scores
z_score1 = function(x) {
  # computes the z-score of x \frac{x - \bar{x}}{\hat\sigma_x}
  # inputs: x - a numeric vector
  # outputs: the z-scores for x
  
  xbar = mean(x)
  s = sd(x)
  z = {x - mean(x)} / s
  
  return(z)  
}
stopifnot( class(z_score1(1:3)) == 'numeric' && length(z_score1(1:3) == 3) )
stopifnot( all(z_score1(1:3) == -1:1) )

z_score1a = function(x) {
  # computes the z-score of x \frac{x - \bar{x}}{\hat\sigma_x}
  # inputs: x - a numeric vector
  # outputs: the z-scores for x
  
  xbar = mean(x)
  s = sd(x)
  z = (x - xbar) / s
  
  return(z)  
}

## 2nd function to compute z-scores
z_score2 = function(x) {
  # computes the z-score of x \frac{x - \bar{x}}{\hat\sigma_x}
  # inputs: x - a numeric vector
  # outputs: the z-scores for x
  if ( length(x) == 1 ) {
    warning("sd undefined for length one vectors")
    return(x)
  }
  {x - mean(x)} / sd(x)
}
#z_score2(1)
stopifnot( all(z_score2(1:3) == -1:1) )

# compare our function versions
x = rnorm(10, 3, 1) ## generate some normally distributed values
round(cbind(x, 'Z1' = z_score1(x), 'Z2' = z_score2(x)), 1)

# default parameters: ---------------------------------------------------------

# function to compute z-scores
z_score3 = function(x, na_rm = TRUE) {
  # computes the z-score of x \frac{x - \bar{x}}{\hat\sigma_x}
  # inputs: x - a numeric vector
  #         na.rm - a logical indicating whether to remove missing values, 
  #                 passed to sum() and sd()
  # outputs: the z-scores for x
  
  {x - mean(x, na.rm = na_rm)} / sd(x, na.rm = na_rm)
}

x = c(NA, x, NA)
round(cbind(x, 'Z1' = z_score1(x), 'Z2' = z_score2(x), 'Z3' = z_score3(x)), 1)

# scope: ----------------------------------------------------------------------

## Example 1 - lexical scoping
#help(ls)
ls()
f1 = function() {
  f1_message = "I'm defined inside of f1!"  # `message` is a function in base
  ls()
}
ls()
f1()
exists('f1') # 'f1' %in% ls()
exists('f1_message')
ls()

## Example 2 - functions have their own environments 
environment()
f2 = function() {
  environment()
}
f2()
rm(f1, f2)

## Example 3 - lexical scoping
y = x = 'I came from outside of f!'
f3 = function() {
  x = 'I came from inside of f!'
  list(x = x, y = y)
}
f3()
x

## Example 4 - masking
mean = function(x) {
  # document
  sum(x) 
}
ls()
mean(1:10)
search()
base::mean(1:10)
rm(mean)
mean = 10
mean(1:10)

## Example 5 - dynamic lookup 
y = "I have been reinvented!"
f3()

## Example 6 - lazy evaluation
f4 = function(x) {
#  x
  45
}
f4( x = stop("Let's pass an error.") )

f5 = function(x) {
  y = x
  45
}
f5( x = stop("Let's pass an error.") )

# more on lexical scoping: ----------------------------------------------------

## global objects
a = 1
b = 2

## ex 1
g1 = function() {
  a = 3
  g2 = function() {
    b = 3
    b
  }
  c(a = a, b = b)
}
g1()
c(a, b)

## ex 2
d = 5
g3 = function() {
  a = 3
#  d = 0
  g4 = function() {
    b = 3
    c(a = a, b = b, d = d)
  }
  g4()
}
g3()

## ex 3
# a function inherits from the environment where it is defined
g6 = function() {
  b = 3
  c(a = a, b = b)
}

g5 = function() {
  a = 3
  g6()
}

g6()
g5()
