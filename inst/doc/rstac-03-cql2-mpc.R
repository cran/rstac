## ---- include = FALSE---------------------------------------------------------
is_online <- tryCatch({
  res <- httr::GET("https://planetarycomputer.microsoft.com/api/stac/v1")
  !httr::http_error(res)
}, error = function(e) {
  FALSE
})

knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>",
  eval = is_online
)

## ----load-rstac, eval=TRUE----------------------------------------------------
library(rstac)

## ----connection, eval=TRUE----------------------------------------------------
planetary_computer <- stac("https://planetarycomputer.microsoft.com/api/stac/v1")
planetary_computer

## ----queryables---------------------------------------------------------------
planetary_computer |>
  collections("landsat-c2-l2") |> 
  queryables() |> 
  get_request()

## ----cql2-search--------------------------------------------------------------
time_range <- cql2_interval("2020-12-01", "2020-12-31")
bbox <- c(-122.2751, 47.5469, -121.9613, 47.7458)
area_of_interest = cql2_bbox_as_geojson(bbox)

stac_items <- planetary_computer |>
  ext_filter(
    collection == "landsat-c2-l2" &&
      t_intersects(datetime, {{time_range}}) &&
      s_intersects(geometry, {{area_of_interest}})
  ) |>
  post_request()

## ----items-length-------------------------------------------------------------
stac_items

## ----geojson-to-sf------------------------------------------------------------
sf <- items_as_sf(stac_items)

# create a function to plot a map
plot_map <- function(x) {
  library(tmap)
  library(leaflet)
  current.mode <- tmap_mode("view")
  tm_basemap(providers[["Stamen.Watercolor"]]) +
    tm_shape(x) + 
    tm_borders()
}

plot_map(sf)

## ----lowest-cloud-cover-------------------------------------------------------
cloud_cover <- stac_items |>
  items_reap(field = c("properties", "eo:cloud_cover"))
selected_item <- stac_items$features[[which.min(cloud_cover)]]

## ----assets-list--------------------------------------------------------------
items_assets(selected_item)

purrr::map_dfr(items_assets(selected_item), function(key) {
  tibble::tibble(asset = key, description = selected_item$assets[[key]]$title)
})

## ----asset-preview-check, eval=TRUE, include=FALSE, echo=FALSE----------------
is_accessible <- is_online && tryCatch({
  res <- httr::HEAD(
    assets_url(selected_item, asset_names = "rendered_preview")
  )
  !httr::http_error(res)
}, error = function(e) {
  FALSE
})

## ----asset-preview, eval=is_accessible, fig.height=3, fig.width=5-------------
#  selected_item$assets[["rendered_preview"]]$href
#  
#  selected_item |>
#    assets_url(asset_names = "rendered_preview") |>
#    preview_plot()

## ----sign-item----------------------------------------------------------------
selected_item <- selected_item |>
  items_sign(sign_fn = sign_planetary_computer())

selected_item |> 
  assets_url(asset_names = "blue") |>
  substr(1, 255)

## ----url-check----------------------------------------------------------------
library(httr)
selected_item |> 
  assets_url(asset_names = "blue") |>
  httr::HEAD() |>
  httr::status_code()

## ----read-file----------------------------------------------------------------
library(stars)
selected_item |> 
  assets_url(asset_names = "blue", append_gdalvsi = TRUE) |>
  stars::read_stars(RasterIO = list(nBufXSize = 512, nBufYSize = 512)) |>
  plot(main = "blue")

## ----cql2-search-cloud--------------------------------------------------------
stac_items <- planetary_computer |>
  ext_filter(
    collection %in% c("sentinel-2-l2a", "landsat-c2-l2") &&
      t_intersects(datetime, {{time_range}}) &&
      s_intersects(geometry, {{area_of_interest}}) &&
      `eo:cloud_cover` < 20
  ) |>
  post_request()

## ----assets-rename------------------------------------------------------------
stac_items <- stac_items |>
  assets_select(asset_names = c("B11", "swir16")) |>
  assets_rename(B11 = "swir16")

stac_items |>
  items_assets()

## ----items-fetch--------------------------------------------------------------
stac_items <- planetary_computer |>
  ext_filter(
    collection == "sentinel-2-l2a" &&
      t_intersects(datetime, interval("2020-01-01", "2020-12-31")) &&
      s_intersects(geometry, {{
        cql2_bbox_as_geojson(c(-124.2751, 45.5469, -123.9613, 45.7458))
      }})
  ) |>
  post_request()

stac_items <- items_fetch(stac_items)

## ----cloud-cover-ts-plot------------------------------------------------------
library(dplyr)
library(slider)
library(ggplot2)

df <- items_as_sf(stac_items)  |>
  dplyr::mutate(datetime = as.Date(datetime)) |>
  dplyr::group_by(datetime) |>
  dplyr::summarise(`eo:cloud_cover` = mean(`eo:cloud_cover`)) |>
  dplyr::mutate(
    `eo:cloud_cover` = slider::slide_mean(
      `eo:cloud_cover`, before = 3, after = 3
    )
  )

df |> 
  ggplot2::ggplot() +
  ggplot2::geom_line(ggplot2::aes(x = datetime, y = `eo:cloud_cover`))

## ----collection-landsat-bands-------------------------------------------------
landsat <- planetary_computer |>
  collections(collection_id = "landsat-c2-l2") |>
  get_request()

library(purrr)
purrr::map_dfr(landsat$summaries$`eo:bands`, tibble::as_tibble_row)

## ----landsat-assets-----------------------------------------------------------
purrr::map_dfr(landsat$item_assets, function(x) {
    tibble::as_tibble_row(
      purrr::compact(x[c("title", "description", "gsd")])
    )
})

## ----collection-daymet--------------------------------------------------------
daymet <- planetary_computer |>
  collections(collection_id = "daymet-daily-na") |>
  get_request()

daymet

## ----daymet-assets------------------------------------------------------------
items_assets(daymet)

daymet |>
  assets_select(asset_names = "zarr-abfs") |>
  assets_url()

