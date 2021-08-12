## R Short Course, Part 4: Exercises

### Agenda

+ Welcome [2-2:05]
+ Questions about Part 4 [2:05-2:20]
+ Exercise Set 1
  - Live coding [2:20-3:25] *or*
  - Breakout 1 [2:20-2:35]
  - Discussion [2:35-2:50]
  - Breakout 2 [2:50-3:10]
  - Discussion [3:10-3:25]
+ Closing questions [3:25-3:30]

## Exercise

In this exercise, we will examine simulated data from field notes
recording interactions between individuals in a primate community.
This data has been simulated to resemble (in some respects) a real
data set I encountered some years back.

The names in the simulated data were selected at random from a list
of all babies issued social security numbers in the US during a
specific year in the 1980s. Links to the data for this problem can
be found in the [template](./rsc_part4_munge_template.R).

The first column of the "social" data contains names of individual
focus primates, the second a particular class of interaction, and
the third a comma separated list of others involved in the interaction.

The other two files provide unique names for the focal individuals
(those in the first column) and all individuals in the community
(including the focal individuals).

Starting after step 5, subset to rows with a problematic `toward` or
`who` entry to identify possible problemsn and solutons. 

1. Download and open the template [here](./rsc_part4_munge_template.R) 
   and update the header.
2. Format the "social" data for cleaning by:
   + use `tidyr::separate()` to split `toward` into columns
   + use `resahpe()` or `tidyr::pivot_longer()` to place each focal/toward
     pair in its own row.
3. Check that all of the `focal` entries in the `social` data are in the
   list of `focal` animals and, if needed, repair entry mistakes.
4. Check the validity of `toward` entriess based on the community data.
   How many invalid entries are there?
5. Make a column `who` as a copy of `toward` where you can repair names
   without losing the original entry. 
6. Use `str_trim()` and `str_to_title()` (from `stringr`) to remove
   extra whitespace and correct capitalization.
7. Remove empty entries after trimming (e.g. from a trailing comma).
8. Filter and then remove entries marked `?`.
9. Find potential matches with one deleted letter for the remaining
   problem names using a strin distance as implemented, e.g., in
   the `agrep()` function.
10. Replace 1 deletion matches in the working data frame.
11. Use `adist()` to compute a string distance between remaning
    unmatched names and possible matches from the community data.
12. Replace names having a unique minimum distance string in the
    original data frame.
13. Construct a data frame with umatched entries and possible matches. 
14. Construct a data frame of matches made in steps 9-12. 
   
You can download an example solution [here](./rsc_part4_munge_solution.R). 