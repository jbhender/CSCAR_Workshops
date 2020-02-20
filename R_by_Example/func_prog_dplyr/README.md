
##

## Tips for writing functions using dplyr

1. Start simple and don't be afraid to do some of the work outside of the function.

1. Use `.data` and `!` or `!!`. 

1. Use scoped variants of dplyr verbs `_if`, `_at`, `_all`. 

1. Use "quosure" as a last resort, see `vignette('programming', package = 'dplyr')`. 
