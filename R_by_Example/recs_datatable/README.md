# R By Example: Analyzing RECS using data.table

## Abstract

The focus for this workshop is on analyzing winter home temperatures in the US
using data from the 
[Residential Energy Consumption Survey](https://www.eia.gov/consumption/residential/). 
We’ll use [data.table](https://github.com/Rdatatable/data.table/wiki) syntax throughout for data manipulation.

The workshop is organized in a parallel fashion, with participants given time
to build an analysis from scratch by adapting presented examples step by step. 
In the process, participants will become familiar with core data.table fuctionality, 
pivoting using the `melt` method, and a basic ggplot2 example.

This workshop is geared towards beginner to intermediate R users.

## Motivating Questions

> Which census region has the coolest home temperatures during winter? 

In this workshop, I'll share with you an analysis answering this question using
data.table in R. As we go, I'll ask you to adapt my example step-by-step 
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

The "microdata" at the household level can be found at this [link](https://www.eia.gov/consumption/residential/data/2015/index.php?view=microdata).

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

## Files

The files for this workshop can be found at my
[CSCAR_Workshops](https://github.com/jbhender/CSCAR_Workshops/tree/master/R_by_Example/recs_datatable) repository on Github.

Here is a list of files:

 - [RbyExample-recs_dt-example.R](./RbyExample-recs_dt-example.R) - 
 instructor example
 - [RbyExample-recs_dt-template.R](./RbyExample-recs_dt-template.R) - a 
 template R script to help you get started on the exercise.
 - [RbyExample-recs_dt-solution-a.R](./RbyExample-recs_dt-solution-a.R) -
 solution to participant exercise
 - [RbyExample-recs_dt-solution-a-hints.html](./RbyExample-recs_dt-solution-a-hints.html) - exercise instructions with buttons to reveal the solution step by step
 - [RbyExample-recs_dt-solution-a-hints.R](./RbyExample-recs_dt-solution-a-hints.R) - source code for the "hints" document above, written using spin. 
 - [RbyExample-recs_dt-solution-b.R](./RbyExample-recs_dt-solution-b.R) - 
 solution to the second approach, suggested as a take-home exercise. 
 - [RbyExample-recs_dt-solution.R](./RbyExample-recs_dt-solution.R) - 
 participant solution combining approaches (a) and (b) discussed below.

## Overview

We will use the variables above to answer the questions of interest. Here is
an outline for how we'll approach this. 

1. Prepare an R script by writing a header and loading needed packages.
1. Read the data from the web and create a local copy, using a flag to 
determine when the local copy is already available to read from. 
1. Clean our data by formatting variables and giving them memorable names. 
1. Prepare the replicate weights in a "longer" format.
1. Select cases (rows) to be used for the analysis.
1. Estimate the quanity of interest using the split-apply-combine or 
"aggregate by group" pattern.
1. Join the weights to our original data and create replicate estimates.
1. Join our original estimates and the replicate estimates to compute
standard errors and form confidence intervals.
1. Visualize the results using ggplot2.  

I'll demonstrate each of the steps above using the script 
`RbyExample-recs_dt-example.R`. 

## Participant Example 

> How does thermostat behavior impact the difference between day and night
temperatures in winter at home?

There are two ways to approach the question above:
  a. Estimate day and night temperatures for each group and compare visually
  a. Estimates the difference between day and night temperatures by group.

I've provided solutons to each of these as `RbyExample-recs_dt-solution-a.R`
and `RbyExample-recs_dt-solution-b.R`, respectively.  During the workshop,
I'd suggest you develop the solution to approach (a). I'd recommend you use
approach (b) as an exercise after the workshop to help solidify your 
understanding. 

Below you can find instructions for the example.  Use this 
[link](./RbyExample-recs_dt-solution-a-hints.html) for a solution that can
be unfolded step by step or 
[download](RbyExample-recs_dt-solution-a.R) the solution here. 

### Step 1 - Header and libaries

Before beginning, we'll state our goals and use a header to document our work.
1. Open the template script 
1. Update the title, description, author, and date information.
1. Use `library` to add `"tidyverse"` and `"data.table"` to the search path. 

### Step 2 - Read and format data

In this step we'll read in the data, select and format needed variables, and
filter the rows to the set of relevant cases. 

First, read in the data using the template provided in the example. Use a file
flag to decide whether to read from the URL or use a local copy.

### Step 3 - Prep data

Next, create a "core" data set with the variables below:

  - DOEID (`id`)
  - NWEIGHT (`weight`)
  - HEATHOME (`heat_home`)
  - EQUIPMUSE (`therm`)
  - TEMPHOME (`temp_home`)
  - TEMPNITE (`temp_night`)

In that data set, convert negative numbers to explicit missing values (`NA`) and
use a `factor` to provide meaningful labels for `heat_home` and `therm`. 

Next, select the subset of homes that use space heating in winter. 

Finally, set aside the replicate weights for later use and pivot them to a
longer format:

  - DOEID (`id`)
  - BRRWT1-BRRWT96


### Step 4 - Point Estimates

Steps 1-3 are the initial phase of almost every analysis. Now, you're ready to 
begin the analytic tasks. These will tend to differ between analyses.

In this analysis, the first step is to form point estimates of the average
national day with someone home and night temperatures. Do that by forming
weighted (NWEIGHT/`weight`) means of these temperatures (TEMPHOME/`temp_home`,
TEMNITE/`temp_night`) by group (EQUIPMUSE/`therm`). 

To produce the plot at the end of this analysis, we'll want the temperatures in
a longer format -- this is a good time to achieve that using `melt()`.

### Step 5 - Replicate Estimates

Recall that this is survey data and not an identically distributed sample of US 
households. As such, to estimate standard errors we will use the replicate
weights method in which we repeatedly recomptue the estimates from step 4, each
time replacing NWEIGHT/`weight` with one of the 96 replicate weights.  To do
this efficiently:

1. Create a dataset where each row is a home (id), temperature type, and replicate
weight. This dataset will have 96 rows for each row of the dataset in step 4.
To do this, join the longer format weights from step 1 with the dataset from
step 4.

1. Next, re-compute point estimates for each set of replicate weights.  To do
this, re-use the code from step 4 and add the identifier for the replicate weights
to the `by` argument. 

The result should have rows giving the weighted average temperature for each 
unique combination of thermostat behavior, temperature type, and set 
of replicate weights. 

### Step 6 - Standard Errors and confidence bounds

Once we have the replicate estimates for our quantities of interest, we estimate
the variance of the point estimates from step 4 using the sum of squared 
deviations of the replicate estimates around the original point estimates, 
scaling up by a factor determined in the process of formulating the replicate 
weights. The standard error is the square root of this variance estimate.

To accomplish this:

  1. Join the point estimates from step 4 with the replicate
estimates from step 5.
  1. Estimate the standard error for each point estimate, using the same grouping
structure as used in step 4 to form the point estimates.
  1. Add columns `lwr` and `upr` for, respectively, the lower and upper 95% 
confidence bounds using the point estimate +/- $\Phi^{-1}(.975)$ (or 1.96) 
times the standard error.

### Step 7 - Plot the results

Create a plot of the results using ggplot2 and following the template from
the example.








