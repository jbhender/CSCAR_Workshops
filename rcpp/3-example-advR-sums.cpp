// [[Rcpp::plugins(cpp11)]]
#include <numeric>
#include <Rcpp.h>
using namespace Rcpp;

// Various implementations of "sum" from Ch 25 of Advanced R
//https://adv-r.hadley.nz/rcpp.html

// [[Rcpp::export]]
double sumC(NumericVector x) {
  int n = x.size();
  double total = 0;
  
  for(int i = 0; i < n; ++i) {
      total += x[i];
  }
  return total;
}

// [[Rcpp::export]]
double sum3(NumericVector x) {
  double total = 0;
  
  NumericVector::iterator it;
  for(it = x.begin(); it != x.end(); ++it) {
    total += *it;
  }
  return total;
}

// [[Rcpp::export]]
double sum4(NumericVector xs) {
  double total = 0;
  
  for(const auto &x : xs) {
    total += x;
  }
  return total;
}

// [[Rcpp::export]]
double sum5(NumericVector x) {
  return std::accumulate(x.begin(), x.end(), 0.0);
}


/*** R
x = rnorm(1e6)
bench::mark(sum(x), sum3(x), sum4(x), sum5(x))
*/
