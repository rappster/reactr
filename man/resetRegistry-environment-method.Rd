% Generated by roxygen2 (4.0.2): do not edit by hand
\docType{methods}
\name{resetRegistry,environment-method}
\alias{resetRegistry,environment-method}
\alias{resetRegistry-environment-method}
\title{Reset Registry (environment)}
\usage{
\S4method{resetRegistry}{environment}(where = getRegistry(), ...)
}
\arguments{
\item{where}{\code{\link{environment}}.}

\item{...}{Further arguments to be passed to subsequent functions/methods.}
}
\value{
\code{\link{logical}}. \code{TRUE}: successful; \code{FALSE}: fail.
}
\description{
See generic: \code{\link[reactr]{resetRegistry}}
}
\examples{
\dontrun{

## Set reactives so registry has entries //  
setReactive(id = "x_1", value = 10)
setReactive(id = "x_2", value = function() {
  .ref_1 <- get("x_1")
})

## Inspect current state of registry //
registry <- getRegistry()
showRegistry()
## --> two entries corresponding to invisible objects associated to `x_1` 
## and `x_2`

## Reset //
resetRegistry()
showRegistry()
## --> empty 

}
}
\author{
Janko Thyson \email{janko.thyson@rappster.de}
}
\references{
\url{http://github.com/Rappster/reactr}
}
\seealso{
\code{
   \link[reactr]{resetRegistry},
    \link[reactr]{rmFromRegistryByUid}
}
}

