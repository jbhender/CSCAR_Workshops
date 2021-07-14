# Input and Output (I/O) in R
#
# Updated: September 6, 2020
# Author: James Henderson
# 79: -------------------------------------------------------------------------

# delimited data: -------------------------------------------------------------

## base R, the 'utils' package

### input
recs = read.table( 
  '../../data/recs2015_public_v4.csv', 
  sep = ',', 
  stringsAsFactors = FALSE, 
  header = TRUE
)

### inspect
dim(recs)
class(recs)
head( names(recs), 10 ) 

### output
write.table(
  lme4::InstEval, 
  file = '../../data/InstEval.txt', 
  sep = '\t', 
  row.names = FALSE
)

## (Tidyverse) readR

### input
recs_tib = readr::read_delim('../../data/recs2015_public_v4.csv', delim = ',')

### inspect
dim(recs_tib)
class(recs_tib)

## data.table

### input
recs_dt = data.table::fread('../../data/recs2015_public_v4.csv')

### inspect
dim(recs_dt)
class(recs_dt)

### input with command line pre-processing
recs_dt = 
  data.table::fread(cmd = 'gunzip -c ../../data/recs2015_public_v4.csv.gz')

# Native R binaries: ----------------------------------------------------------

## .RData

### (output) save objects in .RData files
df = lme4::InstEval
df_desc = 'The lme4::InstEval data.'
save(df, df_desc, file = '../../data/InstEval.RData')

### (input) restore 
rm( list = ls() )
ls()
load('../../data/InstEval.RData')
ls()

#### invisible return
foo = load('../../data/InstEval.RData') #df, df_desc
foo

#### useful construction
assign('InstEval', get(foo[1]) )

## Serialized R Data
#! For special cases when you don't want a name attached to the object data

### output
saveRDS(lme4::InstEval, file = '../../data/InstEval.rds')

### input
df = readRDS('../../data/InstEval.rds')

# Other formats: --------------------------------------------------------------
?haven::read_dta()
?readxl::read_xlsx()

