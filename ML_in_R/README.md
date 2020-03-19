# Machine Learning in R

## About
* This workshop is being held online, registered participants should
have recieved a link to a BlueJeans meeting at their umich email address.*

[March 19, 2-4pm](https://ttc.iss.lsa.umich.edu/ttc/sessions/machine-learning-in-r/)

## Resources

[The Elements of Statistical Learning](https://web.stanford.edu/~hastie/ElemStatLearn/)

[Introduction to Machine Learning](https://m-clark.github.io/introduction-to-machine-learning/)

## Examples

[Isolet data](https://archive.ics.uci.edu/ml/machine-learning-databases/isolet/)

[Data

## Machine Learning Concepts

## The Isolet data

The [Isolet](https://archive.ics.uci.edu/ml/machine-learning-databases/isolet/)
dataset we will use for examples today consists of data from recordings of
XX individuals pronouncing each letter of the English alphabet. It is *tabular*
data meaning that features (variables) of interest have already been extracted.

Because each person vocalizes more than one letter, our data are not independent.
While not adjusting for this fact in our loss function, we will take this into
consideration when assigning cross-validation folds. We do this because predicting
spoken letters from a new individual is different from (possibly harder than)
predicting an unheard letter from an individual in our training data.

The testing and training split created by the data authors already accounts for
this. The data were collected in 5 waves, with the first 4 waves being training
data and the $5^{th}$ used for testing.  We will use the same distinction.

For validation, we will use 10-fold cross validation assigning all data for each
individual to the same fold. In this way, our validation evaluations will more closely
resemble our intended tesitng scheme. 

## Elastic Net

### Overview
The elastic net is a form of penalized regression for generalized linear models
and similar regression problems such as the Cox model. In addition to the usual
likelihood based loss or deviance, it penalizes the regression coefficients $\beta$
using:

$$
J(\beta; \alpha, \lambda) = \lambda \left( \frac{1 - \alpha}{2} ||\beta||^2_2 + \alpha||\beta||_1\right).
$$

For a continuous response variable with a Guassian likelihood, the standard regression
problem becomes:

$$
\hat \beta = \arg\min_{\beta} \frac{1}{2n}||Y-X\beta||^2 + J(\beta; \alpha, \lambda).
$$



### Key Functions and Arguments

+ `glmnet()` -
  - `x` the model matrix (usually without intercept) 
  - `y` the response varaible
  - `family` the GLM family / likelihood to use
  - `alpha` the elastic net mixing parameter
  - `nlambda` how many lambdas to fit the model for
  - `standardize` if `TRUE`, internally rescales columns of `x` to have variance 1
  - `intercept` if `TRUE` and intercept is fit. 
  
+ `cv.glmnet()` 

## Gradient Boosting

### Overview

Boosting is a method for building an additive classifier or regression function from
a collection of simpler functions such as linear models or trees.  There are three
key ideas:

+ Simpler classifiers are combined sequentially,

### Key Functions and Arguments

+ `xgb.DMatrix` - construct a training matrix in the format used by `xboost`
+ `xgb.train` - trains the gradient boosted classifier
  - params - a list of parameters controlling the model space and training
  - data - the data as created using `xgb.DMatrix`
  - nrounds - the maximum number of boosting rounds during training
  - watchlist - used to get feedback on validation data as training progresses

+

## Random Forest

### Overview

Random forests are one of the easiest to use ML tools for tabular data and
often need very little tuning. In addition, the algorithm allows for an
"out-of-bag" estimate of the error rate that makes use of a validation
dataset or cross-validation scheme largely redundant.

Below is the random forest algorithm as described in ESL.
![](./img/rf-algo.png)


