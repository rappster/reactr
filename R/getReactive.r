#' @title
#' Get Value
#'
#' @description 
#' Retrieves value from an environment or any of its sub-environments based
#' on a path-like ID.
#' 
#' @details
#' Values for \code{id} are expected to be of structure \code{a/b/c/.../z},
#' i.e. being a path-like identifier with a slash used as separator. 
#' The identifier is transformed to \code{a$b$c$...$z} and then in turn to a
#' valid \emph{get} expression (\code{where$a$b$c$...$z}).
#'   	
#' @param id \strong{Signature argument}.
#'    Object containing path-like ID information.
#' @param where \strong{Signature argument}.
#'    Object containing environment information.
#' @param .hash_id \code{\link{character}}.
#'    Name of the auxiliary environment for caching hash values. 
#'    Default: \code{"._HASH"}. Keep it unless this name is already taken in 
#'    either \code{where} or \code{where_watch}.
#' @template threedot
#' @example inst/examples/getThis.r
#' @seealso \code{
#'   	\link[reactr]{getThis-character-environment-method}
#' }
#' @template author
#' @template references
#' @export 
setGeneric(
  name = "getThis",
  signature = c(
    "id",
    "where"
  ),
  def = function(
    id,
    where = .GlobalEnv,
    .hash_id = "._HASH",
    ...
  ) {
    standardGeneric("getThis")       
  }
)

#' @title
#' Get Value from Environment
#'
#' @description 
#' See generic: \code{\link[reactr]{getThis}}
#'      
#' @inheritParams getThis
#' @param id \code{\link{missing}}.
#' @return See method
#'    \code{\link[reactr]{getThis-character-environment-method}}
#' @example inst/examples/getThis.r
#' @seealso \code{
#'    \link[reactr]{getThis}
#' }
#' @template author
#' @template references
#' @export
setMethod(
  f = "getThis", 
  signature = signature(
    id = "character",
    where = "missing"
  ), 
  definition = function(
    id,
    where,
    .hash_id,
    ...
  ) {

  return(getThis(id = id, where = where, .hash_id = .hash_id, ...))
    
  }
)

#' @title
#' Get Value from Environment
#'
#' @description 
#' See generic: \code{\link[reactr]{getThis}}
#'   	 
#' @inheritParams getThis
#' @param id \code{\link{character}}.
#' @return \code{\link{ANY}}. Variable value
#' @example inst/examples/getThis.r
#' @seealso \code{
#'    \link[reactr]{getThis}
#' }
#' @template author
#' @template references
#' @export
setMethod(
  f = "getThis", 
  signature = signature(
    id = "character",
    where = "environment"
  ), 
  definition = function(
    id,
    where,
    .hash_id,
    ...
  ) {

  watch <- where$.watch[[id]]
  if (!is.null(watch)) {
    idx <- sapply(watch, function(ii) {
      hash_0 <- get(ii, envir = where[[.hash_id]][[ii]], inherits = FALSE)
      hash_1 <- get(id, envir = where[[.hash_id]][[ii]], inherits = FALSE)
      hash_0 != hash_1
    })
   
    if (any(idx)) {
      ## Update //
      out <- setReactive(
        id = id, 
        where = where, 
#         binding = substitute(BINDING), 
#           list(BINDING = get(id, where$.bindings, inherits = FALSE)),
        watch = watch,
        where_watch = where,
        binding = get(id, envir = where$.bindings, inherits = FALSE),
        binding_type = 2
      )
    } else {
      out <- get(id, envir = where, inherits = FALSE)
    }
  } else {
    out <- get(id, envir = where, inherits = FALSE)
  }
      
  return(out)
    
  }
)