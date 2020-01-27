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

We will use the variables above to answer the questions of interest. Here is
an outline for how we'll approach this. 

1. Prepare an R script by writing a header and loading needed packages.
1. Read the data from the web and create a local copy, using a flag to 
determine when the local copy is already available to read from. 
1. Clean our data by formatting variables and giving them memorable names. 
1. Prepare the replicate weights in a "long" format.
1. Select cases (rows) to be used for the analysis.
1. Estimate the quanity of interest using the split-apply-combine or 
"aggregate by group" pattern.
1. Join the weights to our original data and create replicate estimates.
1. Join our original estimates and the replicate estimates to compute
standard errors and form confidence intervals.
1. Visualize the results using ggplot2.  

## Example

### Step 1 - Header and libaries

Before beginning, we'll state our goals and use a header to document your work.
1. Open the template script 
1. Update the title, description, author, and date information.
1. Use `library` to add `"tidyverse"` to the search path. 

### Step 2 - Read data

In this step you'll read in the data, select and format needed variables,  and
filter the rows to the set of relevant cases. 

First, read in the data using the template provided in the example. Use a file
flag to decide whether to read from the URL or use a local copy.

### Step 3 - Prep data

Next, create a "core" data set with the variables below:
  - DOEID
  - NWEIGHT
  - ??  , our grouping variable
  - ??  , response variables

Also, set aside the replicate weights for later use and pivot them to a long
format:
  - DOEID
  - BRRWT1-BRRWT96

Finally, select the subset of homes that use space heating in winter. 

### Step 4 - Point Estimates

Steps 1-3 are the initial phase of almost every analysis. Now, you're ready to 
begin the analytic tasks. These will tend to differ between analyses.

In this analysis, the first step is to form point estimates of the

