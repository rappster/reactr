% Generated by roxygen2 (4.0.2): do not edit by hand
\name{rmFromRegistry}
\alias{rmFromRegistry}
\title{Remove From Registry (generic)}
\usage{
rmFromRegistry(id, where = parent.frame(), ...)
}
\arguments{
\item{id}{\strong{Signature argument}.
Object containing name/ID information.}

\item{where}{\strong{Signature argument}.
Object containing location information.}

\item{...}{Further arguments to be passed to subsequent functions/methods.}
}
\description{
Removes entry of associated reactive object that has been unset via
\code{\link[reactr]{unsetReactive}} from the registry.
}
\examples{
\dontrun{

## NOTE //
## This function should typically only be called inside 'unsetReactive()'
## as it manages the internal registry!

## Start with a clean registry //
resetRegistry()

where <- new.env()
setReactive(id = "x_1", value = 10, where = where)
setReactive(id = "x_2", 
  value = function() .ref_1 <- get("x_1"),
  where = where
)

## Insepct registry before removal //
showRegistry()

rmFromRegistry(id = "x_1", where = where)
showRegistry()
rmFromRegistry(id = "x_2", where = where)
showRegistry()

## Sanity of actual cached values is not affected by this unless other values
## for `strict_get` are chosen
where$x_1
where$x_2

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
  	\link[reactr]{rmFromRegistry-character-environment-method}
}
}

