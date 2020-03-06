# R by Example: Functional Programming with data.table

## Background

### Functional Programming

A maxim of programming is *don't repeat yourself*.  For data science, 
I like to modify this to *don't repeat yourself more than twice*.  This means if 
you find yourself using copy-and-paste for a chunk of code for the third time, 
it's probably better to write a function that captures the pattern you are 
repeating.

Encapsulating repetitions in functions helps us write better programs by:

1. making our code easier to read, especially if we use good function names,
1. making it easier to avoid errors in our code, 
1. saving us time in writing and debugging our code.  

### Functions in R

The basic pattern for defining a function is shown below.

```r
my_func = function( arg1, arg2 = 5, arg3 = NULL) {
 ## function body goes here
 
 if ( !is.null( arg3 ) ) {
  return( arg1 * arg2 * arg3 )
 }
 
 arg1 * arg2
}
```

We use the `function` keyword along with 0 or more agruments.  Arguments can
be given defaults. Optional arguments can default to NULL.  

### Function style
A good style rule is to always document a functions inputs and outputs:

```r
my_func = function( arg1, arg2 = 5, arg3 = NULL) {
 # For the product of two or three vectors. 
 # Inputs:
 #  arg1: - a numeric vector
 #  arg2: - a numeric vector, defaults to 5
 #  arg3: - optionally, a third numeric vector
 # Outputs: A (possibly length one) numeric vector, the product of the arguments
 
 if ( !is.null( arg3 ) ) {
  return( arg1 * arg2 * arg3 )
 }
 
 arg1 * arg2
}
```

Another stylistic standard is to reserve explicit use of `return()` for cases
where the function returns early. For normal returns at the end of a function,
we simply write the final computation or the object to be output without 
any assignment.

### Examples

The examples for this workshop are based off the earlier workshop:
[R by Example: Analyzing RECS using data.table](https://jbhender.github.io/CSCAR_Workshops/R_by_Example/recs_datatable/).

Some patterns frequently repeated among the example and solutions are:

1. computing weighted sums by group,
1. using the replicate weight method to compute standard errors and confidence
bounds,
1. replacing numeric codes with labeled factors using the codebook.

We will write functions encapsulating each of these patterns in order 
to allow us to more efficiently explore the RECS data. 

## Example 1

In this example, we begin adapting the instructor [example](https://jbhender.github.io/CSCAR_Workshops/R_by_Example/recs_datatable/RbyExample-recs_d-example.R) from the previous workshop to encapsulate the patterns of
weighted sums by group and fix ideas. The final product can be viewed [here](./RbyExample-recs-dt-example-adapted.R).

## Example 2

This is an extension of example 1, but now encapsulates the 
replicate weight pattern.

## Example 3

In this example, we write a function to transform variables using labels read
from the codebook. The final product can be viewed [here](./RbyExample-fpd-example1.R).

## Tips for writing functions using data.tale

1. Start simple and don't be afraid to do some of the work outside of the function.

1. Recall that `by` and `keyby` accept character strings as well as bare variable
names.

1. Use `.SD[[..var]]` to access a specific variable using a character string `var`.

1. Not everything needs to be done in a single step. Use `set` functions such as
   `setnames` to modify in place.

1. Use `.SDcols` to control which columns are in the data.table `.SD`. 



