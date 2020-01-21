## Abstract

This focus for this workshop is on analyzing winter home temperatures in the US
using data from the 
[Residential Energy Consumption Survey](https://www.eia.gov/consumption/residential/). 
We’ll use the [tidyverse](tidyverse.org) throughout, 
relying on the dplyr package for data manipulations and ggplot2 for plotting. 

The workshop is organized in a parallel fashion, with participants given time
to build an analysis from scratch by adapting presented examples step by step. 
In the process, participants will become familiar with core dplyr functions, 
pivoting using tidyr, and a basic ggplot2 example.

This workshop is geared towards beginner to intermediate R users.

## Motivating Questions

> Which census region has the coolest home temperatures during winter? 

In this workshop, I'll share with you an analysis answering this question using
the tidyverse in R. As we go, I'll ask you to adapt my example step-by-step 
to answer the question below.

> How does thermostat behavior impact the difference between day and night
temperatures in winter at home?

## RECS

The Residential Energy Consumption Survey (RECS) is a household
survey focused on home energy use in the US caried out by the 
Energy Information Administration. 

This data allows us to answer meaningful questions about home 
energy use. Doing so requires forming weighted estimates by group -
a convenient example for learning core dplyr functionality.

In addition, the data contain a number of replicate weights that can 
be used to compute standard errors for survey weighted estimates. This
form of repetition is an opportunity to learn an important form of
"vectorization" in R. Vectorization is a technique wherein we  organize 
our R code to avoid explicit loops and instead rely on functions that
implement these loops in a lower level machine language (e.g. C/C++). 

The "microdata" at the household level can be found at:
https://www.eia.gov/consumption/residential/data/2015/index.php?view=microdata.

We'll use the linked csv file.  We'll also take a look at the variable
and response codebook (the XLS link).  There we'll review the following
key variables:

 - DOEID 
 - REGIONC
 - EQUIPMUSE
 - TEMPHOME
 - TEMPGONE
 - TEMPNITE
 - NWEIGHT
 - BRRWT1-BRRWT96


## Overview




## Example

### Step 1 - Header and libaries

1. Open the template script 
1. Update the description, details, author, and date information.
1. Use `library` to add `"tidyverse"` to the search path. 

### Step 2 - I/O and data prep

In this step we'll read in the data, select and format variables we'll need, and
filter the rows to the set of relevant cases. 

In the exercise, you'll want to first set aside the replicate weights for later use:
  - DOEID
  - BRRWT1-BRRWT96

Next, in the primary data keep the variables below:
  - DOEID
  - NWEIGHT
  - ??  , our grouping variable
  - ??  , response variable

Then, select the subset of cases 

### Step 3 - 

