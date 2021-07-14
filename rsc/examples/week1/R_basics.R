# Examples and notes for R Basics 1-3: 
#   1 - Objects, Assignment, and Naming
#   2 - Globabl Environment
#
# Updated: September 4, 2020
# Author: James Henderson
#79: --------------------------------------------------------------------------

# R Basics 1: -----------------------------------------------------------------
# This is a comment ignored by R
instructor <- 'Dr. Henderson'
x <- 10
y <- 32
z <- c(x, y) #Form vectors by combining or concatenating elements.

9 -> w # This works, but is bad style.
the_answer = 42 # Most other languages use = for assignment.

the_answer

# non-syntactic names
`.2way` = 42
`Value ($)` = 1e3

# value vs reference
x = 10
y = 32
z = c(x, y)
c(x, y, z)

y = the_answer
c(x, y, z)

# R Basics 2: -----------------------------------------------------------------

# Ex 0
ls()
rm(instructor)
rm(Z)

# Ex 1a
rm( list = ls() )
ls()

# Ex 1b - assign
assign("new_int", 9) # i.e. new_int = 9
new_int
`=`(new_int, 9)
ls()
new_int
`=`("new_int", 9)
`<-`("new_int", 9)

new_obj = 'new_int2'
some_int = rpois(1, 1)
assign(new_obj, some_int)
ls()
new_int2

# Ex 1c - get 
get('new_int')

# How are these different?
get(some_int)
get("some_int")

# Error? Or a value? What will the value be?
get(new_obj)

# Ex 2
rm( list = ls() )
obj = 'obj_name'
val = 42
assign(obj, value = val) # assign the value in 'val' to the value in 'obj'
ls()

nms = ls()
global_objs = lapply(ls(), get)
names(global_objs) = setdiff(ls(), 'global_objs') # c('nms', nms) 
global_objs

#79: --------------------------------------------------------------------------
