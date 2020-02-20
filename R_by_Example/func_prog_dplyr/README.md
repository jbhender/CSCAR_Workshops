# R by Example: Functional Programming with dplyr

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

The basic pattern for defining an function is shown below.

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

### Examples

The examples for this workshop are based off the earlier workshop:
[R by Example: Analyzing RECS using tidyverse](https://jbhender.github.io/CSCAR_Workshops/R_by_Example/recs_dplyr/).

Some patterns frequently repeated among the example and solutions are:

1. replacing numeric codes with labeled factors using the codebook,
1. computing weighted sums by group,
1. using the replicate weight method to compute standard errors and confidence
bounds.

We will write functions encapsulating each of these patterns in order to allow
us to more efficiently explore the RECS data.

## Example 1

In this example, we write a function to transform variables using labels read
from the codebook. The final product can be viewed [here](./RbyExample-fpd-example1.R).

## Example 2

In this example, we begin adapting the instruction [example](https://jbhender.github.io/CSCAR_Workshops/R_by_Example/recs_dplyr/RbyExample-recs_tidy-example.R) from the previous workshop to encapsulate the patterns of
weighted sums by group and fix ideas. The final product can be viewed [here](./RbyExample-fpd-example2.R).

## Example 3

This is an extension of example 2, but now encapsulates the 
replicate weight pattern in the function `recs_mean_brr` which can be found in
[RbyExample-fpd-recs_funcs.R](./RbyExample-fpd-recs_funcs.R)

## Tips for writing functions using dplyr

1. Start simple and don't be afraid to do some of the work outside of the function.

1. Use the `_at` scoped variant of dplyr verbs, 
   e.g. `summarize_at` or `mutate_at` to pass columns to operate on as
   character vectors. Use the "lambda function" formulation of `.funs` if you
   need to make use of auxillary variables (such as weights).

1. Use `.data[!!var]` to access a specific variable using a character string.

1. Use base R where needed, keeping in mind that tibbles/data.frames are lists.

1. Use ` !!new_var := ...` to name a new variable using a length one character
vector `new_var`.

1. Use "quosures" and quasi-quotations as a last resort, see `vignette('programming', package = 'dplyr')`. Personally, I avoid this outside the use of `.data[!!var]`.



