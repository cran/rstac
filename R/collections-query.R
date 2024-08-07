#' @title Endpoint functions
#'
#' @rdname collections
#'
#' @description
#' The `collections` function implements the WFS3 `/collections`
#'  and \code{/collections/\{collectionId\}} endpoints.
#'
#' Each endpoint retrieves specific STAC objects:
#' \itemize{
#'   \item `/collections`: Returns a list of STAC Collections published in
#'     the STAC service
#'   \item \code{/collections/\{collectionId\}}: Returns a single STAC
#'     Collection object
#' }
#'
#' @param q       a `rstac_query` object expressing a STAC query
#' criteria.
#'
#' @param collection_id a `character` collection id to be retrieved.
#'
#' @param limit   an `integer` defining the maximum number of results
#' to return. If not informed, it defaults to the service implementation.
#'
#' @seealso
#' [get_request()], [post_request()], [items()]
#'
#' @return
#' A `rstac_query` object with the subclass `collections` for
#'  `/collections/` endpoint, or a `collection_id` subclass for
#'  \code{/collections/{collection_id}} endpoint, containing all search field
#'  parameters to be provided to STAC API web service.
#'
#' @examples
#' \dontrun{
#'  stac("https://brazildatacube.dpi.inpe.br/stac/") %>%
#'    collections() %>%
#'    get_request()
#'
#'  stac("https://brazildatacube.dpi.inpe.br/stac/") %>%
#'    collections(collection_id = "CB4-16D-2") %>%
#'    get_request()
#' }
#'
#' @export
collections <- function(q, collection_id = NULL, limit = NULL) {
  check_query(q, "stac")
  params <- list()
  subclass <- "collections"
  if (!is.null(collection_id)) {
    if (length(collection_id) != 1)
      .error("Parameter `collection_id` must be a single value.")
    params$collection_id <- collection_id
    subclass <- "collection_id"
  } else if (!is.null(limit)) {
    params$limit <- limit
  }
  rstac_query(
    version = q$version,
    base_url = q$base_url,
    params = utils::modifyList(q$params, params),
    subclass = subclass
  )
}

#' @export
before_request.collections <- function(q) {
  check_query_verb(q, verbs = c("GET", "POST"))
  set_query_endpoint(q, endpoint = "./collections")
}

#' @export
after_response.collections <- function(q, res) {
  content <- content_response_json(res)
  doc_collections(content)
}

#' @export
before_request.collection_id <- function(q) {
  check_query_verb(q, verbs = c("GET", "POST"))
  set_query_endpoint(q, endpoint = "./collections/%s", params = "collection_id")
}

#' @export
after_response.collection_id <- function(q, res) {
  content <- content_response_json(res)
  doc_collection(content)
}
