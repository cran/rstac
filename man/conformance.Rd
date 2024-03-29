% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/conformance-query.R
\name{conformance}
\alias{conformance}
\title{doc_conformance endpoint}
\usage{
conformance(q)
}
\arguments{
\item{q}{a \code{rstac_query} object expressing a STAC query criteria.}
}
\value{
A \code{rstac_query} object with the subclass \code{conformance} for \verb{/conformance}
endpoint.
}
\description{
The conformance endpoint provides the capabilities of
the service.
This endpoint is accessible from the provider's catalog (\verb{/conformance}).
}
\examples{
\dontrun{
stac("https://planetarycomputer.microsoft.com/api/stac/v1") \%>\%
  conformance() \%>\% get_request()
}

}
\seealso{
\code{\link[=get_request]{get_request()}},  \code{\link[=stac]{stac()}}, \code{\link[=collections]{collections()}}
}
