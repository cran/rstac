## ---- include = FALSE---------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  cache = TRUE
)

## ----setup, echo=FALSE--------------------------------------------------------
library(rstac)
library(tibble)

## ----endpoints, echo=FALSE----------------------------------------------------

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

## ----queries-1----------------------------------------------------------------
s_obj <- stac("https://brazildatacube.dpi.inpe.br/stac/")
s_obj

## -----------------------------------------------------------------------------
s_obj$base_url

## ----queries-2----------------------------------------------------------------
s_obj |> collections()

## ----queries-3----------------------------------------------------------------
s_obj |> collections("S2-16D-2")

## ----queries-4----------------------------------------------------------------
s_obj |> 
  collections("S2-16D-2") |>
  items()

## ----queries-5----------------------------------------------------------------
s_obj |> 
  collections("S2-16D-2") |> 
  items(feature_id = "S2-16D_V2_015011_20190117")

## ----queries-6----------------------------------------------------------------
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
  stac_search(collections = c("CB4_64_16D_STK-1", "S2-16D-2"),
              datetime = "2021-01-01/2021-01-31",
              limit = 400) |>
  post_request()

## ----request-3----------------------------------------------------------------
s_obj |> 
  stac_search(collections = c("CB4_64_16D_STK-1", "S2-16D-2")) |>
  post_request(config = c(httr::add_headers("x-api-key" = "MY-KEY")))

## -----------------------------------------------------------------------------
s_obj %>% get_request()

## -----------------------------------------------------------------------------
s_obj |>
  collections("S2-16D-2") |>
  get_request()

## -----------------------------------------------------------------------------
s_obj |>
  collections("CB4_64_16D_STK-1") |>
  items(feature_id = "CB4_64_16D_STK_v001_021027_2020-07-11_2020-07-26") |>
  get_request()

## -----------------------------------------------------------------------------
s_obj |> 
  stac_search(collections = c("CB4_64_16D_STK", "S2-16D-2")) |>
  get_request()

## -----------------------------------------------------------------------------
s_obj |>
  stac_search(collections = "CB4_64_16D_STK-1",
              datetime = "2019-01-01/2019-12-31",
              limit = 100) |> 
  post_request() |>
  items_fields(field = "properties")

## -----------------------------------------------------------------------------
s_obj |>
  stac_search(collections = "CB4_64_16D_STK-1",
              datetime = "2019-01-01/2019-12-31",
              limit = 100) |> 
  post_request() |>
  items_filter(properties$`eo:cloud_cover` < 10)

## -----------------------------------------------------------------------------
s_obj |>
  stac_search(collections = "CB4_64_16D_STK-1",
              datetime = "2019-01-01/2019-12-31",
              limit = 100) |> 
  post_request() |>
  items_length()

## -----------------------------------------------------------------------------
s_obj |>
  stac_search(collections = "CB4_64_16D_STK-1",
              datetime = "2019-01-01/2019-12-31",
              limit = 100) |>
  post_request() |>
  items_matched()

## -----------------------------------------------------------------------------
items_fetched <- s_obj |>
  stac_search(collections = "CB4_64_16D_STK-1",
              datetime = "2019-01-01/2019-12-31",
              limit = 500) |>
  post_request() |>
  items_fetch()

items_fetched

## -----------------------------------------------------------------------------
items_length(items_fetched)

## -----------------------------------------------------------------------------
items_assets(items_fetched)

## -----------------------------------------------------------------------------
s_obj |>
  stac_search(collections = "CB4_64_16D_STK-1",
              datetime = "2019-01-01/2019-12-31",
              limit = 10) |>
  post_request() |>
  items_assets()

## -----------------------------------------------------------------------------
selected_assets <- s_obj |>
  stac_search(collections = "CB4_64_16D_STK-1",
              datetime = "2019-01-01/2019-12-31",
              limit = 10) |>
  post_request() |>
  assets_select(asset_names = c("BAND14", "NDVI"))

## -----------------------------------------------------------------------------
items_assets(selected_assets)

## -----------------------------------------------------------------------------
selected_assets |> assets_url()

## -----------------------------------------------------------------------------
renamed_assets <- selected_assets |> assets_rename(BAND14 = "B14")
renamed_assets

## -----------------------------------------------------------------------------
items_assets(renamed_assets)

