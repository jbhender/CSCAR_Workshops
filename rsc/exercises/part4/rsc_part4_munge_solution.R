# RSC Part 4, Munging Exercise Solution (Partial)
# In this exercise we clean up some artificial field notes on primate 
#  behavior.
#
# Author: James Henderson, PhD
# Updated: August 12, 2021
# 79: -------------------------------------------------------------------------

# libraries: ------------------------------------------------------------------
library(tidyverse)

# data: -----------------------------------------------------------------------

# unique primates being followed 
dt_focal = 
  read_delim(
    'https://jbhender.github.io/Stats506/F17/Stats506_F17_ps2_focal_names.csv',
    delim=',', 
    col_names = "name"
  )

# larger community of primates
dt_comm = 
  read_delim(
    'https://jbhender.github.io/Stats506/F17/Stats506_F17_ps2_all_names.csv',
    delim=',', 
    col_names = "name"
  )

# recorded social interactions
dt_social = 
  read_delim(
    'https://jbhender.github.io/Stats506/F17/Stats506_F17_ps2_interactions.csv',
    delim=','
  )

# separate into pairwise social interactions: ---------------------------------

## determine how many columns we expect to have
to_split = 
  with(dt_social,
       vapply(str_split(toward, ','), length, FUN.VALUE = 0L)
)
## number of columns we need
max_sep = max(to_split)

# how many rows to expect, sum(to_split)

# separate "toward" into distinct columns
social_sep = dt_social %>% 
  separate(
    col = toward,
    into = paste0("id", 1:max_sep),
    sep = ",",
    extra = "merge",
    fill = "right"
  )

# reshape into a longer format
social_long = social_sep %>%
  pivot_longer(
    cols = all_of(paste0('id', 1:max_sep)),
    names_to = 'id',
    names_prefix = 'id',
    values_to = 'toward'
  ) %>%
  filter(!is.na(toward))

#! Note: tidyr::seperate_rows() could be used to combined the steps above. 

# check and repair validity of `focal` entries: ------------------------------
social_long = social_long %>%
  mutate(ok_focal = focal %in% dt_focal[['name']])

#with(social_long, table(ok_focal))
stopifnot( all(social_long[['ok_focal']]) )

# check and repair validity of `toward` entries: ------------------------------
social_long = social_long %>%
  mutate(ok_toward = toward %in% dt_comm[['name']])
with(social_long, table(ok_toward))

social_long %>% filter(ok_who == FALSE)

## trim white space and correct capitalization
social_long = social_long %>%
  mutate( 
    who = str_trim(toward),
    who = str_to_title(who),
    ok_who = who %in% dt_comm[['name']]
  )
with(social_long, table(ok_toward, ok_who))
social_long %>% filter(ok_who == FALSE)

## remove empty entries after trimming
n_empty = with(social_long, sum(who == ''))
social_long = social_long %>%
  filter(who != "")

with(social_long, table(ok_who))
social_long %>% filter(ok_who == FALSE)  

## record and remove entries with ?
n_question = with(social_long, sum(who == "?"))
social_question = social_long %>%
  filter(who == "?")
social_long = social_long %>%
  filter(who != "?")

with(social_long, table(ok_who))
social_long %>% filter(ok_who == FALSE)  

# look for similar names in the reference names: ------------------------------
dt_comm %>%
  filter(grepl('^A', name))
## Aham == Ahlam or Adam? (Only first is valid)

# use a string distance to look for possible matches: -------------------------
to_match = {social_long %>% filter(ok_who == FALSE)}[['who']] 
fuzzy_match_1d = to_match |>
  lapply(
    function(who) {
      agrep(
        pattern = who,
        x = dt_comm[['name']],
        max.distance = list(
          insertions = 0L,
          deletions = 1L,
          substitutions = 0L
        ),
        fixed = TRUE,
        ignore.case = TRUE,
        value = TRUE
      ) 
    }
  )
vapply(fuzzy_match_1d, length, FUN.VALUE = 0L) |>
  table() 

## alternate syntax  
fuzzy_match_1d = to_match |>
  lapply(
    FUN = agrep,
    x = dt_comm[['name']],
    max.distance = list(
      insertions = 0L,
      deletions = 1L,
      substitutions = 0L
    ),
    fixed = TRUE,
    ignore.case = TRUE,
    value = TRUE
  )
names(fuzzy_match_1d) = to_match

## replace 1 deletion matches in the original data using a "dictionary"
n_1d = vapply(fuzzy_match_1d, length, FUN.VALUE = 0L)

match_1d = unlist(fuzzy_match_1d[which(n_1d == 1)])
names(match_1d) = to_match[which(n_1d == 1)]

social_long = social_long %>%
  mutate(
    who = ifelse(
      ok_who == TRUE, 
      who, 
      ifelse(who %in% names(match_1d), match_1d[who], who)
    ),
    ok_who = who %in% dt_comm[['name']]
  )

with(social_long, table(ok_who))
social_long %>% filter(ok_who == FALSE)  

fuzzy_match_1d[['Kae']]

# use a string distance as in `adist()`: --------------------------------------
to_match = to_match[which(n_1d != 1)]
match_dist = 
  adist(
    str_to_lower(to_match), 
    str_to_lower(dt_comm[['name']]),
    costs = c(i = 1.5, d = 1, s = 3),
    partial = FALSE,
    ignore.case = TRUE
  )
dim(match_dist)
length(to_match)
nrow(dt_comm)

best = apply(match_dist, 1, \(x) which(x == min(x)) )
names(best) = to_match
vapply(best, length, FUN.VALUE = 1L) |> table() 
best_idx = which(vapply(best, length, FUN.VALUE = 1L) == 1)

best_match = dt_comm[['name']][unlist(best[best_idx])]
names(best_match) = names(best[best_idx])

social_long = social_long %>%
  mutate(
    who = ifelse(
      ok_who == TRUE, 
      who, 
      ifelse(who %in% names(best_match), best_match[who], who)
    ),
    ok_who = who %in% dt_comm[['name']]
  )
with(social_long, table(ok_who))
social_long %>% filter(ok_who == FALSE)  

# construct a data frame of possible matches for remaining: -------------------
unmatched = lapply(best[-best_idx], \(i) dt_comm[['name']][i]) |>
  lapply(paste, collapse = ', ')
unmatched = 
  tibble(
    who = names(unmatched),
    possible = unlist(unmatched)
  )
unmatched = unmatched %>%
  left_join(social_long, by = 'who') 

unmatched = unmatched %>%
  select(focal, behavior_cat, id, who, possible)

# 79: -------------------------------------------------------------------------
