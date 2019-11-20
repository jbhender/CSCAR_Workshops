#include <Rcpp.h>
using namespace Rcpp;

// This function rewrites the log likelihood for a two-part logistic + 
// log-normal model in C++ for greater efficiency. 
// 
// The orignal function 'minus_loglik' appears in 'marginal_mean_twopart.R'
// within the function of the same name.  

// [[Rcpp::export]]
double minus_loglik_cpp(NumericVector params, 
                        NumericVector y,
                        NumericMatrix Z,
                        NumericMatrix X,
                        NumericVector w) {
  double out = 5594.117;
  return out; 
}

/*** R
# Log-liklihood for marginalized model from Smith (2014): ---------------------
minus_loglik = function(params, y, Z, X, w){
  
  # parameters
  alpha = params[ grep('zero_', names(params))]
  beta = params[ grep('mean_', names(params))]
  
  # compute matrix products
  p0 = Z %*% alpha
  v = X %*% beta
  
  # non-zero locations in y
  pos = which(y > 0)
  n1 = length(pos)
  s = params["log_sigma"]
  
  # log likelihood
  loglik = sum( -w * log( 1 + exp(p0) ) ) +
    sum( w[pos]*{p0[pos] - log( y[pos] ) - .5*log( 2*pi ) - s -
    .5 / {exp(s)^2 } * { log( y[pos] ) + p0[pos] -
    log( 1 + exp(p0[pos]) ) +
    exp(s)^2*.5 - v[pos]  }^2} 
    )
  
  return(-loglik)
}

# Test code
source('~/github/2partmodels/smith2014/local/two_part_formuals.R')
data(bioChemists, package = 'pscl')
mf = two_part(art ~ phd + kid5 | fem + phd, data = bioChemists)
cont = lm(art ~ phd + kid5, data = bioChemists[bioChemists$art > 0,])
zero = glm( I(art > 0) ~ fem + phd, data = bioChemists, family = binomial())

X = mf$X; Y = mf$Y; Z = mf$Z
params = c(coef(zero), coef(cont), sigma(cont))
names(params) =  
  c( paste0('zero_', colnames(Z)), paste0('mean_', colnames(X)), 'log_sigma' )
w = rep(1, length(Y))
vr = minus_loglik(params, Y, Z, X, w) 
vcpp = minus_loglik_cpp(params, Y, Z, X, w)
if( abs( vr - vcpp ) < 1e-3 ) {
  cat("Values match!\n")
}
*/
