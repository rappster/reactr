\dontrun{
  
################################################################################
## Binding type 1 //
################################################################################
 
## This is based on 'makeActiveBinding()' and respective boilerplate code 

where <- new.env()

## Set variable that can be monitored by others //
setReactive(id = "x_1", value = 10, where = where)

## Get current variable value //
where$x_1

###################
## In .GlobalEnv ##
###################

## BE CAREFUL WHAT YOU DO!

## Ensure clean state //
suppressWarnings(rm(x_1))
suppressWarnings(rm(.hash))

setReactive(id = "x_1", value = 10)
x_1

##------------------------------------------------------------------------------
## Binding scenario: identical
##------------------------------------------------------------------------------

## Ensure 'x_1' is set //
setReactive(id = "x_1", value = 10, where = where)

## Set variable that monitors 'x_1' //
## Binding contract: identical
setReactive(id = "x_2", where = where, watch = "x_1", binding = function(x) {x})

## When 'x_1' changes, 'x_2' changes accordingly:
## NOTE:
## When retrieving the value of 'x_2', you always retrieve a *cached* value 
## unless for the first retrieval after the observed variable 'x_1' has changed.
## That way, the function that binds 'x_1' to 'x_2' (the binding contract) 
## does not need to be executed each time, but only when it's actually required
where$x_1
where$x_2  ## cached value
where$x_1 <- 100
where$x_1  
where$x_2  ## value after executing binding function
where$x_2  ## cached value
where$x_2  ## cached value
where$x_1 <- 10
where$x_2  ## value after executing binding function
where$x_2  ## cached value
where$x_2  ## cached value

## NOTE:
## It does not matter if you set (or get) values via 'setReactive()' 
## (or 'getReactive()') or via '<-'/'assign()' (or '$'/'get()')
setReactive(id = "x_1", value = 100, where = where)

where$x_1
where$x_2  ## value after executing binding function
where$x_2  ## cached value
getReactive("x_2", where = where) ## cached value

###################
## In .GlobalEnv ##
###################

## BE CAREFUL WHAT YOU DO!

## Ensure clean state //
suppressWarnings(rm(x_2))
suppressWarnings(rm(.hash))

setReactive(id = "x_2", watch = "x_1", binding = function(x) {x})

x_1
x_2  ## cached value
x_1 <- 100
x_1  
x_2  ## value after executing binding function
x_2  ## cached value
x_2  ## cached value
x_1 <- 10
x_2  ## value after executing binding function
x_2  ## cached value
x_2  ## cached value

setReactive(id = "x_1", value = 100)

x_1
x_2  ## value after executing binding function
x_2  ## cached value
getReactive("x_2") ## cached value

##------------------------------------------------------------------------------
## Binding scenario: arbitrary functional relationship
##------------------------------------------------------------------------------

## Set variable that monitors 'x_1' //
setReactive(id = "x_3", where = where, watch = "x_1", binding = function(x) {x + 100})

where$x_1
where$x_3
where$x_1 <- 10
where$x_3 

###################
## In .GlobalEnv ##
###################

## BE CAREFUL WHAT YOU DO!

setReactive(id = "x_3", watch = "x_1", binding = function(x) {x + 100})

x_1
x_3
x_1 <- 10
x_3 

##------------------------------------------------------------------------------
## Binding scenario: mutual
##------------------------------------------------------------------------------

## Set variables that are mutually bound //
where <- new.env()  

## Set '.tracelevel = 1' if you'd like to be able to understand what's actually
## going on
.tracelevel <- 0
    
setReactive(id = "x_1", where = where, watch = "x_2", 
  mutual = TRUE, .tracelevel = .tracelevel)
setReactive(id = "x_2", where = where, watch = "x_1", 
  mutual = TRUE, .tracelevel = .tracelevel
)

## Initial default values //
where$x_1
where$x_2

## Change any one of the mutually bound variables //
where$x_1 <- 300
where$x_1
where$x_2
where$x_2 <- 500
where$x_2
where$x_1

###################
## In .GlobalEnv ##
###################

## BE CAREFUL WHAT YOU DO!

## Ensure clean state //
suppressWarnings(rm(x_1))
suppressWarnings(rm(x_2))
suppressWarnings(rm(x_3))
suppressWarnings(rm(.hash))

## Set '.tracelevel = 1' if you'd like to be able to understand what's actually
## going on
.tracelevel <- 0
    
setReactive(id = "x_1", watch = "x_2", mutual = TRUE, .tracelevel = .tracelevel)
setReactive(id = "x_2", watch = "x_1", mutual = TRUE, .tracelevel = .tracelevel)

x_1
x_2
x_1 <- 300
x_1
x_2
x_2 <- 500
x_2
x_1

##------------------------------------------------------------------------------
## Binding scenario: multi-way
##------------------------------------------------------------------------------

## Set '.tracelevel = 1' if you'd like to be able to understand what's actually
## going on
.tracelevel <- 0

where <- new.env()      

## Set variables that are mutually bound //
setReactive(id = "x_1", where = where, watch = "x_2", 
  mutual = TRUE, .tracelevel = .tracelevel)
setReactive(id = "x_2", where = where, watch = "x_1", 
  mutual = TRUE, .tracelevel = .tracelevel
)
setReactive(id = "x_3", where = where, watch = "x_2", 
  binding = function(x) {x + 100}, .tracelevel = .tracelevel
)

where$x_1 <- 100
where$x_1
where$x_2
where$x_3

where$x_2 <- 200
where$x_1
where$x_2
where$x_3

## Disregarded:
where$x_3 <- 500
where$x_1
where$x_2
where$x_3

###################
## In .GlobalEnv ##
###################

## BE CAREFUL WHAT YOU DO!

## Ensure clean state //
suppressWarnings(rm(x_1))
suppressWarnings(rm(x_2))
suppressWarnings(rm(x_3))
suppressWarnings(rm(.hash))

## Set '.tracelevel = 1' if you'd like to be able to understand what's actually
## going on
.tracelevel <- 0

setReactive(id = "x_1", watch = "x_2", mutual = TRUE, .tracelevel = .tracelevel)
setReactive(id = "x_2", watch = "x_1", mutual = TRUE, .tracelevel = .tracelevel)
setReactive(id = "x_3", watch = "x_2", binding = function(x) {x + 100}, 
  .tracelevel = .tracelevel)

x_1 <- 100
x_1
x_2
x_3

x_2 <- 200
x_1
x_2
x_3

## Disregarded:
x_3 <- 500
x_1
x_2
x_3

##------------------------------------------------------------------------------
## Binding scenario: multi-way with non-standard binding
##------------------------------------------------------------------------------

## Set '.tracelevel = 1' if you'd like to be able to understand what's actually
## going on
.tracelevel <- 0

where <- new.env()  

## Set variables that are mutually bound //
setReactive(id = "x_1", where = where, watch = "x_2", 
  mutual = TRUE, binding = function(x) {x/2}, .tracelevel = .tracelevel)
setReactive(id = "x_2", where = where, watch = "x_1", 
  mutual = TRUE, binding = function(x) {x * 2}, .tracelevel = .tracelevel
)

where$x_1 <- 100
where$x_1
where$x_2

where$x_2 <- 500
where$x_1
where$x_2

###################
## In .GlobalEnv ##
###################

## BE CAREFUL WHAT YOU DO!

## Ensure clean state //
suppressWarnings(rm(x_1))
suppressWarnings(rm(x_2))
suppressWarnings(rm(x_3))
suppressWarnings(rm(.hash))

## Set '.tracelevel = 1' if you'd like to be able to understand what's actually
## going on
.tracelevel <- 0

## Set variables that are mutually bound //
setReactive(id = "x_1", watch = "x_2", mutual = TRUE, 
  binding = function(x) {x/2}, .tracelevel = .tracelevel)
setReactive(id = "x_2", watch = "x_1", mutual = TRUE, 
  binding = function(x) {x * 2}, .tracelevel = .tracelevel
)

x_1 <- 100
x_1
x_2

x_2 <- 500
x_1
x_2

##------------------------------------------------------------------------------
## Binding scenario: complex data structure (kind of like Reference Classes)
##------------------------------------------------------------------------------

x_1 <- new.env()  
x_2 <- new.env()  

## Set regular "complex" variable 'x_1' //
setReactive(id = "field_1", value = TRUE, where = x_1)
setReactive(id = "field_2", value = data.frame(x_1 = 1:5, x_2 = letters[1:5]), 
  where = x_1)

## Set variable with bindings //
setReactive(id = "field_1", where = x_2, watch = "field_1", where_watch = x_1, 
         binding = function(x) {!x})
setReactive(id = "field_2", where = x_2, watch = "field_2", where_watch = x_1, 
         binding = function(x) {x[,-1,drop = FALSE]})

x_1$field_1
x_1$field_2
x_2$field_1
x_2$field_2

##------------------------------------------------------------------------------
## On a sidenote: ID for hash environment
##------------------------------------------------------------------------------

## The decision whether to update a variable that is bound to another one
## depends on a comparison of hash values as computed by 'digest::digest()'
## The default auxiliary environment, where these are stored is: 'where$._HASH'
## If that name is already taken in your 'where' or 'where_watch', then you 
## need to specify an alternative hash environment ID via '.hash_id'.

## Default hash ID //
setReactive(id = "x_1", value = 10, where = where)
where$._HASH$x_1
where$._HASH$x_1$x_1

## Specify alternative '.hash_id' //
where <- new.env()
new_hash_id <- ".ALTERNATIVE_HASH"

setReactive(id = "x_1", value = 10, where = where, .hash_id = new_hash_id)
where$._HASH$x_1   ## environment does not exist anymore
where[[new_hash_id]]$x_1 
where[[new_hash_id]]$x_1$x_1


################################################################################
## Binding type 2 //
################################################################################

## This is the LEGACY (!) way of defining reactive bindings and is subject
## to being deprecated in furture package versions.

where <- new.env()  
  
setReactive(id = "x_1", value = Sys.time(), where = where, binding_type = 2)
getReactive(id = "x_1", where = where)

binding <- substitute(function(x) {
  x + 60*60*24
})
setReactive(id = "x_2", where = where, binding = binding, watch = "x_1", 
         binding_type = 2)
getReactive(id = "x_2", where = where)  
  
## Change value of monitored variable //
setReactive(id = "x_1", value = Sys.time(), where = where, binding_type = 2)
getReactive(id = "x_1", where = where)  
getReactive(id = "x_2", where = where) 

###################
## In .GlobalEnv ##
###################

## BE CAREFUL WHAT YOU DO!

## Ensure clean state //
suppressWarnings(rm(x_1))
suppressWarnings(rm(x_2))
suppressWarnings(rm(.hash))
  
setReactive(id = "x_1", value = Sys.time(), binding_type = 2)
getReactive(id = "x_1")

binding <- substitute(function(x) {
  x + 60*60*24
})
setReactive(id = "x_2", binding = binding, watch = "x_1", binding_type = 2)
getReactive(id = "x_2")  
  
## Change value of monitored variable //
setReactive(id = "x_1", value = Sys.time(), binding_type = 2)
getReactive(id = "x_1")  
getReactive(id = "x_2") 

##------------------------------------------------------------------------------
## Profiling //
##------------------------------------------------------------------------------

require("microbenchmark")
    
## Binding type 1 //
where <- new.env()

res_bt_1 <- microbenchmark(
  "1" = setReactive_bare(id = "x_1", value = 10, where = where),
  "2" = getReactive(id = "x_1", where = where),
  "3" = setReactive_bare(id = "x_2", where = where, watch = "x_1",
    binding = function(x) {x + 100}),
  "4" = getReactive(id = "x_2", where = where),
  "5" = setReactive_bare(id = "x_1", value = 100, where = where),
  "6" = getReactive(id = "x_2", where = where),
  control = list(order = "inorder")
)
res_bt_1

## Binding type 2 //
where <- new.env()  

res_bt_2 <- microbenchmark(
  "1" = setReactive_bare(id = "x_1", value = Sys.time(), where = where,
                 binding_type = 2),
  "2" = getReactive(id = "x_1", where = where),
  "3" = setReactive_bare(id = "x_2", where = where,
    binding = substitute(function(x) {
        x + 60*60*24
      }), watch = "x_1", binding_type = 2),
  "4" = getReactive(id = "x_2", where = where),
  "5" = setReactive_bare(id = "x_1", value = Sys.time(), where = where,
                 binding_type = 2),
  "6" = getReactive(id = "x_2", where = where),
  control = list(order = "inorder")
)
res_bt_2

}
