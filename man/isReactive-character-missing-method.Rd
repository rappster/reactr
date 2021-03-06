% Generated by roxygen2 (4.0.2): do not edit by hand
\docType{methods}
\name{isReactive,character,missing-method}
\alias{isReactive,character,missing-method}
\alias{isReactive-character-missing-method}
\title{Is Reactive (character-missing)}
\usage{
\S4method{isReactive}{character,missing}(id, where = parent.frame(), ...)
}
\arguments{
\item{id}{\code{\link{character}}.}

\item{where}{\code{\link{missing}}.}

\item{...}{Further arguments to be passed to subsequent functions/methods.}
}
\value{
See method
   \code{\link[reactr]{isReactive}}
}
\description{
See generic: \code{\link[reactr]{isReactive}}
}
\examples{
\dontrun{

## Reactive objects //
setReactive(id = "x_1", value = 10)
isReactive(id = "x_1")
unsetReactive("x_1")
isReactive(id = "x_1")

## Non-reactive/regular objects //
x_2 <- 10
isReactive(id = "x_2")
obj <- ReactiveObject.S3()
isReactive("obj")

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
   \link[reactr]{isReactive}
}
}

