# R packages 
#
# Updated: September 6, 2020
# Author: James Henderson
# 79: -------------------------------------------------------------------------

# libraries: ------------------------------------------------------------------
#! load packages at the start of your script
library(tidyverse); library(data.table)


# installation: ---------------------------------------------------------------
# installing from CRAN
install.packages('lme4', lib = .libPaths()[1])

# installing from github
#install.packages('devtools')
#devtools::install_github("tidyverse/dplyr")

# package location: -----------------------------------------------------------

## see default, usually best to leave default alone
.libPaths()

## change to another library
.libPaths('/Users/jbhender/Rlib')

#install.packages('lme4', lib = '/Users/jbhender/Rlib')

# using packages: -------------------------------------------------------------

## use library to add it to the search path, not "require" except in functions
search()
library(lme4)
search()
#! Note the location
help(library)

## use detach to remove a package from the search path
#InstEval
detach(package:lme4, unload = TRUE )
?detach
search()

## access exported (public) objects with ::
head(lme4::InstEval)
#InstEval = lme4::InstEval
#data(InstEval, package = 'lme4')
#data(package = 'lme4')

## access non-exported (private) objects with :::
fm1 = lme4::lmer(Reaction ~ Days + (Days | Subject), sleepstudy)
anova(fm1)
anova
lme4::anova.merMod
lme4:::anova.merMod

## common use case
MASS::glm.nb()
#MASS::select()

# 79: -------------------------------------------------------------------------