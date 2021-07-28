# R Short Course, Part 3
# Logical vectors
#
# Author: James Henderson
# Updated: July 23, 2021
# 79: -------------------------------------------------------------------------

# logical keywords, TRUE, FALSE, NA: ------------------------------------------
typeof(TRUE)
typeof(FALSE)
typeof(NA)
if ( TRUE && T ) {
  print('Synonyms')
}
if ( !(FALSE || F) ){
  print('Synonyms')
}

# T == TRUE, F == FALSE, but always use the full word

# Boolean comparisons: --------------------------------------------------------
{2 * 3} == 6     # test equality with ==
(2 + 2) != 5     # use != for 'not equal'
sqrt(70) > 8     # comparison operators: >, >=, <, <=
sqrt(64) >= 8  
!{2 == 3}        # Use not to negate or 'flip' a logical

# Boolean operators are vectorized: -------------------------------------------
1:10 > 5

## broadcasting
res = 1:10 > c(0, 5)
names(res) = 1:10
res

# Logical conjunctions `&` (and) and `|` (or): --------------------------------

## vectorized
{2 + 2} == 4 | {2 + 2} == 5 # An or statement asks if either statement is true
{2 + 2} == 4 & {2 + 2} == 5 # And requires both to be true

## bitwise / scalar
{2 + 2} == 4 || {2 + 2} == 5 # An or statement asks if either statement is true
{2 + 2} == 4 && {2 + 2} == 5 # And requires both to be true

## distinction between vectorized and bitwise
even = {1:10 %% 2} == 0
div4 = {1:10 %% 4} == 0
names(even) = 1:10
names(div4) = 1:10

even | div4
even || div4

even & div4
even && div4

# functions for working with logical vectors: ---------------------------------
any(even)
all(even)
which(even)

which((1:5)^2 > 10)

# subset by position using which and a logical vector 
head(mtcars)
mtcars[which(mtcars$mpg > 30), ]

# stylistically, subset() method is better
subset(mtcars,  mpg > 30) 

# how does each handle NA by default?
any(c(NA, TRUE))
any(c(NA, FALSE))
any(c(NA, even))

all(c(NA, TRUE))
all(c(NA, FALSE))
all(c(NA, even))

which(c(NA, TRUE))
which(c(NA, FALSE))
which(c(NA, even))


# 79: -------------------------------------------------------------------------
