# R Short Course, Part 3
# Iteration
#
# Author: James Henderson
# Updated: July 27, 2021
# 79: -------------------------------------------------------------------------

# for loop: -------------------------------------------------------------------

# syntax
for ( i in 1:10 ) {
  cat(i, '\n')
}

# the iterator (var) and body are evaluated in the global environment
for ( var in names(mtcars) ) {
  cat( sprintf('average %s = %4.3f', var, mean(mtcars[, var]) ), '\n')
}
var

# while loop: ----------------------------------------------------------------
# a `while` loop continues as long as a condition remains true

## random walk example, until 'hitting time' of reaching 10
max_iter = 1e3 # always limit the total iterations allowed in a while loop
val = vector(mode = 'numeric', length = max_iter)
val[1] = rnorm(1) ## initialize

k = 1 # counter
while ( abs(val[k]) < 10 && k <= max_iter ) {
  val[k + 1] = val[k] + rnorm(1)
  k = k + 1
}
val = val[1:{k - 1}]

plot(val, type = 'l')

# control words: --------------------------------------------------------------

# next
for ( i in 1:10 ) {
  if ( i %% 2 == 0 ) {
    next
  }
  cat(i,'\n')
}

# break
x = c()
for ( i in sample(1:1e1, 1e1) ) {
  x = c(x, i)
  if ( i %% 3 == 0 ) {
    break
  }
}
print(x)

# 79: -------------------------------------------------------------------------
