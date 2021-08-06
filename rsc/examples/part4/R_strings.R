# R Short Course, Part 4
# Strings
#
# Author: James Henderson, PhD, CSCAR
# Updated: August 6, 2021
# 79: -------------------------------------------------------------------------

# create a string (length one character vector) using quotes: -----------------
string1 = "This is a string."
string2 = 'This is a string.'
all.equal(string1, string2)
typeof(string1)

# if your string contains a quote, use the opposite or escape them: -----------
string_single = "These are sometimes called 'scare quotes'."
print(string_single)

# note the difference between print() and cat()
string_double = 'Quoth the Raven, "Nevermore."'
print(string_double)
cat(string_double,'\n')

string_double = "Quoth the Raven, \"Nevermore.\""
print(string_double)
cat(string_double,'\n')

# you can also use writeLines() to cat multiple lines: -----------------------
backslash = "This is a backslash '\\', this is not '\ '."
writeLines(backslash)

some_file = c('Line 1', 'Line 2')
writeLines(some_file)

## compare to cat
cat(some_file)

# concatenating strings: ------------------------------------------------------
## LETTERS and letters are built-in R vectors
length(LETTERS)

## paste(), note the difference between `sep` and `collapse`
paste(LETTERS, collapse = "")
paste(1:26, LETTERS, sep = ': ')
paste(1:26, LETTERS, sep = ': ', collapse = '\n ')

## stringr::str_c
library(stringr) # stringr is in the tidyverse
all.equal(str_c(LETTERS, collapse = ""), paste(LETTERS, collapse = ""))
all.equal(str_c(1:26, LETTERS, sep = ': '), paste(1:26, LETTERS, sep = ': '))
all.equal(
  str_c(1:26, LETTERS, sep = ': ', collapse = '\n '), 
  paste(1:26, LETTERS, sep = ': ', collapse = '\n ') 
)

## str_c and paste differ in treating NA
paste(1:3, c(1, NA, 3), sep = ':', collapse = ', ')
str_c(1:3, c(1, NA, 3), sep = ':', collapse = ', ')
str_c(1:3, str_replace_na(c(1, NA, 3)), sep = ":", collapse = ', ')

# string length: --------------------------------------------------------------
length(paste(LETTERS, collapse = "") )
nchar(paste(LETTERS, collapse = "") )
str_length(paste(LETTERS, collapse = "") )

# substrings using position indexing: -----------------------------------------
substr('Strings',  3, 7)
str_sub('Strings', 1, 6)

## str_sub suports negative indexing
sprintf('base: %s, stringr: %s', 
        substr('Strings', -5, -1), 
        str_sub('Strings', -5, -1)
)

# pattern matching: -----------------------------------------------------------

## stringr::fruit vector with names of fruits
head(fruit)

## grep() and grepl()
grep('fruit', fruit)
which(grepl('fruit', fruit) )
head(grepl('fruit', fruit) )
grepl('fruit', fruit)[grep('fruit', fruit)]

## vectorized over input, but not pattern
grep(c('fruit', 'berry'), fruit)
sapply(c('fruit', 'berry'), grep, x = fruit)

## match -- must be exact
match('berry', fruit)
match(c('apple', 'pear'), c(fruit, fruit))

## stringr::str_detect is vectorized over pattern and input and uses
##  broadcasting
ind_fruit = which(str_detect(fruit, 'fruit') )
ind_berry = which(str_detect(fruit, 'berry') )

ind_either = which(str_detect(fruit, c('fruit','berry') ) )
setdiff(union(ind_fruit, ind_berry), ind_either )

## below I demonstrate the broadcasting pattern
ind_odd = seq(1, length(fruit), 2)
ind_even = seq(2, length(fruit), 2)

odd_fruit = ind_odd[ str_detect(fruit[ind_odd], 'fruit') ]
even_berry = ind_even[ str_detect(fruit[ind_even], 'berry') ]
setdiff(union(odd_fruit, even_berry), ind_either )

## still need an sapply loop due to broadcasting
sapply(c('fruit', 'berry'), function(x) which(str_detect(fruit, x) ) )

## stringr::str_locate uses an OR logic for broadcasting
#! note format of output
ind_fruit = str_locate(fruit, 'fruit')
ind_berry = str_locate(fruit, 'berry')

ind_either = str_locate(fruit, c('fruit','berry'))
setdiff(union(ind_fruit, ind_berry), ind_either )

# find and replace: -----------------------------------------------------------
## see also base sub() and gsub() but I prefer the stringr versions
# abc ... 
letter_vec = paste(letters, collapse = '')

## replace all instances
str_replace_all(letter_vec, '[aeiou]', 'X')

#replace the first instance
str_replace(letter_vec, '[aeiou]', 'X')

# to replace by location
str_sub(letter_vec, start = 1:3, end = 2:4)
str_sub(letter_vec, start = -3, end = -1) = 'XXX'

# splitting strings: ----------------------------------------------------------

## strsplit()
fruit_list = strsplit(fruit,' ')
two_ind = which(sapply(fruit_list, length)==2)
fruit_two = lapply(fruit_list[two_ind], paste, collapse=' ')
unlist(fruit_two)

## stringr::str_split()
all.equal(fruit_list, str_split(fruit, ' '))

## compare 
string = '1;2,3'
strsplit(string, c(';', ','))
str_split(string, c(';', ','))

### use a regular expression to split on either character. 
str_split(string,';|,')

# 79: -------------------------------------------------------------------------
