\dontrun{
  
################################################################################
## Basics
################################################################################

##------------------------------------------------------------------------------  
## In parent environment (parent.frame()) //
##------------------------------------------------------------------------------

## NOTE:
## Be careful what you do as this alters objects in .GlobalEnv due to 
## the default value of `where` being equal to  `parent.frame()`!

## Set reactive object that can be referenced by others //
setReactive(id = "x_1", value = 10)

## Set reactive object that has a reactive binding to 'x_1' //
## NOTE:
## All the comments in `function()` below are just to tell you exactly what's
## going on. They are **not** required (see below/next section for much more 
## concise forms for specifying the binding functions)

setReactive(id = "x_2", 
  value = function() {
    ########################################
    ## Unambiguously specifying references #
    ########################################
    
    ## Via YAML markup:
    "object-ref: {id: x_1, as: ref_1}"
    
    ## NOTE
    ## See vignette `Specifying reactive references` for details and alternative
    ## ways to specify references
    ## 
    ## All these are valid ways to specify the references after the part
    ## `object-ref:` (omitting the closing bracket)
    ##
    ##    {id: {id}}
    ##    --> default `where` is used, i.e. `parent.frame()` is used
    ##    Example: object-ref: {id: x_1}
    ##
    ##    {id: {id}, where: {where}}
    ##    --> explicit `where`. Can be the name of any environment object
    ##    that is accessible, i.e. that exists under this name when calling
    ##    `setReactive()`
    ##    Example: {id: x_1, where: where_1}
    ##
    ##    {id: {id}, where: {where}, as: {ref-id}}
    ##    --> additional specification of the name/id to use inside *this* 
    ##    function if it should differ from {id}.
    ##    Example: {id: x_1, where: where_1, as: my_ref}
    ##    --> you would then use objec `my_ref` in the remainder of this 
    ##    function
    
    #############################
    ## Using referenced objects #
    #############################
    
    ## As we used the markup 
    ##
    ##                         {id: x_1, as: ref_1}
    ##
    ## `setReactive()` expects us to use `ref_1` in the following 
    
    ref_1 * 2
  }
)

## Inspect //
x_1
x_2

## Modification of `x_1` and implications on `x_2` //
(x_1 <- 50)
x_2
## --> update according to binding function
x_2
## --> cached value, no update
## For subsequent requests of `x_2` and as long as `x_1` has not changed
## again it is safe to return the value that has been cached after the last
## update cycle was completed --> possible efficiency increase for more 
## situations where binding functions are more complex or the amount of data 
## stored in referenced objects is significantly big. 

## Trying to explicit change the value of an object that has one-directionally
## references another object (i.e. no bi-directionality)
x_2 <- 500
x_2
## --> in case `strict_set = 0` (default) this is gracefully disregarded. 
## Otherwise a warning or an error is issued:

setReactive(id = "x_2", value = function() "object-ref: {id: x_1}",
              strict_set = 1)
try(x_2 <- 500)

setReactive(id = "x_2", value = function() "object-ref: {id: x_1}",
              strict_set = 2)
try(x_2 <- 500)

## Clean up //
rmReactive("x_1")
rmReactive("x_2")

##------------------------------------------------------------------------------  
## Typed //
##------------------------------------------------------------------------------

setReactive(id = "x_1", value = 10, typed = TRUE)
setReactive(id = "x_2", value = function() "object-ref: {id: x_1}")

x_1 <- 20
x_2
try(x_1 <- "hello world")

## Overwriting initial `NULL` values is fine //
setReactive(id = "x_1", typed = TRUE)
x_1
(x_1 <- "hello world")

## Clean up //
rmReactive("x_1")
rmReactive("x_2")

##------------------------------------------------------------------------------  
## Verbose //
##------------------------------------------------------------------------------

## To better understand what's actually going on below the surface and how 
## the caching mechanism works, you can set `verbose = TRUE`

setReactive(id = "x_1", value = 10)
setReactive(id = "x_2", value = function() "object-ref: {id: x_1}", 
              verbose = TRUE)

x_1 <- 20
x_2
## --> Object UID: 
##     The only required information to compute an object's UID are its name/ID
##     and the environment that it has been assigned to. Thus 
##     `computeObjectUid("x_2", where = .GlobalEnv)` yields:
##     ab22808532ff42c87198461640612405
## --> UID of calling object:
##     Object `x_2` "calls itself". While this may seem obvious, there are 
##     situations where objects are called by **other** objects (especially in
##     case of bi-directionally referenced objects)
## --> Information about modified references:
##     We are informed that the value of the reference with the UID 
##     2fc2e352f72008b90a112f096cd2d029 (corresponds to 
##     `computeObjectUid("x_1", where = .GlobalEnv)`) has changed
##     --> `x_2` needs to be updated by executing its binding function.
## --> Checksum comparision:
##     In addition to the information which reference has change, we are 
##     presented the actual checksums of the referenced object's visible value:
##     1) The one that `x_2` stored after completing the last update 
##        (or initialization) cycle
##     2) The current checksum of `x_1` after the visible value has been changed
##        from `10` to `20`
##     Checksums are simply computed by running `digest::digest({value}) with 
##     {value} being the visible value of a reactive object.
## --> Information that update will be performed ("Updating ...")

x_2
## --> cached value, no update since `x_1` has not changed again
x_1 <- 30
x_2
## --> update according to binding function

## Clean up //
rmReactive("x_1")
rmReactive("x_2")

##------------------------------------------------------------------------------  
## In custom environment //
##------------------------------------------------------------------------------

## NOTE:
## It is recommended **not** to use the name/ID `where` when explicitly 
## stating environments as this might lead to inconsitencies with the argument 
## `where` of `setReactive()`. 
## Also, even though it might often not be required due to the lexical scoping
## mechanism of R, it is probably a good idea to pass along all objects 
## denoting explicitly to use environments as additional arguments of 
## `setReactive()` as that way they can unambigously be referenced inside
## the function and all of its helper functions.

where_1 <- new.env()

## Set variable that others can have reactive bindings to //
setReactive(id = "x_1", value = 10, where = where_1)

## Set variable that has reactive binding to `x_1`
setReactive(id = "x_2", 
  value = function() {
    "object-ref: {id: x_1, where: where_1, as: ref_1}"
    ref_1 * 2
  }, 
  where = where_1, where_1 = where_1
)

## Get current variable value //
where_1$x_1
where_1$x_2
## --> value cached at initialization is used; no update as `x_1` in `where_1`
## has not changed yet
(where_1$x_1 <- 100)
## --> `x_1` in `where_1` is updated
where_1$x_2
## --> referenced value for `x_1` in `where_1` changed --> update and re-cache
where_1$x_2
## --> cached value is used until reference changes again
where_1$x_2
where_1$x_2
(where_1$x_1 <- 50)
where_1$x_2
## --> referenced value for `x_1` in `where_1` changed --> update and re-cache

## Clean up //
rmReactive("x_1", where_1)
rmReactive("x_2", where_1)
suppressWarnings(rm(where_1))

################################################################################
## Reactive scenarios
################################################################################

##------------------------------------------------------------------------------
## Scenario 1: one-directional (1)
##------------------------------------------------------------------------------

## Explanation //
## - Type/Direction: 
##   `A` references `B` 
## - Binding/Relationship: 
##   `A` uses value of `B` "as is", i.e. value of `A` identical to value of `B`

setReactive(id = "x_1", value = 10)
setReactive(id = "x_2", value = function() {
  "object-ref: {id: x_1}"
  x_1
})

x_1
x_2
(x_1 <- 50)
x_2
## --> as `x_1` has changed `x_2` changes according to its binding function

## NOTE
## After an initial call to `setReactive()`, it does not matter if you set 
## (or get) values via `setReactive()` (or `getReactive()`) or 
## via `<-`/`assign()` (or `$`/`get()`):
setReactive(id = "x_1", value = 100)
x_1
x_2  
## --> value after executing binding function
getReactive("x_2") 
## --> cached value
x_2 
## --> cached value

##------------------------------------------------------------------------------
## Scenario 1: one-directional (2)
##------------------------------------------------------------------------------

## Explanation //
## - Type/Direction: 
##   `A` references `B`   
## - Binding/Relationship:
##   `A` transforms value of `B` , i.e. value of `A` is the result of 
##   applying a function on the value of `B`

setReactive(
  id = "x_3", 
  value = function() {
    ## object-ref: {id: x_1}
    x_1 * 2
  }
)

x_1
x_3
(x_1 <- 10)
x_3 

## Clean up //
rmReactive("x_1")
rmReactive("x_2")
rmReactive("x_3")

##------------------------------------------------------------------------------
## Scenario 1: one-directional (3)
##------------------------------------------------------------------------------

## Explanation //
## - Type/Direction: 
##   `A` references `B` and `C`, `B` references `C`
## - Binding/Relationship: 
##   `A` transforms value of `B` , i.e. value of `A` is the result of 
##   applying a function on the value of `B`

setReactive(id = "x_1", value = 10)
setReactive(
  id = "x_2", 
  value = function() {
    ## object-ref: {id: x_1}
    x_1 * 2
  }
)
setReactive(
  id = "x_3", 
  value = function() {
    ## object-ref: {id: x_1}
    ## object-ref: {id: x_2}
    x_1 + x_2 * 2
  }
)

x_1
x_2
x_3
(x_1 <- 50)
x_3 
## --> change of `x_1` affects both `x_2` and `x_3` --> update
x_3
x_2

(x_2 <- 500)
x_1
## --> not affected as no binding to either `x_2` or `x_3`
x_3
## --> affected by change of `x_2` --> update

## Clean up //
rmReactive("x_1")
rmReactive("x_2")
rmReactive("x_3")

##------------------------------------------------------------------------------
## Scenario 4: bi-directional (1)
##------------------------------------------------------------------------------

## Explanation //
## - Type/Direction: 
##   `A` references `B` and `B` references `A` --> bidirectional binding type
## - Binding/Relationship: 
##   `A` uses value of `B` "as is" and `B` uses value of `A` "as is". 
##   This results in a steady state. 

setReactive(id = "x_1", value = function() {
  ## object-ref: {id: x_2}
  x_2
})
setReactive(id = "x_2", value = function() {
  ## object-ref: {id: x_1}
  x_1
  }
)

## Note that mutually bound objects are initialized to `NULL`
x_1
x_2

## Thus you need to set a specific value to *either one* of them
## (they both accept "set values")
## Setting `x_1`:
x_1 <- 10
x_1
x_2
x_1
## --> update cycle complete; from now own cached values can be used
x_2
x_1

## Setting `x_2`:
x_2 <- 100
x_2
x_1
x_2
## --> update cycle complete; from now own cached values can be used
x_1
x_2

## Clean up //
rmReactive("x_1")
rmReactive("x_2")

##------------------------------------------------------------------------------
## Scenario 5: bi-directional (2)
##------------------------------------------------------------------------------

## Explanation //
## - Type/Direction: 
##   `A` references `B` and `B` references `A` --> bidirectional binding type
## - Binding/Relationship: 
##   `A` uses transformed value of `B` and `B` uses transformed value of `A`. 
##   The binding functions used result in a steady state.

setReactive(id = "x_1", value = function() {
  ## object-ref: {id: x_2}
  x_2 * 2
  }
)
setReactive(id = "x_2", value = function() {
  ## object-ref: {id: x_1}
  x_1 / 2
  }
)

## NOTE
## Still a minor inconsistency with respect to initial values 
## (`numeric()` instead of `NULL`) depending on the structure of the binding
## function
x_1
x_2
## Addressed in issue #11

## Setting `x_1`:
x_1 <- 10
x_1
x_2
x_1
x_2
x_1

## Setting `x_2`:
x_2 <- 100
x_2
x_1
x_2
x_1
x_2

## Clean up //
rmReactive("x_1")
rmReactive("x_2")

##------------------------------------------------------------------------------
## Scenario 6: bi-directional (3)
##------------------------------------------------------------------------------

## Explanation //
## - Type/Direction: 
##   `A` references `B` and `B` references `A` --> bidirectional binding type
## - Binding/Relationship: 
##   `A` uses transformed value of `B` and `B` uses transformed value of `A`. 
##   The binding functions used result in a **non-steady state**.

## It's better to use `verbose = TRUE` to comprehend what's going on

setReactive(id = "x_1", value = function() {
  ## object-ref: {id: x_2}
  x_2 * 2
}, verbose = TRUE)
setReactive(id = "x_2", value = function() {
  ## object-ref: {id: x_1}
  x_1 * 4
}, verbose = TRUE)

## Setting value of `x_1`:
x_1 <- 10
x_1
## --> 10 * 4 * 2 = 80 (calling graph: x_1:x_2:x_1[=10]*4:x_2[=40]*2[=80])
x_2
## --> 80 * 4 = 320 (calling graph: x_2:x_1[=80]*4[=320])
x_1
## --> 320 * 2 = 640 (calling graph: x_1:x_2[=320]*2[=620])
x_2
## --> 640 * 4 = 2560 (calling graph: x_2:x_1[=620]*4[=2560])
x_1
## --> 2560 * 2 = 5120 (calling graph: x_1:x_2[=2560]*2[=5120])
## --> as each object value request results in the respective binding functions
## to be executed, we never reach a steady state

## Note that due to caching and checksum comparision we never enter an 
## "infinite recursion" situation

## Setting value of `x_2`:
x_2 <- 1
x_2
x_1
x_2
x_1
x_2
x_1

## Clean up //
rmReactive("x_1")
rmReactive("x_2")

################################################################################
## Additional features / misc //
################################################################################

##------------------------------------------------------------------------------
## Pushing
##------------------------------------------------------------------------------

## The caching mechanism in combination with the registry mechanism used in
## this package allows "push updates", i.e. the **active** propagation of 
## state changes throught the systems, i.e. to all objects that are 
## referencing an object that stores a certain system state.

setReactive(id = "x_1", value = 10)
setReactive(
  id = "x_2", 
  value = function() {
    ## object-ref: {id: x_1}
    tmp <- x_1 * 2
    message(paste0("[", Sys.time(), "] I'm `x_2`and my reference `x_1` has changed: ", x_1))
    tmp
  },
  push = TRUE
)

x_1
x_2
## --> so far, this is no different from what we specified before

## The difference lies in the way changes of `x_1` are propagated:
## Up until now, objects that reference other objects would only be notified 
## of changes in their references in a "pull manner": 
## they would not be updated until they are explicitly requested and thus their
## binding functions are executed, which in turn would "pull" the change of 
## referenced objects into the object.
## Now, when using `pull = TRUE`, whenever an object that is referenced in
## other objects (i.e. `x_1`) changes, it actually calls **all** of its registered
## push references (i.e. `x_2`) and thus "pushing" its change throughout the 
## entire system. 

x_1 <- 100
## --> note that we **did not** request `x_2` explicitly, yet its binding
## function was executed by `x_1` as we've registered `x_2` to be an object
## that changes can/should be actively pushed to.
x_1 <- 200
x_1 <- 300

x_2
## --> the cached value corresponding to the last push cycle

## Clean up //
rmReactive("x_1")
rmReactive("x_2")

##------------------------------------------------------------------------------
## Using reactive bindings in more complex data structure //
##------------------------------------------------------------------------------

## This resembles what is already possible and actually better implemented 
## via the use of Reference Classes or R6 Classes 
## (see argument `active` in `R6::R6Class()`).
## However, it might be useful in situations where you don't want or cannot 
## use either Reference Classes or R6 Classes.
# 
## Note, however, that the use of the informal S3 class `ReactiveObjectS3` is
## subject to change in future releases as it was introduced primarily for 
## rapid prototyping.

x_1 <- new.env()  
x_2 <- new.env()  

setReactive(id = "field_1", value = 1:5, where = x_1, typed = TRUE)
setReactive(id = "field_2", value = function() { 
  "object-ref: {id: field_1, where: x_1}"
  field_1 * 2
}, where = x_1, typed = TRUE)

setReactive(id = "field_1", value = function() { 
  "object-ref: {id: field_1, where: x_1}"
  "object-ref: {id: field_2, where: x_1}"
  data.frame(field_1, field_2)
}, where = x_2, typed = TRUE)

setReactive(id = "x_3", value = function() { 
  "object-ref: {id: field_1, where: x_1, as: x_1_f_1}"
  "object-ref: {id: field_2, where: x_1, as: x_1_f_2}"
  "object-ref: {id: field_1, where: x_2, as: x_2_f_1}"
  list(
    x_1_f_1 = summary(x_1_f_1), 
    x_1_f_2 = summary(x_1_f_2), 
    x_2_f_1 = x_2_f_1[,1] * x_2_f_1[,2],
    files = paste0("file_", x_2_f_1[,1])
  )
}, x_1 = x_1, x_2 = x_2)

## Inspect //
x_1$field_1
x_1$field_2
x_2$field_1
x_3

## Change values //
(x_1$field_1 <- 1:10)
x_1$field_2
x_2$field_1
x_3

(x_1$field_1 <- 1)
x_1$field_2
x_2$field_1
x_3


## Clean up //
rmReactive("x_1")
rmReactive("x_2")
rmReactive("x_3")

##------------------------------------------------------------------------------  
## Disabled caching //
##------------------------------------------------------------------------------

## Caching can be disabled by `cache = FALSE` and should theoretically result
## in slightly faster runtimes for get and set operations as less code needs
## to be executed (maintaining the registry, comparing checksums etc.).
## However, current profiling paradoxically does not reinforce this hypothesis 
## for all operations yet (see profiling section).
## Addressed in issue #23 (https://github.com/Rappster/reactr/issues/23).

## NOTE:
## Features "bi-directional bindings" and "push updates" are not available 
## when the caching mechanism is disabled.

setReactive(id = "x_1", value = 10, cache = FALSE)
setReactive(id = "x_2", value = function() "object-ref: {id: x_1}", 
              cache = FALSE)

showRegistry()
## --> empty as there is no need to maintain a registry if caching is disabled

x_1 <- 20
x_2
x_1 <- 30
x_2

## Bi-directional bindings are not possible //
rmReactive("x_1")
rmReactive("x_2")
setReactive(id = "x_1", value = function() "object-ref: {id: x_2}", 
              cache = FALSE)
## NOTE:
## Trying to specify a bi-directional binding already fails before actually
## reaching an "infinite recursion" situation. This is due to the internal 
## mechanics of the implemented reactivity framework.

## Whe could illustrate what happens if the step actually had passed:
x_2 <- NULL
setReactive(id = "x_1", value = function() "object-ref: {id: x_2}", 
              cache = FALSE)
setReactive(id = "x_2", value = function() "object-ref: {id: x_1}", 
              cache = FALSE)
## --> the actual error message is a bit off still as I couldn't figure out
## how to "exit early" from a `withRestarts(tryCatch(...))` construct. 
## But for the moment, it should be informative enough.
## Addressed in issue #24 (https://github.com/Rappster/reactr/issues/24).

## Push updates are not possible //
rmReactive("x_1")
rmReactive("x_2")
setReactive(id = "x_1", value = 10, cache = FALSE)
setReactive(
  id = "x_2", 
  value = function() {
    "object-ref: {id: x_1}"
    message(paste0(Sys.time(), ": ", x_1))
    x_1
  }, 
  cache = FALSE, 
  push = TRUE
)

x_1 
x_2
(x_1 <- 20)
## --> no push update for `x_2`
x_2
## --> `x_2` needs to pull its updates --> push disabled as caching is disabled

## Clean up //
rmReactive("x_1")
rmReactive("x_2")

##------------------------------------------------------------------------------  
## Class used //
##------------------------------------------------------------------------------

## Instances of class `ReactiveObject.S3` provide the invisible object structure
## that powers the reactivity mechanism. 
## The visible part only consist in the value of field `.value`, 

setReactive(id = "x_1", value = 10)
(inst <- getFromRegistry("x_1"))
class(inst)
inst$.value
rmReactive("x_1")

################################################################################
## Profiling //
################################################################################

##------------------------------------------------------------------------------
## Microbenchmark (1) //
##------------------------------------------------------------------------------

require("microbenchmark")

## Session info //

# > sessionInfo()
# R version 3.1.1 (2014-07-10)
# Platform: x86_64-w64-mingw32/x64 (64-bit)
# 
# locale:
# [1] LC_COLLATE=German_Germany.1252  LC_CTYPE=German_Germany.1252   
# [3] LC_MONETARY=German_Germany.1252 LC_NUMERIC=C                   
# [5] LC_TIME=German_Germany.1252    
# 
# attached base packages:
# [1] stats     graphics  grDevices utils     datasets  methods   base     
# 
# other attached packages:
# [1] microbenchmark_1.4-2 reactr_0.1.8         testthat_0.9        
# 
# loaded via a namespace (and not attached):
#  [1] colorspace_1.2-4    conditionr_0.1.3    devtools_1.6.0.9000 digest_0.6.4       
#  [5] ggplot2_1.0.0       grid_3.1.1          gtable_0.1.2        htmltools_0.2.6    
#  [9] httpuv_1.3.0        MASS_7.3-33         mime_0.2            munsell_0.4.2      
# [13] plyr_1.8.1          proto_0.3-10        R6_2.0              Rcpp_0.11.3        
# [17] reshape2_1.4        RJSONIO_1.3-0       scales_0.2.4        shiny_0.10.2.1     
# [21] stringr_0.6.2       tools_3.1.1         xtable_1.7-4        yaml_2.1.13        
# [25] yamlr_0.4.10    

## Making sure that all objects are removed from `.GlobalEnv`
rm(list = ls(environment(), all.names = TRUE))

resetRegistry()
object.size(getRegistry())
## --> cost of having an empty registry is 56 bytes

## NOTE:
## Due to some strange behavior with respect to environments, you might need
## to run this function a couple of times until no error is issued anymore!

res <- microbenchmark(
  "set/x_1/setReactive" = setReactive(id = "x_1", value = 10, where = environment()),
  "set/x_2/regular" = assign("x_2", value = 10, envir = environment()),
  "get x_1" = get("x_1", envir = environment()),
  "get x_2" = get("x_2", envir = environment()),
  "set/x_3/setReactive" = setReactive(
    id = "x_3", 
    value = function() {
      ## object-ref: {id: x_1}
      x_1 * 2
    },
    where = environment()
  ),
  "get x_3" = get("x_3", envir = environment()),
  "change x_1" = assign("x_1", 100),
  "change x_2" = assign("x_2", 100),
  "get x_3 (2)" = get("x_3", envir = environment())
)

res
# Unit: microseconds
#                   expr      min       lq       mean    median        uq      max neval
#  set/x_1/setReactive 1188.646 1319.829 1453.20424 1403.6330 1499.2815 3024.621   100
#        set/x_2/regular    1.185    2.370    3.86766    3.5540    4.1460   31.390   100
#                get x_1   77.585   91.799  107.61211   97.1290  111.0470  286.650   100
#                get x_2    1.185    2.369    3.94463    3.5530    3.5540   64.555   100
#  set/x_3/setReactive 5477.721 6251.792 6687.43914 6435.0930 6818.8710 8986.210   100
#                get x_3  236.308  269.178  414.77674  295.2375  408.6530 1044.730   100
#             change x_1  201.958  226.536  257.65281  242.2310  270.3625  468.470   100
#             change x_2    1.184    2.961    3.71369    3.5540    4.1460   18.952   100
#            get x_3 (2)  236.900  270.659  427.25543  294.0525  404.2110 2306.815   100

## Costs //
## 1) Setting: simple `setReactive()` compared to regular assignment:
1403.6330/3.5540
## --> about 395 times slower, but nominal time is still quite small:
1403.6330/10^9 ## in seconds
##
## 2) Setting: one-directional `setReactive()` compared to regular assignment:
6435.0930/3.5540
## --> about 1800 times slower, but nominal time is still quite small:
6435.0930/10^9 ## in seconds
##
## 3) Update: reactive object compared to regular object:
242.2310/3.5540
## --> about 70 times slower, but nominal time is still quite small:
242.2310/10^9 ## in seconds
##
## 4) Getting: simple reactive object compared to regular object:
97.1290/3.5530
## --> about 27 times slower, but nominal time is still quite small:
97.1290/10^9 ## in seconds
##
## 5) Getting: referencing reactive object compared to regular object:
295.2375/3.5530
## --> about 83 times slower, but nominal time is still quite small:
295.2375/10^9 ## in seconds

##------------------------------------------------------------------------------
## Memory //
##------------------------------------------------------------------------------

## Reactive objects //
rm(list = ls(environment(), all.names = TRUE))
resetRegistry()

(memsize_1 <- memory.size(max = FALSE))
## --> total memory used before setting reactive objects

setReactive(id = "x_1", value = 10)
setReactive(
  id = "x_2", 
  value = function() {
    ## object-ref: {id: x_1}
    x_1 * 2
  }
)

(memsize_2 <- memory.size(max = FALSE))
## --> total memory used after setting reactive objects

## Difference:
memsize_2 / memsize_1
## --> about 0,1 % increase 

## Object sizes //
object.size(getRegistry())
## --> still 56 bytes (?)
object.size(getFromRegistry("x_1"))
## --> 352 bytes
object.size(getFromRegistry("x_2"))
## --> 352 bytes

object.size(x_1)
## --> 48 bytes
object.size(x_2)
## --> 48 bytes

##----------

## Regular objects //
rm(list = ls(environment(), all.names = TRUE))
resetRegistry()

(memsize_1 <- memory.size(max = FALSE))
## --> total memory used before setting reactive objects

## Assign:
x_1 <- 10
x_2 <- x_1 * 2

(memsize_2 <- memory.size(max = FALSE))
## --> total memory used after setting reactive objects

## Difference:
memsize_2 / memsize_1
## --> about 0,01 % increase

object.size(x_1)
## --> 48 bytes
object.size(x_2)
## --> 48 bytes

##------------------------------------------------------------------------------
## Microbenchmark (2) //
##------------------------------------------------------------------------------

require("microbenchmark")

rm(list = ls(environment(), all.names = TRUE))
resetRegistry()

## NOTE:
## Due to some strange behavior with respect to environments, you might need
## to run this function a couple of times until no error is issued anymore!

res <- microbenchmark(
  "set/x_1/setReactive" = setReactive(id = "x_1", value = 10, cache = FALSE),
  "set/x_2/regular" = assign("x_2", value = 10, envir = environment()),
  "get x_1" = get("x_1", envir = environment()),
  "get x_2" = get("x_2", envir = environment()),
  "set/x_3/setReactive" = setReactive(
    id = "x_3", 
    value = function() {
      ## object-ref: {id: x_1}
      x_1 * 2
    },
    cache = FALSE
  ),
  "get x_3" = get("x_3", envir = environment()),
  "change x_1" = assign("x_1", 100),
  "change x_2" = assign("x_2", 100),
  "get x_3 (2)" = get("x_3", envir = environment())
)

res

# Unit: microseconds
#                   expr      min        lq       mean    median        uq      max neval
#  set/x_1/setReactive 1204.637 1266.2310 1396.94640 1327.2320 1408.0750 3191.635   100
#        set/x_2/regular    1.777    2.9610    3.68405    3.5540    4.1460    7.699   100
#                get x_1   33.167   36.7190   43.04497   39.6810   45.6040   76.993   100
#                get x_2    1.185    2.3690    3.42347    3.5535    4.1460   18.360   100
#  set/x_3/setReactive 4852.305 5195.5135 5411.78583 5334.3965 5446.6280 7057.252   100
#                get x_3  368.972  391.4775  428.66495  416.0560  448.3335  804.868   100
#             change x_1  207.880  220.6130  278.05576  235.4200  253.7795 2272.464   100
#             change x_2    1.777    2.9620    3.67219    3.5540    4.1460   10.069   100
#            get x_3 (2)  364.826  390.2930  443.53041  416.9445  451.5910 1982.854   100

## Costs //
## 1) Setting: simple `setReactive()` compared to regular assignment:
1327.2320/3.5540
## --> about 375 times slower, but nominal time is still quite small:
1327.2320/10^9 ## in seconds
## 1.a) Compared to enabled caching:
1403.6330/1327.2320
## --> about 5 % faster
##
## 2) Setting: one-directional `setReactive()` compared to regular assignment:
5334.3965/3.5540
## --> about 1500 times slower, but nominal time is still quite small:
5334.3965/10^9 ## in seconds
## 2.a) Compared to enabled caching:
6435.0930/5334.3965
## --> about 20 % faster
##
## 3) Update: reactive object compared to regular object:
235.4200/3.5540
## --> about 65 times slower, but nominal time is still quite small:
235.4200/10^9 ## in seconds
## 3.a) Compared to enabled caching:
242.2310/235.4200
## --> about 3 % faster
##
## 4) Getting: simple reactive object compared to regular object:
39.6810/3.5530
## --> about 10 times slower, but nominal time is still quite small:
39.6810/10^9 ## in seconds
## 4.a) Compared to enabled caching:
97.1290/39.6810
## --> about 2,5 times faster
##
## 5) Getting: referencing reactive object compared to regular object:
416.0560/3.5530
## --> about 115 times slower, but nominal time is still quite small:
416.0560/10^9 ## in seconds
## 5.a) Compared to enabled caching:
295.2375/416.0560
## --> about 30 % slower (!?)

##------------------------------------------------------------------------------
## References to environments //
##------------------------------------------------------------------------------

## Illustration that references to environments are not removed if the 
## referenced environment is removed:

env_1 <- new.env()
env_1$x <- 10
env_2 <- new.env()
env_2$env_1 <- env_1

## See if they are really the same //
env_2$env_1
env_1
identical(env_2$env_1, env_1)

env_2$env_1$x
env_1$x <- 100
env_2$env_1$x

## Removing `env_1`
rm(env_1)
env_2$env_1
## --> still there

## Reassigning `env_1`
env_1 <- new.env()
identical(env_2$env_1, env_1)
## --> not identical anymore

## This is the reason why method `ensureIntegrity()` of class `ReactiveObject.S3`
## exists and why in certain situations the re-sync of registry references 
## must/should be ensured

##------------------------------------------------------------------------------
## On a sidenote: caching mechanism
##------------------------------------------------------------------------------

## The caching mechanism implemented by this function relies on keeping
## a registry that stores certain information that are either required
## or useful in deciding whether an update should be triggered or not.
##
## The rule of thumb is as follows:
##    If B depends on A and A has not changed:
##    --> use the last cache value if B is requested
##    If B depends on A and A has changed
##    --> execute the reactive binding function and thus also update 
##        the cached value
##
## The decision is based on a comparison of checksum values as computed by 
## `digest::digest()`. These are stored in option environment
##                       `getOption(".reactr")$.registry`
## which is accessible via the convenience function 
##                          `getRegistry()`
## Besides the actual checksum values, each entry - corresponding to a reactive 
## object - also contains some additional information:
## - id:    object ID as specified in call to `setReactive()`
## - uid:   object UID computed as follows:
##          `digest::digest(list(id = id, where = {where}))`
##          where `{where}` stands for the location provided via argument 
##          `where` in the call to `setReactive()`
## - {uid}: subenvironment corresponding to the object`s UID. This contains
##          the object`s own checksum 
## - {ref-uid} subenvironments for each referenced object should there exist
##             any. These in turn contain the referenced object`s checksum that is
##             used to determine if an update is necessary or not.

## Registry object/environment //
resetRegistry()
registry <- getRegistry()
ls(registry)
showRegistry()
## --> currently empty 

## Illustrating the role of the registry //
setReactive(id = "x_1", value = 10)
showRegistry()
## --> Object with UID 2fc2e352f72008b90a112f096cd2d029 has been registered

## Retrieve from registry //
(reg_x_1 <- getFromRegistry("x_1"))
## --> same as manually selecting the respective object from the registry
## environment:
registry[[computeObjectUid("x_1")]]

ls(reg_x_1, all.names = TRUE)
reg_x_1$.id
reg_x_1$.uid
reg_x_1$.where
reg_x_1$.checksum

setReactive(
  id = "x_2", 
  value = function() {
    ## object-ref: {id: x_1}
    x_1 * 2
  }
)
showRegistry()

reg_x_2 <- getFromRegistry("x_2")
ls(reg_x_2, all.names = TRUE)
reg_x_2$.id
reg_x_2$.uid
reg_x_2$.where
reg_x_2$.checksum
ls(reg_x_2$.refs_pull)
## --> pull references --> reference to `x_1` or UID 2fc2e352f72008b90a112f096cd2d029
reg_x_1_through_x_2 <- reg_x_2$.refs_pull[["2fc2e352f72008b90a112f096cd2d029"]]
## --> same as invisible object behind `x_1` or object with 
## UID 2fc2e352f72008b90a112f096cd2d029 in registry:
identical(reg_x_1, reg_x_1_through_x_2)
## --> that way all references are always accessible which is quite handy
## for a lot of situations, including push updates and integrity checks.

## Clean up //
rmReactive("x_1")
rmReactive("x_2")
resetRegistry()

}
