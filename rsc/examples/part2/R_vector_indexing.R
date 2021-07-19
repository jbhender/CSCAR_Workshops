# Vector Indexing 
# 
# Author: James Henderson
# Updated: July 18, 2021
# 79: -------------------------------------------------------------------------

# positional indexing: --------------------------------------------------------
x = 2 * (1:10)

# extract a single element
x[7]
x[1]

# extract multiple elements
x[c(1, 10)]

# extract a range of elements
x[5:10]
x[seq(5, 10, 1)]

# indexing by name: -----------------------------------------------------------
code = 1:27
names(code) = c(LETTERS, ' ') # built in vector of A-Z
code[c('O', 'P', 'E', 'N', ' ', 'S', 'O', 'U', 'R', 'C', 'E')]

# logical indexing: -----------------------------------------------------------
y = c('pi' = pi, 'e' = exp(1), 'phi' = (1 + sqrt(5)) / 2 )
y[c(TRUE, FALSE, TRUE)]
y[y > 2]

# list indexing: --------------------------------------------------------------
messages = list(
  hello = 'Hello World!',
  catchphrase = 'Cowabunga, dude.',
  goodbyes = c('Hasta la vista, baby.', 'So long.', 'Later gator.')
)

# selecting a sub-list by position
messages[1:2]
messages[1]
messages[c(1, 3)]

# selecting a sub-list by name 
messages['goodbyes']
messages[c('catchphrase', 'goodbyes')]

# selecting a single element by position
messages[[2]]

# selecting a single element by name
messages$hello
messages[['hello']]

# using `with()` to create an environment from a list: ------------------------
hello = 'Hi!'
hi = 'hi'
with(messages,
     cat(hello, '\n\n', catchphrase, '\n\n', goodbyes[3], '\n', sep = '')
)

cat(
  messages[['hello']], 
  '\n\n',
  messages[['catchphrase']], 
  '\n\n',
  messages[['goodbyes']][3], 
  '\n',
  sep = ''
)

# 79: -------------------------------------------------------------------------
