#' @title
#' Remove From Registry (generic)
#'
#' @description 
#' Removes entry of associated reactive object that has been unset via 
#' \code{\link[reactr]{unsetReactive}} from the registry.
#'   	
#' @param id \strong{Signature argument}.
#'    Object containing name/ID information.
#' @param where \strong{Signature argument}.
#'    Object containing location information.
#' @template threedots
#' @example inst/examples/removeFromRegistry.r
#' @seealso \code{
#'   	\link[reactr]{removeFromRegistry-character-environment-method}
#' }
#' @template author
#' @template references
setGeneric(
  name = "removeFromRegistry",
  signature = c(
    "id",
    "where"
  ),
  def = function(
    id,
    where = parent.frame(),
    ...
  ) {
    standardGeneric("removeFromRegistry")       
  }
)

#' @title
#' Remove From Registry (character-missing)
#'
#' @description 
#' See generic: \code{\link[reactr]{removeFromRegistry}}
#'      
#' @inheritParams removeFromRegistry
#' @param id \code{\link{character}}.
#' @param where \code{\link{missing}}.
#' @return See method
#'    \code{\link[reactr]{removeFromRegistry-character-environment-method}}.
#' @example inst/examples/removeFromRegistry.r
#' @seealso \code{
#'    \link[reactr]{removeFromRegistry},
#'    \link[reactr]{removeFromRegistry-character-environment-method}
#' }
#' @template author
#' @template references
#' @export
#' @aliases removeFromRegistry-character-missing-method
setMethod(
  f = "removeFromRegistry", 
  signature = signature(
    id = "character",
    where = "missing"
  ), 
  definition = function(
    id,
    where,
    ...
  ) {

  removeFromRegistry(
    id = id,
    where = where,
    ...
  )
    
  }
)

#' @title
#' Remove From Registry (character-environment)
#'
#' @description 
#' See generic: \code{\link[reactr]{removeFromRegistry}}
#'   	 
#' @inheritParams removeFromRegistry
#' @param id \code{\link{character}}.
#' @param where \code{\link{environment}}.
#' @return \code{\link{logical}}. \code{TRUE}: successfully removed; 
#'    \code{FALSE}: not removed because there was nothing to remove.
#' @example inst/examples/removeFromRegistry.r
#' @seealso \code{
#'    \link[reactr]{removeFromRegistry}
#' }
#' @template author
#' @template references
#' @export
#' @aliases removeFromRegistry-character-environment-method
setMethod(
  f = "removeFromRegistry", 
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
  if (length(id)) {
    uid <- getObjectUid(id = id, where = where)
    out <- removeFromRegistryByUid(uid = uid)
  }
  return(out)
    
  }
)
