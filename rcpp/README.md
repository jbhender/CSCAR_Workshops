## Rcpp: Integrating C++ into R

The Rcpp package for R makes integrating C++ intro R seamless.

To do this it:
  + provides C++ classes for working with many common R data structures,
  + automates the process of compiling C++ code and making it callable in R,
  + makes some R functions callable from C++ to ease the prototyping process,    
  + provides "syntactic sugar" enabling R programmers to more readily write C++.

## References

  + `vignette("Rcpp-introduction")`
  + Advanced R, [Chapter 25](https://adv-r.hadley.nz/rcpp.html#rcpp-intro)
  + http://rcpp.org/ 
  + http://www.learncpp.com/ 

## Examples

  + [0-example-advr-25.2.R](./0-example-advr-25.2.R)
    Intrdocutory examples using `cppFunction()`
  + [1-example-signC_vec.cpp](./1-example-signC_vec.cpp)
    Additional examples using `sourceCpp()`.  
  + [2-example-advR-meanC.cpp](2-example-advR-meanC.cpp)
  + https://gallery.rcpp.org/articles/r-function-from-c++/ 
  + https://jbhender.github.io/Stats506/F17/Using_C_Cpp.html

## Going Further

 + [Rcpp Gallery](https://gallery.rcpp.org/)
 + [RcppArmadillo](https://github.com/RcppCore/RcppArmadillo)
 + [RcppEigen](http://dirk.eddelbuettel.com/code/rcpp.eigen.html)
 + [Boost](https://www.boost.org/) and the 
   [BH](https://gallery.rcpp.org/articles/using-boost-with-bh/) package.

## About 
Notes for a CSCAR workshop last presented November 22, 2019.

