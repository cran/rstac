% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ext_query.R
\name{ext_query}
\alias{ext_query}
\title{Query extension}
\usage{
ext_query(q, ...)
}
\arguments{
\item{q}{a \code{rstac_query} object expressing a STAC query
criteria.}

\item{...}{entries with format \verb{<field> <operator> <value>}.}
}
\value{
A \code{rstac_query} object  with the subclass \code{ext_query} containing
all request parameters to be passed to \code{post_request()} function.
}
\description{
The \code{ext_query()} is the \emph{exported function} of the STAC API
query extension. It can be used after a call to \code{stac_search()}
function. It allows that additional fields and operators other than those
defined in \code{stac_search()} function be used to make a complex filter.

The function accepts multiple filter criteria. Each filter entry is an
expression formed by \verb{<field> <operator> <value>}, where
\verb{<field>} refers to a valid item property. Supported \verb{<fields>}
depends on STAC API service implementation. The users must rely on the
service providers' documentation to know which properties can be used
by this extension.

The \code{ext_query()} function allows the following \verb{<operators>}
\itemize{
\item \code{==} corresponds to '\code{eq}'
\item \code{!=} corresponds to '\code{neq}'
\item \code{<} corresponds to '\code{lt}'
\item \code{<=} corresponds to '\code{lte}'
\item \code{>} corresponds to '\code{gt}'
\item \code{>=} corresponds to '\code{gte}'
\item \verb{\\\%startsWith\\\%} corresponds to '\code{startsWith}' and implements
a string prefix search operator.
\item \verb{\\\%endsWith\\\%} corresponds to '\code{endsWith}' and implements a
string suffix search operator.
\item \verb{\\\%contains\\\%}: corresponds to '\code{contains}' and implements a
string infix search operator.
\item \verb{\\\%in\\\%}: corresponds to '\verb{in}' and implements a vector
search operator.
}

Besides this function, the following S3 generic methods were implemented
to get things done for this extension:
\itemize{
\item The \code{before_request()} for subclass \code{ext_query}
\item The \code{after_response()} for subclass \code{ext_query}
}
See source file \code{ext_query.R} for an example of how to implement new
extensions.
}
\examples{
\dontrun{
 stac("https://brazildatacube.dpi.inpe.br/stac/") \%>\%
   stac_search(collections = "CB4-16D-2") \%>\%
   ext_query("bdc:tile" \%in\% "007004") \%>\%
   post_request()
}

}
\seealso{
\code{\link[=ext_filter]{ext_filter()}}, \code{\link[=stac_search]{stac_search()}}, \code{\link[=post_request]{post_request()}},
\code{\link[=before_request]{before_request()}}, \code{\link[=after_response]{after_response()}}, \code{\link[=content_response]{content_response()}}
}
