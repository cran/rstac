## ----prepare, include = FALSE-------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(rstac)

## ----text-1-------------------------------------------------------------------
cql2_text(vehicle_height > (bridge_clearance - 1)) # TEXT format

## ----json-1-------------------------------------------------------------------
cql2_json(vehicle_height > (bridge_clearance - 1)) # JSON format

## ----string-------------------------------------------------------------------
cql2_text("Via dell'Avvento")
cql2_json("Via dell'Avvento")

## ----number-------------------------------------------------------------------
cql2_text(3.1415)
cql2_json(-100)

## ----boolean------------------------------------------------------------------
cql2_text(TRUE)
cql2_json(FALSE)

## ----timestamp----------------------------------------------------------------
cql2_text(timestamp("1969-07-20T20:17:40Z"))
cql2_json(timestamp("1969-07-20T20:17:40Z"))

## ----date---------------------------------------------------------------------
cql2_text(date("1969-07-20"))
cql2_json(date("1969-07-20"))

## ----property-----------------------------------------------------------------
cql2_text(windSpeed > 1)
cql2_json(windSpeed > 1)

## ----comparison-1-------------------------------------------------------------
cql2_text(city == "Crato")
cql2_json(city == "Jacareí")

## ----comparison-2-------------------------------------------------------------
cql2_text(avg(windSpeed) < 4)
cql2_json(avg(windSpeed) < 4)

## ----comparison-3-------------------------------------------------------------
cql2_text(balance - 150.0 > 0)
cql2_json(balance - 150.0 > 0)

## ----comparison-4-------------------------------------------------------------
cql2_text(updated >= date('1970-01-01'))
cql2_json(updated >= date('1970-01-01'))

## ----is-null------------------------------------------------------------------
cql2_text(!is_null(geometry))
cql2_json(!is_null(geometry))

## ----like---------------------------------------------------------------------
cql2_text(name %like% "Smith%")
cql2_json(name %like% "Smith%")

## ----between------------------------------------------------------------------
cql2_text(between(depth, 100.0, 150.0))
cql2_json(between(depth, 100.0, 150.0))

## ----in-1---------------------------------------------------------------------
cql2_text(cityName %in% list('Toronto', 'Frankfurt', 'Tokyo', 'New York'))
cql2_json(cityName %in% list('Toronto', 'Frankfurt', 'Tokyo', 'New York'))

## ----in-2---------------------------------------------------------------------
cql2_text(!category %in% list(1, 2, 3, 4))
cql2_json(!category %in% list(1, 2, 3, 4))

## ----spatial, message=FALSE---------------------------------------------------
poly <- list(
  type = "Polygon",
  coordinates = list(
    rbind(
      c(0,0),
      c(0,1),
      c(0,1)
    )
  ))
cql2_text(s_intersects(geometry, {{poly}}))
cql2_json(s_intersects(geometry, {{poly}}))

## ----temporal-----------------------------------------------------------------
cql2_text(t_intersects(event_date, interval("1969-07-16T05:32:00Z", "1969-07-24T16:50:35Z")))
cql2_json(t_intersects(event_date, interval("1969-07-16T05:32:00Z", "1969-07-24T16:50:35Z")))

## ----functions----------------------------------------------------------------
cql2_text(s_within(road, Buffer(geometry, 10, "m")))
cql2_json(s_within(road, Buffer(geometry, 10, "m")))

