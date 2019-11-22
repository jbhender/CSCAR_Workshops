#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
IntegerVector signC_vec1(NumericVector x){
 int n = x.size();
 IntegerVector s(n);
 
 for (int i = 0; i < n; ++i) {
   if (x[i] > 0) {
     s[i] = 1;
   } else if (x[i] < 0) {
     s[i] = -1; 
   } else {
     s[i] = 0;
   }
 }
 
 return s; 
}

// A second function, calling the simpler signC function.
int signC(double x);

// [[Rcpp::export]]
IntegerVector signC_vec2(NumericVector x) {
  int n = x.size();
  IntegerVector s(n);
  
  for (int i=0; i < n; ++i) {
    s[i] = signC(x[i]);
  }
  
  return s;  
}

int signC(double x) {
  int s;
  if (x > 0) { 
    s = 1; 
  } else if (x < 0) {
    s = -1; 
  } else {
    s = 0;
  }
  
  return s; 
}

/*** R
## R functions
signR =  function(x) {
  if (x > 0) {
    1L
  } else if (x == 0) {
    0L
  } else {
    -1L
  }
}

signR_vec1 = function(x) {
  vapply(x, signR, 0L)
}

signR_vec2 = function(x) {
  ifelse(x > 0, 1L, ifelse(x < 0, -1L, 0L))
}

x = rnorm(1e3)
bm_sign = bench::mark(signR_vec1(x), signR_vec2(x), 
                      signC_vec1(x), signC_vec2(x))
bm_sign
*/
