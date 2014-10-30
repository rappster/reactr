#' @title
#' Create Reactive Source Object
#'
#' @description 
#' Creates a reactive source object that can be used by 
#' observable reactive objects created via \code{\link[reactr]{setShinyReactive}}
#' or \code{\link[shiny]{reactive}}.
#' 
#' @details 
#' This is a slightly modified version of \link[shiny]{makeReactiveBinding}.
#'  
#' @param id \code{\link{character}}.
#'    Name/ID of the reactive source object.
#' @param value \code{\link{ANY}}.
#'    Value of reactive source object.
#' @param where \code{\link{environment}}.
#'    Environment in which to create the object.
#' @param overwrite \code{\link{logical}}.
#'    Only relevant if object already exists.
#'    \code{TRUE}: overwrite existing value;
#'    \code{FALSE}: keep currrent value. 
#' @param typed \code{\link{logical}}.
#'    \code{TRUE}: checks class validity of assignment value specified via
#'    \code{value} and throws an error if classes do not match or if the class 
#'    of the assignment value does not inherit from the class of field value 
#'    \code{.value} at initialization;
#'    \code{FALSE}: no class check is performed.
#'    Note that initial values of \code{NULL} are disregarded for the class 
#'    check, i.e. any value overwriting an initial \code{NULL} value 
#'    is valid.
#' @template threedots
#' @example inst/examples/setReactiveSource.r
#' @seealso \code{
#'    \link[reactr]{setShinyReactive},
#'    \link[shiny]{reactive}
#' }
#' @template author
#' @template references
#' @import conditionr
#' @import shiny
#' @export 
setReactiveSource <- function(
  id, 
  value = NULL,
  where = parent.frame(),
  overwrite = TRUE,
  typed = FALSE
) {
#   ## Ensure that shiny let's us do our thing //
#   shiny_opt <- getOption("shiny.suppressMissingContextError")
#   if (is.null(shiny_opt) || !shiny_opt) {
#     options(shiny.suppressMissingContextError = TRUE)  
#   }
  
  if (exists(id, where = where, inherits = FALSE) && !is.null(value)) {
    if (!overwrite) {
      value <- get(id, pos = where, inherits = FALSE)
    } 
    rm(list = id, pos = where, inherits = FALSE)
  }
  values <- shiny:::reactiveValues(value = value)

  ## Add some stuff to the instance of `reactiveValues` the dirty way //
  ## 1) `.class` field and value:
  values$.class <- class(value)
  ## 2) `.class` field and value:
  values$.checkClass <- function(self = values, v) {
    if (self$.class != "NULL" && !inherits(v, self$.class)) {
    ## --> seems like enforcing class consistency for `NULL` situations
    ## does not make sense as `NULL` will probably only be used for initial
    ## values. Possible think about what should happen when `NULL` is the 
    ## **assignment** value instead of the initial value --> issue #22
## TODO: issue #22
      
      num_clss <- c("integer", "numeric")
      if (all(c(class(v), self$.class) %in% num_clss)) {
        
      } else {
        conditionr::signalCondition(
          call = substitute(
            assign(x= ID, value = VALUE, envir = WHERE, inherits = FALSE),
            list(ID = id, VALUE = v, WHERE = where)
          ),
          condition = "AbortedWithClassCheckError",
          msg = c(
            Reason = "class of assignment value does not inherit from initial class",
            ID = id,
            UID = computeObjectUid(id, where),
            Location = capture.output(where),
            "Class expected" = values$.class,
            "Class provided" = class(v)
          ),
          ns = "reactr",
          type = "error"
        )
      }
    }
  }
  
  makeActiveBinding(id, env = where, 
#     local({
      fun = function(v) {
        if (missing(v)) {
          values$value
        } else {
          if (typed) {
            values$.checkClass(v = v)
          }    
          values$value <- v
        }
      }
#     })
  )

  invisible(values$value)
#   invisible()

}