# R Short Course, Part 4
# Regular Expressions (regex)
#
# Author: James Henderson, PhD, CSCAR
# Updated: August 6, 2021
# 79: -------------------------------------------------------------------------

# regex concepts: -------------------------------------------------------------
## find all two word fruits by searching for a space
fruit[grep(" ", fruit)]

## find all fruits with an 'a' anywhere in the word
fruit[grep("a", fruit)]

## find all fruits starting with 'a'
fruit[grep("^a", fruit)]

## find all fruits ending with 'a'
fruit[grep("a$", fruit)]

## find all fruits starting with a vowel
fruit[grep("^[aeiou]", fruit)]

## find all fruits with two consecutive vowels
fruit[grep("[aeiou]{2}", fruit)]

## find all fruits ending with two consecutive consonants other than r
fruit[grep("[^aeiour]{2}$", fruit)]

# more advanced patterns: -----------------------------------------------------
## find all fruits with two consecutive vowels twice, separated by a single
## consonant
fruit[grep("[aeiou]{2}.[aeiou]{2}", fruit)]

## find all fruits with two consecutive vowels twice, separated by one or
## more consonants
fruit[grep("[aeiou]{2}.+[aeiou]{2}", fruit)]

## find all fruits with exactly three consecutive consonants in the middle of
## two vowels
fruit[grep("[aeiou][^aeiou ]{3}[aeiou]", fruit)]
#str_view(fruit, "[aeiou][^aeiou ]{3}[aeiou]")

# escaping meta-characters using \\: ------------------------------------------

## escape once for regex, once for R = twice total
c(fruit, "umich.edu")[grep('\\.', c(fruit, "umich.edu"))]

# grouping and back-reference: ------------------------------------------------
## find all fruits with a repeated letter
fruit[grep("(.)\\1", fruit)]

## find all fruits with a repeated letter but exclude double r
fruit[grep("([^r])\\1", fruit)]

## find all fruits that end with a repeated letter
fruit[grep("(.)\\1$", fruit)]

# 79: -------------------------------------------------------------------------
