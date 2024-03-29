testthat::test_that("items functions", {
    # skip cran check test
    testthat::skip_on_cran()

    res <- stac("https://brazildatacube.dpi.inpe.br/stac/") %>%
      stac_search(
        collections = "CB4-16D-2",
        limit = 10) %>%
      get_request()

    res_bbox <- stac("https://brazildatacube.dpi.inpe.br/stac/") %>%
      stac_search(
        collections = "CB4-16D-2",
        limit = 1,
        datetime = "2017-01-01/2017-03-01",
        bbox = c(-52.5732, -12.5975, -51.4893, -11.6522)) %>%
      get_request()

    intersects_geojson <- list(
      type = "Polygon",
      coordinates = structure(c(-52.5732, -51.4893,
                                -51.4893, -52.5732,
                                -52.5732, -12.5975,
                                -12.5975, -11.6522,
                                -11.6522, -12.5975),
                              .Dim = c(1L, 5L, 2L))
    )

    res_geo <- stac("https://brazildatacube.dpi.inpe.br/stac/") %>%
      stac_search(
        collections = "CB4-16D-2",
        limit = 1,
        datetime = "2017-01-01/2017-03-01",
        intersects = intersects_geojson) %>%
      post_request()

    res_ext <- stac("https://brazildatacube.dpi.inpe.br/stac/") %>%
      stac_search(collections = "CB4-16D-2",
                  limit = 10) %>%
      ext_query("bdc:tile" %in% "007004") %>%
      post_request()

    item_stac <- stac("https://brazildatacube.dpi.inpe.br/stac/") %>%
      collections(collection_id = "CB4-16D-2") %>%
      items(feature_id = "CB4-16D_V2_000002_20230509") %>%
      get_request()

    asset_url <- assets_url(item_stac, asset_names = "thumbnail")

    expect_null(
      tryCatch({
        preview_plot(asset_url)
      }, error = function(e) {e},
      warning = function(w) {w}
      ))

    modified_url <- gsub(pattern = ".png", replacement = ".ddd", asset_url)
    expect_error(preview_switch(modified_url))

    items_ms <- stac("https://planetarycomputer.microsoft.com/api/stac/v1") %>%
      stac_search(
        collections = "sentinel-2-l2a",
        datetime = "2020-01-01/2020-01-31",
        limit = 1) %>%
      post_request()

    # items_fetch---------------------------------------------------------------
    # error - given another object
    testthat::expect_error(items_fetch(list(res)))

    # ok - stac_collection_list object
    testthat::expect_equal(
      object = subclass(
        stac("https://brazildatacube.dpi.inpe.br/stac/") %>%
          stac_search(collections = "LCC_C4_64_1M_STK_GO_PA-SPC-AC-NA-1",
                      limit = 500) %>%
          get_request(.) %>%
          items_fetch()),
      expected = "doc_items"
    )

    testthat::expect_error(
      object = {
        mock_obj <- res_bbox
        mock_obj$context$matched <- 0
        items_fetch(mock_obj)
      }
    )

    testthat::expect_equal(
      object = subclass(
        suppressWarnings(
          stac("https://planetarycomputer.microsoft.com/api/stac/v1") %>%
            stac_search(collections = "io-lulc", limit = 1) %>%
            ext_query("io:tile_id" %in% "60W") %>%
            post_request() %>%
            items_fetch())),
      expected = "doc_items"
    )

    # items_length--------------------------------------------------------------
    # ok - return a numeric
    testthat::expect_true(is.numeric(items_length(res)))

    # items_datetime------------------------------------------------------------
    # doc_items
    testthat::expect_length(items_datetime(res), n = 10)

    # doc_item
    testthat::expect_vector(items_datetime(item_stac), ptype = character())

    # provide wrong object
    testthat::expect_error(
      object = items_datetime(
        stac("https://brazildatacube.dpi.inpe.br/stac/") %>%
          collections(collection_id = "CB4-16D-2") %>%
          get_request()
      )
    )

    # items_bbox----------------------------------------------------------------
    # doc_items
    testthat::expect_length(items_bbox(res), n = 10)

    # doc_item
    testthat::expect_vector(items_bbox(item_stac), ptype = double())

    testthat::expect_error(
      object = items_bbox(
        stac("https://brazildatacube.dpi.inpe.br/stac/") %>%
          collections(collection_id = "CB4-16D-2") %>%
          get_request()
      )
    )

    # items_assets---------------------------------------------------------------
    # doc_items
    testthat::expect_length(items_assets(res), n = 11)

    # doc_item
    testthat::expect_vector(items_assets(item_stac), ptype = character())

    # provide wrong object
    testthat::expect_error(
      object = items_assets(
        stac("https://brazildatacube.dpi.inpe.br/stac/") %>%
          collections(collection_id = "CB4-16D-2") %>%
          get_request()
      )
    )

    # items_matched-------------------------------------------------------------
    testthat::expect_error(items_matched(list()))

    # ok - return a numeric
    testthat::expect_true(is.numeric(items_matched(res)))

    # ok - return a null
    testthat::expect_null(suppressWarnings(items_matched(items_ms)))

    # items_filter--------------------------------------------------------------
    testthat::expect_warning(
      object = items_filter(
        res, filter_fn = function(x) {x[["eo:cloud_cover"]] < 10}
      ),
      class = "doc_items"
    )

    testthat::expect_s3_class(
      object = items_filter(
        res, filter_fn = function(x) {x$properties$`eo:cloud_cover` < 10}
      ),
      class = "doc_items"
    )

    testthat::expect_warning(
      object = items_filter(res, properies$`eo:cloud_cover` < 10),
      class = "doc_items"
    )

    testthat::expect_s3_class(
      object = items_filter(res, properties$`eo:cloud_cover` < 10),
      class = "doc_items"
    )

    testthat::expect_s3_class(
      object = items_filter(res),
      class = "doc_items"
    )

    testthat::expect_error(
      object = items_filter(item_stac, `eo:cloud_cover` < 10)
    )

    testthat::expect_warning(
      object = items_filter(res, list(`eo:cloud_cover` < 10))
    )

    # items_assets--------------------------------------------------------------
    testthat::expect_equal(
      object = class(items_assets(res)),
      expected = "character"
    )

    testthat::expect_equal(
      object = class(items_assets(item_stac)),
      expected = "character"
    )

    # items_next----------------------------------------------------------------
    testthat::expect_s3_class(
      object = items_next(res_geo),
      class = "doc_items"
    )

    testthat::expect_s3_class(
      object = items_next(res_bbox),
      class = "doc_items"
    )

    testthat::expect_s3_class(
      object = items_next(res),
      class = "doc_items"
    )

    testthat::expect_s3_class(
      object = items_next(res_ext),
      class = "doc_items"
    )

    testthat::expect_equal(
      object = items_length(items_next(res)),
      expected = 10
    )

    testthat::expect_error(
      object = {
        mock_obj <- res_geo
        attributes(mock_obj)$query <- list(NULL)
        items_next(mock_obj)
      }
    )

    # items_reap----------------------------------------------------------------
    # doc_items
    testthat::expect_equal(
      object = class(items_reap(item_stac, field = c("properties", "datetime"))),
      expected = "character"
    )

    testthat::expect_length(
      object = items_reap(item_stac, field = c("properties", "datetime")),
      n = 1
    )

    testthat::expect_null(items_reap(item_stac, FALSE))

    testthat::expect_error(
      object = subclass(items_reap(item_stac))
    )

    # doc_items
    testthat::expect_equal(
      object = class(items_reap(res, field = c("properties", "datetime"))),
      expected = "character"
    )

    testthat::expect_length(
      object = items_reap(res, field = c("properties", "datetime")),
      n = 10
    )

    # items_reap with pick_fn
    testthat::expect_equal(
      object = class(items_reap(item_stac, field = "properties",
                                pick_fn = function(x) x$datetime)),
      expected = "character"
    )

    testthat::expect_length(
      object = items_reap(item_stac, field = "properties",
                          pick_fn = function(x) x$datetime),
      n = 1
    )

    # items_reap with empty features
    res$features <- list()
    testthat::expect_null(items_reap(res))

    testthat::expect_null(items_reap(res, FALSE))
    testthat::expect_null(items_reap(res, FALSE, field = FALSE))
})
