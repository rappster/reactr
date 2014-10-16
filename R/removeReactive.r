#' @title
#' Remove Reactive Object (generic)
#'
#' @description 
#' Removes a reactive object from its environment. This implies that the 
#' registry (see \code{\link[reactr]{getRegistry}}) is also updated 
#' accordingly. 
#' 
#' @details
#' 
#' \strong{Note that tis is different from unsetting a reactive object 
#' via \code{\link[reactr]{removeReactive}}}. It is equivalent to 
#' \code{\link[base]{rm}} with a previous call to 
#' \code{\link[reactr]{unsetReactive}}. 
#' 
#' @section Implications with respect to observing variables:
#' 
#' If other reactive variables have been observing the reactive variable that
#' has been removed, from this point on they will simply return the last value
#' that has been cached if when setting the object via 
#' \code{\link[reactr]{setReactiveS3}} argument \code{strict} was \code{FALSE}.
#' In case it was \code{TRUE}, the function returns error condition 
#' \code{BrokenReactiveBinding}.
#' 
#' @note
#' The main S4 method is 
#' \code{\link[reactr]{removeReactive-character-environment-method}}.
#'     
#' @param id \strong{Signature argument}.
#'    Object containing path-like ID information.
#' @param where \strong{Signature argument}.
#'    Object containing location information.
#' @template threedots
#' @example inst/examples/removeReactive.r
#' @seealso \code{
#'   	\link[reactr]{removeReactive-character-environment-method}
#' }
#' @template author
#' @template references
#' @export 
setGeneric(
  name = "removeReactive",
  signature = c(
    "id",
    "where"
  ),
  def = function(
    id,
    where = parent.frame(),
    ...
  ) {
    standardGeneric("removeReactive")       
  }
)

#' @title
#' Remove Reactive Object (character-missing)
#'
#' @description 
#' See generic: \code{\link[reactr]{removeReactive}}
#'      
#' @inheritParams removeReactive
#' @param id \code{\link{character}}.
#' @param where \code{\link{missing}}.
#'    Internal argument that should not be set explicitly.
#'    The value at runtime will correspond to the function that has been 
#'    provided via argument \code{binding}.
#' @return See method
#'    \code{\link[reactr]{removeReactive-character-environment-method}}
#' @example inst/examples/removeReactive.r
#' @seealso \code{
#'    Generic: \link[reactr]{removeReactive}
#' }
#' @template author
#' @template references
#' @aliases removeReactive-method_main 
#' @export
#' @aliases removeReactive-character-missing-method
setMethod(
  f = "removeReactive", 
  signature = signature(
    id = "character",
    where = "missing"
  ), 
  definition = function(
    id,
    where,
    ...
  ) {
  
  return(removeReactive(
    id = id,
    where = where,
    ...
  ))
  
  }
)

#' @title
#' Remove Reactive Object (character-environment)
#'
#' @description 
#' See generic: \code{\link[reactr]{removeReactive}}
#'   	 
#' @inheritParams removeReactive
#' @param id \code{\link{character}}.
#' @param where \code{\link{environment}}.
#' @return \code{\link{logical}}. \code{TRUE}: success; \code{FALSE}: object
#'    was not a reactive one or failure to remove.
#' @example inst/examples/removeReactive.r
#' @seealso \code{
#'    Generic: \link[reactr]{removeReactive}
#' }
#' @template author
#' @template references
#' @aliases removeReactive-method_main 
#' @export
#' @aliases removeReactive-character-environment-method
setMethod(
  f = "removeReactive", 
  signature = signature(
    id = "character",
    where = "environment"
  ), 
  definition = function(
    id,
    where,
    ...
  ) {

  out <- FALSE
  if (!length(id)) {
    stop(paste0("Provide an ID"))
  }
  uid <- getObjectUid(id = id, where = where)    
  
  if (exists(id, envir = where, inherits = FALSE)) {
    has_binding <- try(bindingIsActive(id, where))
    if (inherits(has_binding, "try-error")) {
      has_binding <- FALSE
    } 
    if (has_binding) {
      unsetReactiveByUid(uid = uid)
      rm(list = id, envir = where, inherits = FALSE)
      out <- TRUE
    }
  }
    
  return(out)
  
  }
)
