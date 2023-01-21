## ----prepare, include = FALSE-------------------------------------------------
is_online <- tryCatch({
  res <- httr::GET("https://brazildatacube.dpi.inpe.br/stac/")
  !httr::http_error(res)
}, error = function(e) {
  FALSE
})

knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = is_online
)
library(tibble)

## ----setup, eval=TRUE, echo=FALSE---------------------------------------------
library(rstac)

## ----endpoints, eval=TRUE, echo=FALSE-----------------------------------------

data.frame(
  "**STAC** endpoints"   = c(
    "`/`", "`/stac`","`/collections`", "`/collections/{collectionId}`", 
    "`/collections/{collectionId}/items`", "`/collections/{collectionId}/items/{itemId}`", "`/search`", "`/stac/search`",
    "`/conformance`", "`/collections/{collectionId}/queryables`"
  ), "`rstac` functions" = c(
    "`stac()`", "`stac()`", "`collections()`", "`collections(collection_id)`",
    "`items()`", "`items(feature_id)`", "`stac_search()`", "`stac_search()`",
    "`conformance()`", "`queryables()`"
  ), "API version"      = c(
    ">= 0.9.0", "< 0.9.0", ">= 0.9.0", ">= 0.9.0", ">= 0.9.0", ">= 0.9.0",
    ">= 0.9.0", "< 0.9.0", ">= 0.9.0", ">= 1.0.0"
  ),
  check.names = FALSE
) %>% knitr::kable(format = "markdown")

## ----installing, eval=FALSE---------------------------------------------------
#  install.packages("rstac")

## ----queries-1, eval=TRUE-----------------------------------------------------
s_obj <- stac("https://brazildatacube.dpi.inpe.br/stac/")
s_obj

## ----base-url, eval=TRUE------------------------------------------------------
s_obj$base_url

## ----queries-2, eval=TRUE-----------------------------------------------------
s_obj |> 
  collections()

## ----queries-3, eval=TRUE-----------------------------------------------------
s_obj |> 
  collections("S2-16D-2")

## ----queries-4, eval=TRUE-----------------------------------------------------
s_obj |> 
  collections("S2-16D-2") |>
  items()

## ----queries-5, eval=TRUE-----------------------------------------------------
s_obj |> 
  collections("S2-16D-2") |> 
  items(feature_id = "S2-16D_V2_015011_20190117")

## ----queries-6, eval=TRUE-----------------------------------------------------
s_obj |> 
  stac_search(collections = c("CB4_64_16D_STK", "S2-16D-2")) |>
  ext_query("bdc:tile" == "022024")

## ----request-1----------------------------------------------------------------
s_obj |>
  collections(collection_id = "CB4_64_16D_STK-1") |>
  items() |>
  get_request() 

## ----request-2----------------------------------------------------------------
s_obj |>
  stac_search(
    collections = c("CB4_64_16D_STK-1", "S2-16D-2"),
    datetime = "2021-01-01/2021-01-31",
    limit = 400) |>
  post_request()

## ----request-3----------------------------------------------------------------
s_obj |> 
  stac_search(collections = c("CB4_64_16D_STK-1", "S2-16D-2")) |>
  post_request(config = c(httr::add_headers("x-api-key" = "MY-KEY")))

## ----catalog------------------------------------------------------------------
s_obj |> 
  get_request()

## ----collection---------------------------------------------------------------
s_obj |>
  collections("S2-16D-2") |>
  get_request()

## ----item---------------------------------------------------------------------
s_obj |>
  collections("CB4_64_16D_STK-1") |>
  items(feature_id = "CB4_64_16D_STK_v001_021027_2020-07-11_2020-07-26") |>
  get_request()

## ----item-collection----------------------------------------------------------
s_obj |> 
  stac_search(collections = c("CB4_64_16D_STK", "S2-16D-2")) |>
  get_request()

## ----fields-------------------------------------------------------------------
s_obj |>
  stac_search(
    collections = "CB4_64_16D_STK-1",
    datetime = "2019-01-01/2019-12-31",
    limit = 100) |> 
  post_request() |>
  items_fields(field = "properties")

## ----filter-------------------------------------------------------------------
s_obj |>
  stac_search(
    collections = "CB4_64_16D_STK-1",
    datetime = "2019-01-01/2019-12-31",
    limit = 100) |> 
  post_request() |>
  items_filter(properties$`eo:cloud_cover` < 10)

## ----length-------------------------------------------------------------------
s_obj |>
  stac_search(
    collections = "CB4_64_16D_STK-1",
    datetime = "2019-01-01/2019-12-31",
    limit = 100) |> 
  post_request() |>
  items_length()

## ----matched------------------------------------------------------------------
s_obj |>
  stac_search(
    collections = "CB4_64_16D_STK-1",
    datetime = "2019-01-01/2019-12-31",
    limit = 100) |>
  post_request() |>
  items_matched()

## ----fetch--------------------------------------------------------------------
items_fetched <- s_obj |>
  stac_search(
    collections = "CB4_64_16D_STK-1",
    datetime = "2019-01-01/2019-12-31",
    limit = 500) |>
  post_request() |>
  items_fetch(progress = FALSE)

items_fetched

## ----length-2-----------------------------------------------------------------
items_length(items_fetched)

## ----assets-------------------------------------------------------------------
items_assets(items_fetched)

## ----assets-2-----------------------------------------------------------------
s_obj |>
  stac_search(
    collections = "CB4_64_16D_STK-1",
    datetime = "2019-01-01/2019-12-31",
    limit = 10) |>
  post_request() |>
  items_assets()

## ----assets-select------------------------------------------------------------
selected_assets <- s_obj |>
  stac_search(
    collections = "CB4_64_16D_STK-1",
    datetime = "2019-01-01/2019-12-31",
    limit = 10) |>
  post_request() |>
  assets_select(asset_names = c("BAND14", "NDVI"))

## ----assets-3-----------------------------------------------------------------
items_assets(selected_assets)

## ----assets-url---------------------------------------------------------------
selected_assets |> 
  assets_url()

## ----assets-renamed-----------------------------------------------------------
renamed_assets <- selected_assets |> 
  assets_rename(BAND14 = "B14")
renamed_assets

## ----assets-4-----------------------------------------------------------------
items_assets(renamed_assets)

## ----asset-preview-check, eval=TRUE, include=FALSE, echo=FALSE----------------
is_accessible <- is_online && tryCatch({
  res <- httr::HEAD(
    assets_url(items_fetched$features[[2]], asset_names = "thumbnail")
  )
  !httr::http_error(res)
}, error = function(e) {
  FALSE
})

## ----plot-preview, eval=is_accessible, fig.height=3, fig.width=5--------------
second_item <- items_fetched$features[[2]]
second_item |>
  assets_url(asset_names = "thumbnail") |>
  preview_plot()

