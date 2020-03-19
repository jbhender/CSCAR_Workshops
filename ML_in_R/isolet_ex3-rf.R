# Random Forest approach to the isolet data
#
# We will learn to predict which letter
# an audio recording of a person speaking a
# single (English) letter is using elastic net.
#
# Data comes from here:
# https://archive.ics.uci.edu/ml/machine-learning-databases/isolet/
#
# Author: James Henderson
# Updated: March 18, 2020
# 80: --------------------------------------------------------------------------

# libraries: -------------------------------------------------------------------
library(tidyverse); library(randomForest)

# read in the data: ------------------------------------------------------------
path = './data/'
iso_train = data.table::fread(sprintf('%sisolet1+2+3+4.data', path), header = FALSE)
iso_test = data.table::fread(sprintf('%sisolet5.data', path), header = FALSE)

# prep the data: ---------------------------------------------------------------

## training data
Xtrain = {as.matrix(iso_train[, 1:617]) + 1} / 2
Ytrain =  as.factor( iso_train[[618]] - 1 )

## testing data
Xtest = {as.matrix(iso_test[ , 1:617]) + 1} / 2
Ytest = as.factor( iso_test[[618]] - 1 )

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

# train the random forest model: ----------------------------------------------
set.seed(42)
val_folds = sample(1:10, 2, replace = FALSE)
validx = which(foldid %in% val_folds)

# 153s
tm1 = system.time({ 
  rfmodel1 = randomForest(Xtrain[-validx, ], y = Ytrain[-validx] )
})
## Out of bag (OOB) error rate
#rfmodel1
1 - mean( rfmodel1$predicted == Ytrain[-validx] )

# evaluate the model on the validation data, adjust/pick hyperparameters as 
# needed.
yval = predict(rfmodel1, Xtrain[validx,])
mean(yval == Ytrain[validx]) # 94.45%

# 314s
tm2 = system.time({ 
  rfmodel2 = randomForest(Xtrain[-validx, ], y = Ytrain[-validx],
                          ntree = 1e3, mtry = 36)
})
rfmodel2 #5.49%
mean( rfmodel1$predicted == Ytrain[-validx] ) #94.33%
mean( predict(rfmodel2, Xtrain[validx,]) == Ytrain[validx] ) #94.08%

# refit the model to entire training set: --------------------------------------
#~213s or ~4min
tm3 = system.time({ 
  rfmodel3 = randomForest(Xtrain, y = Ytrain)
})

#evaluate the final model on the test set: -------------------------------------
yhat_test = predict(rfmodel3, Xtest)
mean(yhat_test == Ytest) #~95%

# our model most frequently misclassifies "b" as "v"
class_mat = table(yhat_test, Ytest)
conf_mat = class_mat * {class_mat < min(diag(class_mat))}
letters[which( conf_mat == max(conf_mat), arr.ind = TRUE)]


