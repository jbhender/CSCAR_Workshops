# R Short Course, Part 4
# Factors
#
# Author: James Henderson, PhD, CSCAR
# Updated: August 6, 2021
# 79: -------------------------------------------------------------------------

# libraries: ------------------------------------------------------------------
library(tidyverse)

# creating factors: -----------------------------------------------------------
mtcars[['transmission']] = 
  with(mtcars, 
       factor(am, levels = c(0, 1), labels = c('automatic', 'manual'))
  )

# factor methods and accessor functions: --------------------------------------
class(mtcars[['transmission']])
levels(mtcars[['transmission']])
# note the change
as.numeric(mtcars[['transmission']])
as.character(mtcars[['transmission']])
names(attributes(mtcars[['transmission']]))
attr(mtcars[['transmission']], 'levels')

# working with factors: -------------------------------------------------------

## table labels
with(mtcars, table(transmission, am))

## ggplot requires factors for discrete aesthetics
mtcars %>% 
  ggplot(aes(x = wt, y = mpg, color = transmission, shape = factor(am))) +
  geom_point() +
  theme_bw() + 
  scale_color_manual(values = c('darkred', 'darkblue')) +
  xlab('weight (1,000 lbs)')

## factors let us specify an order other than alphabetical
mtcars %>% 
  ggplot(aes(x = mpg, y = transmission)) +
  geom_boxplot() + 
  theme_bw() 

## chaning factor order

### using relevel()
mtcars %>% 
  mutate(transmission = relevel(transmission, ref = 'manual')) %>%
  ggplot(aes(x = mpg, y = transmission)) +
  geom_boxplot() + 
  theme_bw() 

### create a new factor
new_ord = c('manual', 'automatic')
stopifnot( all(levels(mtcars[['transmission']]) %in% new_ord))

mtcars %>% 
  mutate(transmission = factor(transmission, new_ord, new_ord)) %>%
  ggplot(aes(x = mpg, y = transmission)) +
  geom_boxplot() + 
  theme_bw() 

### helpful to order cases / groups in a plot
mtcars %>%
  arrange(mpg) %>%
  mutate(car = factor(rownames(.), rownames(.))) %>%
  ggplot(aes(x = car, y = mpg, fill = transmission)) + 
  geom_col() + 
  coord_flip() + 
  scale_fill_manual(values = c('darkred', 'darkblue')) +
  theme_bw() 

### factors in regression models
mtcars[['cyl_f']] = with(mtcars, factor(cyl))
x1 = model.matrix(mpg ~ cyl, data = mtcars)
x2 = model.matrix(mpg ~ cyl_f, data = mtcars)

cbind(head(x1), matrix(NA, nrow = 6), head(x2))

lm(mpg ~ cyl, data = mtcars) |> summary()
lm(mpg ~ cyl_f, data = mtcars) |> summary()

# 79: -------------------------------------------------------------------------
