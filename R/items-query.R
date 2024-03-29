#' @title Endpoint functions
#'
#' @description
#' The `items` function implements WFS3
#' \code{/collections/\{collectionId\}/items}, and
#' \code{/collections/\{collectionId\}/items/\{featureId\}} endpoints.
#'
#' Each endpoint retrieves specific STAC objects:
#' \itemize{
#'   \item \code{/collections/\{collectionId\}/items}: Returns a STAC Items
#'     collection (GeoJSON)
#'   \item \code{/collections/\{collectionId\}/items/\{itemId\}}: Returns a
#'     STAC Item (GeoJSON Feature)
#' }
#'
#' The endpoint \code{/collections/\{collectionId\}/items} accepts the same
#' filters parameters of [stac_search()] function.
#'
#' @param q           a `rstac_query` object expressing a STAC query
#' criteria.
#'
#' @param feature_id  a `character` with item id to be fetched.
#' Only works if the `collection_id` is informed. This is equivalent to
#' the endpoint \code{/collections/\{collectionId\}/items/\{featureId\}}.
#'
#' @param datetime    a `character` with a date-time or an interval.
#' Date and time strings needs to conform to RFC 3339. Intervals are
#' expressed by separating two date-time strings by `'/'` character.
#' Open intervals are expressed by using `'..'` in place of date-time.
#'
#' Examples:
#' \itemize{
#'   \item A date-time: `"2018-02-12T23:20:50Z"`
#'   \item A closed interval: `"2018-02-12T00:00:00Z/2018-03-18T12:31:12Z"`
#'   \item Open intervals: `"2018-02-12T00:00:00Z/.."` or
#'     `"../2018-03-18T12:31:12Z"`
#' }
#'
#' Only features that have a `datetime` property that intersects
#' the interval or date-time informed in `datetime` are selected.
#'
#' @param bbox        a `numeric` vector with only features that have a
#' geometry that intersects the bounding box are selected. The bounding box is
#' provided as four or six numbers, depending on whether the coordinate
#' reference system includes a vertical axis (elevation or depth):
#' \itemize{ \item Lower left corner, coordinate axis 1
#'           \item Lower left corner, coordinate axis 2
#'           \item Lower left corner, coordinate axis 3 (optional)
#'           \item Upper right corner, coordinate axis 1
#'           \item Upper right corner, coordinate axis 2
#'           \item Upper right corner, coordinate axis 3 (optional) }
#'
#' The coordinate reference system of the values is WGS84
#' longitude/latitude (<http://www.opengis.net/def/crs/OGC/1.3/CRS84>).
#' The values are, in most cases, the sequence of minimum longitude,
#' minimum latitude, maximum longitude, and maximum latitude. However,
#' in cases where the box spans the antimeridian, the first value
#' (west-most box edge) is larger than the third value
#' (east-most box edge).
#'
#' @param limit       an `integer` defining the maximum number of results
#' to return. If not informed, it defaults to the service implementation.
#'
#' @seealso
#' [get_request()],  [post_request()],
#'  [collections()]
#'
#' @return
#' A `rstac_query` object with the subclass `items` for
#'  \code{/collections/{collection_id}/items} endpoint, or a
#'  `item_id` subclass for
#'  \code{/collections/{collection_id}/items/{feature_id}} endpoint,
#'  containing all search field parameters to be provided to STAC API web
#'  service.
#'
#' @examples
#' \dontrun{
#'  stac("https://brazildatacube.dpi.inpe.br/stac/") %>%
#'    collections("CB4-16D-2") %>%
#'    items(bbox = c(-47.02148, -17.35063, -42.53906, -12.98314)) %>%
#'    get_request()
#'
#'  stac("https://brazildatacube.dpi.inpe.br/stac/") %>%
#'    collections("CB4-16D-2") %>%
#'    items("CB4-16D_V2_000002_20230509") %>%
#'    get_request()
#' }
#'
#' @export
items <- function(q, feature_id = NULL, datetime = NULL, bbox = NULL,
                  limit = NULL) {
  check_query(q, c("collection_id", "items"))
  params <- list()
  if (!is.null(datetime))
    params$datetime <- .parse_datetime(datetime)
  if (!is.null(bbox))
    params$bbox <- .parse_bbox(bbox)
  if (!is.null(limit) && !is.null(limit))
    params$limit <- .parse_limit(limit)
  # set subclass
  subclass <- "items"
  if (!is.null(feature_id)) {
    params$feature_id <- .parse_feature_id(feature_id)
    subclass <- "item_id"
  }
  rstac_query(
    version = q$version,
    base_url = q$base_url,
    params = utils::modifyList(q$params, params),
    subclass = subclass
  )
}

#' @export
parse_params.items <- function(q, params) {
  if (!is.null(params$datetime))
    params$datetime <- .parse_datetime(params$datetime)
  if (!is.null(params$bbox))
    params$bbox <- .parse_bbox(params$bbox)
  if (!is.null(params$limit))
    params$limit <- .parse_limit(params$limit)
  params
}

#' @export
before_request.items <- function(q) {
  check_query_verb(q, verbs = c("GET", "POST"))
  set_query_endpoint(q, endpoint = "./collections/%s/items",
                     params = "collection_id")
}

#' @export
after_response.items <- function(q, res) {
  content <- content_response_json(res)
  doc_items(content, query = q)
}

#' @export
before_request.item_id <- function(q) {
  check_query_verb(q, verbs = c("GET", "POST"))
  set_query_endpoint(q, endpoint = "./collections/%s/items/%s",
                      params = c("collection_id", "feature_id"))
}

#' @export
after_response.item_id <- function(q, res) {
  content <- content_response_json(res)
  doc_item(content)
}
