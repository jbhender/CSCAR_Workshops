# R Short Course, Part 3
# Conditional execution
#
# Author: James Henderson
# Updated: July 26, 2021
# 79: -------------------------------------------------------------------------

# conditional execution: ------------------------------------------------------

# if
if ( TRUE ) {
  print('do something if true')
}

# else
if ( {2 + 2} == 5 ) {
  print('the statement is true')
} else {
  print('the statement is false')
}

# else if
a = 1
b = -1

if ( a * b > 0 ) {
  print('Zero is not between a and b')
} else if ( a < b ) {
  smaller = a
  larger = b
} else {
  smaller = b
  larger  = a
}
c(smaller, larger)

# vectorized ifelse()
result = c(4, 5)
report = ifelse( {2 + 2} == result, 'true', 'false')
report

mtcars[['mpg_over_30']] = with(mtcars, ifelse(mpg > 30, 'Yes', 'No'))
with(mtcars, table(mpg_over_30))

# switch: ---------------------------------------------------------------------
# it's okay to skip this section for now if you find it difficult
cases = function(x) {
  switch(as.character(x),
         a=1,
         b=2,
         c=3,
         "Neither a, b, nor c."
  )
}
cases("a")
cases("m")
cases(8)

# coercion fo character ensures switch uses a look-up by name and not position
cases_alt = function(x) {
  switch(x,
         a=1,
         b=2,
         c=3,
         "Neither a, b, nor c."
  )
}
cases_alt("a")
cases_alt("m")
cases_alt(8)
x = cases_alt(8)
x

# a numeric or by-position switch
for ( i in c(-1:3, 9) ) {
  print(switch(i, 'a', 'b', 'c', 'd'))
}

# a more useful example of using a switch
my_summary = function(x) {
  # Summarize a vector x
  #  inputs: x - a numeric vector or a factor
  #  output: if x is a factor, a frequency table; if x is numeric a string
  #     stating its mean and standard deviation
  switch(class(x),
         factor=table(x),
         numeric=sprintf('mean=%4.2f, sd=%4.2f', mean(x), sd(x)),
         'Only defined for factor and numeric classes.')
}

for ( var in names(iris) ) {
  cat(var, ':\n', sep = '')
  print( my_summary(iris[[var]]) )
}
class(iris)
my_summary(iris)
# 79: -------------------------------------------------------------------------
