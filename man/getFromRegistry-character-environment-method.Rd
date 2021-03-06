% Generated by roxygen2 (4.0.2): do not edit by hand
\docType{methods}
\name{getFromRegistry,character,environment-method}
\alias{getFromRegistry,character,environment-method}
\alias{getFromRegistry-character-environment-method}
\title{Get From Registry (character-environment)}
\usage{
\S4method{getFromRegistry}{character,environment}(id, where = parent.frame(),
  ...)
}
\arguments{
\item{id}{\code{\link{character}}.}

\item{where}{\code{\link{environment}}.}

\item{...}{Further arguments to be passed to subsequent functions/methods.}
}
\value{
\code{\link{ReactiveObject.S3}}. Stored invisible instance of reactive
   object.
}
\description{
See generic: \code{\link[reactr]{getFromRegistry}}
}
\examples{
\dontrun{

## Example object //
resetRegistry()
setReactive(id = "x_1", value = 10)
x_1

## Get from registry //
showRegistry()
obj <- getFromRegistry(id = "x_1")
obj$.id
obj$.uid
obj$.where

## Clean up //
obj$.remove()
try(x_1)
## --> removes itself from 'where' and from registry
showRegistry()

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
   \link[reactr]{getFromRegistry}
}
}

