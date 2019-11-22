# Rcpp examples taken (mostly) directly from Chatper 25 of 
# Advanced R, by Hadley Wickham 
# 
# Some examples have been modified or extended to illustrate concepts.
#
# https://adv-r.hadley.nz/rcpp.html#rcpp-intro
# Updated: November 22, 2019

## library: -------------------------------------------------------------------
library(Rcpp)

## 1. one simple function: ----------------------------------------------------
one = function() 1L

cppFunction('
int one_cpp() {
 return 1; 
}
')

## call the functions
one()
one_cpp()
one_cpp
help(cppFunction)

# 2. sign functions: ----------------------------------------------------------
signR <- function(x) {
  if (x > 0) {
    1L
  } else if (x == 0) {
    0L
  } else {
    -1L
  }
}

cppFunction('
int signC(int x) {
  if (x > 0) {
    return 1;
  } else if (x == 0) {
    return 0;
  } else {
    return -1;
  }
}
')

cppFunction('
int signC2(int &x) {
  if (x > 0) {
    return 1;
  } else if (x == 0) {
    return 0;
  } else {
    return -1;
  }
}
')

## timing comparisons
bench::mark(signR(3L), signC(3L), signC2(3L))
bench::mark(signR(-3L), signC(-3L), signC2(-3L))

# 3. Euclidean distance between scalar and vector: ----------------------------
pdistR <- function(x, ys) {
  sqrt((x - ys) ^ 2)
}

cppFunction('
NumericVector pdistC(double x, NumericVector ys) {
  int n = ys.size();
  NumericVector out(n);
            
  for(int i = 0; i < n; ++i) {
    out[i] = sqrt(pow(ys[i] - x, 2.0));
  }
    return out;
}
')

cppFunction('
NumericVector pdistC2(double &x, NumericVector &ys) {
  int n = ys.size();
  NumericVector out(n);
  
  for(int i = 0; i < n; ++i) {
    out[i] = sqrt(pow(ys[i] - x, 2.0));
  }

  return out;
}
')

y = runif(1e6)
bm2 = bench::mark(pdistR(0.5, y), pdistC(0.5, y))
bm2

#


