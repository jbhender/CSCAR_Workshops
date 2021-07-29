## R Short Course, Part 2: Exercises

### Agenda

+ Welcome [2-2:05]
+ Questions about Part 2 [2:05-2:20]
+ Exercise Set 1
  - Breakout [2:20-2:35]
  - Discussion [2:35-2:45]
+ Exercise Set 2
  - Breakout a [2:45-3:15]
  - Discussion [3:15-3:30]


If we end early, consider playing a game of Master Mind to prepare you
for the practicum.

https://www.webgamesonline.com/mastermind/

##  Exercise Set 1

These exercises consist of several multiple choice
questions to discuss with your group.

  1. Which of the following is not the same as the others?
   a. `df$a`
   a. `df[1]`
   a. `df[['a']]`
   a. `df[, 1]`

  2. Which of the following are equivalent to `length(df)`? Choose all that apply.
   a. `nrow(df)`
   a. `ncol(df)`
   a. `3 * nrow(df)`
   a. `length(df[['a']])`
   a. `length(df[1:3])`

  3. Which of the following are equivalent to `length(df$a)`? Choose all that apply.
   a. `nrow(df)`
   a. `ncol(df)`
   a. `3 * nrow(df)`
   a. `length(df[['a']])`
   a. `length(df[1:3])`



## Exercise Set 2

In this exercise you will use data from the 2009 RECS
to compare the percentage of homes with internet access
between urban and rural areas. A template script, including
a high-level outline of the analytic plan and partial code is
available as
[rsc_part2_exercise_template.R](./rsc_part2_exercise_template.R). 

In this script, comments within *<angle brackets>* are inteneded
as instructions to you. You will likely only have time to finish part of
this -- that's okay.  

I recommend you refer to the example script
[recs_case_study.R](../../examples/part2/recs_case_study.R)
for hints as we will follow the same general outline.

1. Download the template script:
   [rsc_part2_exercise_template.R](./rsc_part2_exercise_template.R)
2. Open the script in RStudio (or your IDE) and update the header.
3. Execute the code in the first section labeled "data" to download the data.
4. Create a minimal dataset `recs` by (a) limiting `recs_all` to the key
   variables in `vars` and using the names of `vars` as the names of `recs`.
5. Filter out cases that have `internet` (originally `INTERNET`) less than zero
   as the question was not applicable to these homes.
6. Use the re-merge technique to create normalized weights
   (`weight` originally `NWEIGHT`)
   within levels of `urban` (orginally `UR`). Normalized weights sum to 1.
7. Use `aggregate()` to compute point estimates by group. Specifically,
   sum the normalized weight times `internet` times 100 to estimate the percentage
   of homes with home internet access in each level of `urban`.
8. Execute the code block "pivot weights to long for variance estimation" to
   reshape the replicae weights to a long format.
9. Merge the replicate weights with the focal `recs` dataset.
10. Use re-merging to normalize the replicate weights within levels of
    urban and replicate.
11. Use aggregate to compute replicate estimates of the percent of homes
    with home internet access (similar to step 7).
12. Merge the replicate estimates and the point estimates. 
13. Compute the variance as the mean squared deviation of the replicate
    estimates from the point estimates, times the Fay adjustment, within
    levels of urban.
14. Merge the variance and point estimates into a single data frame.
15. Use `within()` to create lower and upper bounds for the 95% CI as 
    point estimate +/- z * se, where the standard error se is the square 
    root of the variance from step 13 and z is given above. 