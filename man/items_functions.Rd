% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/documents.R
\name{items_functions}
\alias{items_functions}
\alias{items_length}
\alias{items_matched}
\alias{items_fetch}
\alias{items_datetime}
\alias{items_bbox}
\alias{items_bands}
\title{STACItemCollection functions}
\usage{
items_length(items)

items_matched(items, matched_field = NULL)

items_fetch(items, ..., progress = TRUE, matched_field = NULL)

items_datetime(items)

items_bbox(items)

items_bands(items)
}
\arguments{
\item{items}{a \code{STACItemCollection} object.}

\item{matched_field}{a \code{character} vector with the path
where the number of items returned in the named list is located starting from
the initial node of the list. For example, if the information is at position
\code{items$meta$found} of the object, it must be passed as the following
parameter \code{c("meta", "found")}.}

\item{...}{config parameters to be passed to \link[httr]{GET} or
\link[httr]{POST} methods, such as \link[httr]{add_headers} or
\link[httr]{set_cookies}.}

\item{progress}{a \code{logical} indicating if a progress bar must be
shown or not. Defaults to \code{TRUE}.}
}
\value{
The \code{items_length()} returns an \code{integer} value.
The \code{items_matched()} returns an \code{integer} value.
If STAC web server does not support this extension, returns \code{NULL}.
The \code{items_fetch()} returns an \code{STACItemCollection} with all
matched items.
The \code{items_datetime()} returns a \code{list} of all items' datetime.
The \code{items_bbox()} returns a \code{list} with all items'
bounding boxes.
}
\description{
The \code{items_length()} function shows how many items there are in
the \code{STACItemCollection} object.
The \code{items_matched()} function shows how many items matched the
search criteria. It supports \code{search:metadata} (v0.8.0),
\code{context} (v0.9.0), and \code{numberMatched} (OGC WFS3 core spec).
The \code{items_fetch()} function request all STAC Items through
pagination.
The \code{items_datetime()} function retrieves a the \code{datetime}
field in \code{properties} from \code{STACItemCollection} and
\code{STACItem} objects.
The \code{items_bbox()} function retrieves a the \code{bbox}
field of a \code{STACItemCollection} or an \code{STACItem} object.
The \code{get_assets_name()} function returns the assets name from
\code{STACItemCollection} and \code{STACItem} objects.
}
\examples{
\dontrun{

x <- stac("http://brazildatacube.dpi.inpe.br/stac") \%>\%
  stac_search(collections = "CB4_64_16D_STK-1") \%>\%
  stac_search() \%>\%
  get_request()

x \%>\% items_length()
x \%>\% items_matched()
x \%>\% items_datetime()
x \%>\% items_bbox()
}

\dontrun{
x <-
  stac("http://brazildatacube.dpi.inpe.br/stac") \%>\%
  stac_search(collections = "CB4_64_16D_STK-1") \%>\%
  stac_search(limit = 500) \%>\%
  get_request()

x \%>\% items_fetch()
}

}
