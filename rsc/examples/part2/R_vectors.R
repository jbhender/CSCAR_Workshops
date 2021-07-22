# R vectors
#
# Updated: September 6, 2020
# Author: James Henderson
# 79: -------------------------------------------------------------------------

# constructors: ---------------------------------------------------------------
cvec = c()
cvec
length(cvec)
typeof(cvec)

vvec = vector('character', length = 4)
length(vvec)
typeof(vvec)
vvec

vvec_int = vector('integer', length = 4)

# types: ----------------------------------------------------------------------
w = TRUE
x = 1L
y = 1
z = "One"

## What is the return value of the function call below?
vapply( list(w, x, y, z, c(w, x, y, z)), FUN = typeof, FUN.VALUE = 'type')

## illustrate type promotion

## What is the type of each call below?
typeof( x + y )
typeof( y + x )
typeof( w + x )
typeof( w + w )
typeof( w + !w )
typeof( w || !w )

# Subsetting: -----------------------------------------------------------------

typeof( list(w, x, y, z)[3] )   # some_list[] selects a sub_list
typeof( list(w, x, y, z)[2:3] )   # some_list[] selects a sub_list
typeof( list(w, x, y, z)[[3]] ) # some_list[[]] selects a single element

# Attributes: -----------------------------------------------------------------

## Names

### Ex1: assign with names()
x = 1:3
names(x) = c('Uno', 'Dos', 'Tres') # names() is an accesor 
x

### Ex2: quoted names
x = c( 'Uno' = 1, 'Dos' = 2, 'Tres' = 3 )
x

### Ex3: bare names
x = c( Uno = 1, Dos = 2, Tres = 3)
x

### Ex4
names(x)
#attr(x, 'names')

## class

### atomic vectors, class = mode
class(FALSE)
class(0L)
class(1) # class( double) = numeric
class('Two')
class( list() )
                                                               
### class impacts method dispatch
x
class(x)
print(x)

class(x) = 'character'
print(x)
x

### coercion
y_char = as.character(y)

## dim

### Matrix (2D array) class
x = matrix(1:10, nrow = 5, ncol = 2) # column-major ordering
dim(x)
class(x)
dim(x) = c(2, 5)

### Array class
dim(x) = c(5, 1, 2)
class(x)
x

dim(x) = c(5, 2, 1)
x
class(x)

# Arbitrary attributes: -------------------------------------------------------

## query or set attributes with attr()
attr(x, 'color') = 'green'
attr(x, 'color')

## list all attributes with attributes()
attributes(x)
class( attributes(x) )

## assign specific attributes is like using accessor functions, e.g. dim()
attr(x, 'dim')
attr(x, 'dim') = c(5, 2)
class(x)
x

dim(x) = c(2, 5)
x

## Assign NULL to remove attributes
attr(x, 'color') = NULL
attributes(x)

# 79: -------------------------------------------------------------------------