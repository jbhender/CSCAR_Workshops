# Learning to predict from the "isolet" data using elastic net (glmnet). 
#
# We will learn to predict which letter is represented in 
# an audio recording of a person speaking a
# single (English) letter (an "isolet") using elastic net.
#
# In this example, we train over a sequence of values for alpha,
# the elastic net mixing parameter, and examine the regularizationa path
# for lambda - the penalty scale parameter. 
#
# The best fiting model achieved an accuracy of ~95%. 
#
# Data comes from here:
# https://archive.ics.uci.edu/ml/machine-learning-databases/isolet/
#
# Author: James Henderson
# Updated: March 18, 2020

# libraries: ------------------------------------------------------------------
library(tidyverse); library(data.table); library(glmnet);
#library(future); plan(multisession)
library(doParallel)

# set up parallel backend: ----------------------------------------------------
cl = makeCluster(3)
registerDoParallel(cl)

# read in the data: -----------------------------------------------------------
path = '~/github/mlexamples/data/'
iso_train = fread(sprintf('%sisolet1+2+3+4.data', path), header = FALSE)
iso_test = fread(sprintf('%sisolet5.data', path), header = FALSE)

# prep the data: --------------------------------------------------------------

## training data
Xtrain = as.matrix(iso_train[, 1:617])
Ytrain = factor(iso_train[[618]])

## folds -- assign by individual
iso_train = iso_train %>% 
  mutate( a = V618 == 1, 
          z = V618 == 26,
          id = c(1, 1 + cumsum( a[-1]*z[-n()] ))
  )
ids = unique(iso_train$id)
fold_id = rep(1:10, each = 18)
names(fold_id) = sample(ids)
iso_train = iso_train %>% mutate( foldid = fold_id[as.character(id)] )
foldid = iso_train$foldid

## testing data
Xtest = as.matrix(iso_test[, 1:617])
Ytest = factor(iso_test[[618]])

# visualize of training data: -------------------------------------------------

## heatmap
#image(1:617, 1:617, cor(Xtrain), xlab = '', ylab = '', las = 1)

X.svd = svd(Xtrain)
iso_train = mutate( iso_train,
            id = factor(id, ids),
            pc1 = X.svd$u[, 1],
            pc2 = X.svd$u[, 2],
            y = Ytrain
)

filter(iso_train, id %in% c('1', '2') ) %>%
  ggplot( aes( x = pc1, y = pc2, color = id, pch = y) ) +
  geom_point(size = 2) +
  theme_bw() +
  scale_shape_manual(values = LETTERS) +
  guides( pch = "none" )

# multionomial elastic net: ---------------------------------------------------
alphas = seq(0, 1, 0.2) 
fits = vector( mode = 'list', length = length(alphas) )
cvloss = array(0.0, dim = c(3, 2, length(alphas) ),
               dimnames = list( result = c('lambda', 'cvm', 'cvsd'),
                                type = c('min', '1se'),
                                alpha = as.character(alphas)
                                ))

file = './isolet_ex1-glmnet_results.RData'
if ( file.exists(file) ) {
  load(file) # fits, cvloss
} else {
  # each loop takes ~28 minutes using 3 cores for cv.glmnet, so run with care
  for ( alpha in alphas ) {
  
    tm = proc.time()[3]
    # cv.glmnet would do this for us, but this allows us to illustrate
    fit1 = glmnet(Xtrain, Ytrain, family = 'multinomial', alpha = alpha)
    lambda = fit1$lambda
  
    # cross validated fit
    fit1.cv = cv.glmnet(Xtrain, Ytrain, family = 'multinomial',
                      lambda = lambda, alpha = alpha, 
                      foldid = foldid, parallel = TRUE)
  
    # store both fits, though the cv would probably do
    aidx = which(alpha == alphas)
    fits[[aidx]] = list( fit = fit1, fit.cv = fit1.cv, alpha = alpha)
 
    # parameters and 
    idx = with(fit1.cv, which( lambda %in% c(lambda.min, lambda.1se) ) )[2:1]
    cvloss[1, , aidx] = with(fit1.cv, lambda[idx])
    cvloss[2, , aidx] = with(fit1.cv, cvm[idx])
    cvloss[3, , aidx] = with(fit1.cv, cvsd[idx])  
  
    tm = round({tm - proc.time()[3]}/60, 1)
    cat('Finished alpha =', alpha, '...', tm, 'minutes\n')
  }
  save(fits, cvloss, file = file)
} # ends "else" for if ( file.exists(file) )

#dim(cvloss)
cvloss[2, , ]
#cvloss[, , 1]

# Plot the results: -----------------------------------------------------------
plot(fits[[2]]$fit.cv)
plot(fits[[2]]$fit.cv, xlim = c(-9, -6), ylim = c(0.25, 0.4))
#log(cvloss[1,,2])

# Evaluate test error: --------------------------------------------------------
yhat = predict(fits[[2]]$fit, Xtest, type = 'class')
idx = which(fits[[2]]$fit$lambda %in% cvloss[1, , 2])
apply(yhat[, idx] == Ytest, 2, mean) #95.6%

# Shutdown cluster: -----------------------------------------------------------
stopCluster(cl) 

