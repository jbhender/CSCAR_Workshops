# Gradient Boosting Approach to the isolet data
# Cross-validation case study using the "isolet" data and glmnet. 
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
# 80: --------------------------------------------------------------------------

# libraries: -------------------------------------------------------------------
library(doParallel); library(tidyverse); library(xgboost)

# read in the data: ------------------------------------------------------------
path = '~/github/mlexamples/data/'
iso_train = data.table::fread(sprintf('%sisolet1+2+3+4.data', path), header = FALSE)
iso_test = data.table::fread(sprintf('%sisolet5.data', path), header = FALSE)

# prep the data: ---------------------------------------------------------------

## training data (rescaled to [0, 1])
Xtrain = {as.matrix(iso_train[, 1:617]) + 1} / 2
Ytrain =  iso_train[[618]] - 1 

## testing data
Xtest = {as.matrix(iso_test[ , 1:617]) + 1} / 2
Ytest =  iso_test[[618]] - 1 

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

# train the gbm model: --------------------------------------------------------
set.seed(42)
val_folds = sample(1:10, 2, replace = FALSE)
validx = which(foldid %in% val_folds)
tr.frac = {length(foldid) - length(validx)} / length(foldid)

dtrain = xgb.DMatrix(Xtrain[-validx, ], label = Ytrain[-validx])
dvalid = xgb.DMatrix(Xtrain[validx, ], label = Ytrain[validx])
Yvalid = Ytrain[validx]
dtest = xgb.DMatrix(Xtest, label = Ytest)
watchlist = list(train = dtrain, validation = dvalid)

# Model 1, just the basics: ---------------------------------------------------
param1 = list(max_depth = 2, eta = 1, 
              verbose = 1, nthread = 1,
              objective = "multi:softmax", num_class = 26,
              eval_metric = "merror")

#43s
tm1 = system.time({ 
 xgb1  = xgb.train(param1, dtrain, nrounds = 10,  watchlist = watchlist)
}) 
mean(predict(xgb1, dvalid) == Yvalid) #87.99%

# Model 2: --------------------------------------------------------------------
param2 = param1
param2$eta = 0.5; param2$max_depth = 4

# 116s
tm2 = system.time({ 
  xgb2  = xgb.train(param2, dtrain, nrounds = 20,  watchlist = watchlist)
})
mean(predict(xgb2, dvalid) == Yvalid) #92.78%

# Model 3: --------------------------------------------------------------------
param3 = param1
param3$eta = 0.25; param3$max_depth = 6

tm3 = system.time({ 
  xgb3  = xgb.train(param3, dtrain, nrounds = 50,  watchlist = watchlist)
}) 

## Accuracy on validation data
mean(predict(xgb3, dvalid) == Yvalid) #94.4%

## Get prediction for an earlier round (too limit overfitting)
mean( predict(xgb3, dvalid, ntreelimit = 47) == Yvalid ) #94.27%

# Model 4: --------------------------------------------------------------------
param4 = list( booster = 'gblinear',
               eta = 0.2,
               verbose = 1, nthread = 1,
               objective = "multi:softmax", num_class = 26,
               eval_metric = "merror")

tm4 = system.time({ 
  xgb4  = xgb.train(param4, dtrain, nrounds = 50,  watchlist = watchlist,
                    early_stopping_rounds = 5)
}) 
mean( predict(xgb4, dvalid, ntreelimit = 25) == Yvalid ) #95.53%

# Model 5: --------------------------------------------------------------------
param5 = param4
param5$lambda_bias = 0.01

tm5 = system.time({ 
  xgb5  = xgb.train(param5, dtrain, nrounds = 50,  watchlist = watchlist,
                    early_stopping_rounds = 5)
}) 
mean( predict(xgb5, dvalid, ntreelimit = 25) == Yvalid ) #95.53%

# Model 6: --------------------------------------------------------------------
param6 = param5
param6$subsample = 0.5

tm6 = system.time({ 
  xgb6  = xgb.train(param6, dtrain, nrounds = 50,  watchlist = watchlist,
                    early_stopping_rounds = 5)
}) 
mean( predict(xgb6, dvalid, ntreelimit = 25) == Yvalid ) #95.53%

# Compare all models on validation data, then refit chosen model to full data
# and predict. 

# Cross validation for models 4 and 5: ----------------------------------------
cl = makeCluster(2)
registerDoParallel(cl)

xv_error = mclapply(1:10, 
 function(fold) {
   # Set data
   validx = which(foldid == fold)  
   dtrain = xgb.DMatrix(Xtrain[-validx, ], label = Ytrain[-validx])
   dvalid = xgb.DMatrix(Xtrain[validx, ], label = Ytrain[validx])
   Yvalid = Ytrain[validx]
  
   # Train models
   xgb4f = xgb.train(param4, dtrain, nrounds = 25)
   xgb5f = xgb.train(param5, dtrain, nrounds = xgb5$best_ntreelimit)

   # Assess on validation fold
   c(mean( predict(xgb4f, dvalid) == Yvalid ),
     mean( predict(xgb5f, dvalid) == Yvalid) )
 }
)
stopCluster(cl)

apply(do.call("rbind", xv_error), 2, mean)

# Train selected model on the full training data: ------------------------------


      
