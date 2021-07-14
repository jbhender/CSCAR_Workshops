# Arithmetic Operators in R 
#
# Updated: September 6, 2020
# Author: James Henderson
# 79: -------------------------------------------------------------------------

# R can do arithmetic: --------------------------------------------------------
x = 10
y = 32

z = x + y 
x + y

z / x

z^2

z + 2 * c(y, x) - 10  

11 %% 2  # Modular arithmetic 

11 %/% 2 # Integer division

convert_time = function( time ) {
  # converts a 24-hour time, given as an integer, to a 12-hour time
  # Inputs: time - an integer in {0, ..., 23}
  # Outputs: a character vector, e.g. 4am, 12pm
  
  sprintf('%2i%s', 
          ifelse( time %in% c(0, 12), 12, time %% 12),
          c('am', 'pm')[1 + time %/% 12]
  )

}
#vapply(0:23, FUN = convert_time, FUN.VALUE = "12pm")

# Broadcasting: ---------------------------------------------------------------
x = 4:6
y = c(0, 1)
x * y

x = 1:4
y * x
x * y

# Built in functions: ---------------------------------------------------------

## Primitive functions
sum(x)  # summation
exp(x)  # Exponential
sqrt(x) # Square root
log(x)  # Natural log
sin(x)  # Trigonometric functions
cos(pi / 2) # R even contains pi, but only does finite arithmetic
floor(x / 2) #The nearest integer below
ceiling(x / 2) #The nearest integer above

## Base functions
mean(x) # average
setdiff(y, x)
intersect(x, y)
union(x, y)
unique(c(x, y))

## Stat functions
sd(x)   # Standard deviation
var(x)  # Variance

# Finite precision with floating point arithmetic: ----------------------------
sqrt(2)^2 - 2

## floating point addition not commutative 
{.1 + .7 + .2} == 1
{.7 + .2 + .1} == 1
#dplyr::near(.7 + .2 + .1, 1)
