\dontrun{

##------------------------------------------------------------------------------
## Important remarks //
##------------------------------------------------------------------------------
## This is a function that is currently only used inside a call to 'setValue()'
## or 'setValue_bare()'.
## Thus, in order to see what's going on here, we first need to mimick the 
## expected system state.
  
## Mimick expected system state //  
where <- new.env()

## Ensuring that 'test' exists:
setValue(id = "test", value = Sys.time(), where = where)

## Getting boilerplate code for binding contract:
binding <- getBoilerplateCode(
  ns = classr::createInstance(cl = "Reactr.BindingContractMonitoring.S3")
)

## We'd like to set a variable that monitors the variable 'test':
watch <- "test"

## We don't have to explicitly worry about variable that is monitoring 'test'
## except with respect to defining the binding relationship which I 
## call "binding contract".
## It defines the value of the variable monitoring 'test' based on the 
## value of 'test' via a function.
## This is the value of 'binding' when you call 'setValue()'.
.binding <- function(x) {
  ## Add 24 hours //
  x + 60*60*24
}

## Evaluate binding contract //
## Note that it takes the value of 'where$test' and processes it 
## according to the binding relationship defined in '.binding()'
eval(binding)()

## Change monitored variable value //
where$test <- Sys.time()
where$test

## Re-evaluate binding contract //
eval(binding)()  

## All available boilerplate code of this package //
getBoilerplateCode(
  ns = classr::createInstance(cl = "Reactr.BindingContractMonitored.S3")
)
getBoilerplateCode(
  ns = classr::createInstance(cl = "Reactr.BindingContractMonitoring.S3")
)
getBoilerplateCode(
  ns = classr::createInstance(cl = "Reactr.BindingContractMutual.S3")
)

}
