
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tidygeoRSS 🌎 🌍 🌏

![R-CMD-check](https://github.com/RobertMyles/tidygeoRSS/workflows/R-CMD-check/badge.svg)
[![CRAN\_Status\_Badge](https://www.r-pkg.org/badges/version/tidygeoRSS)](https://cran.r-project.org/package=tidygeoRSS)

The idea of tidygeoRSS is to parse ‘geo’ feeds – RSS, Atom and JSON –
and return them as tibbles complete with the geographical information in
a way that is compatible with the
[sf](https://r-spatial.github.io/sf/articles/sf1.html) library.

For more information on these formats, see:

  - geoRSS & geoAtom: <http://www.georss.org/>  
  - geoJSON: <https://geojson.org/>

## Installation

You can install the released version of tidygeoRSS from
[CRAN](https://CRAN.R-project.org) with:

``` r
install.packages("tidygeoRSS")
```

And the development version from
[GitHub](https://github.com/RobertMyles/tidygeoRSS) with:

``` r
# install.packages("remotes")
remotes::install_github("RobertMyles/tidygeoRSS")
```

### Installing sf

tidygeoRSS relies on sf, which also relies on some system dependencies,
so you will most likely have to install certain things before using
tidygeoRSS. More information is available
[here](https://r-spatial.github.io/sf/index.html#installing).

## Usage

### geoJSON example

``` r
library(tidygeoRSS)
tidygeo("https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/2.5_day.geojson")
#> GET request successful. Parsing...
#> # A tibble: 39 x 30
#>    feed_title feed_url time_generated id      mag place    time updated url  
#>    <chr>      <chr>             <dbl> <chr> <dbl> <chr>   <dbl>   <dbl> <chr>
#>  1 USGS Magn… https:/…  1591352536000 ak02…  2.5  "40 … 1.59e12 1.59e12 http…
#>  2 USGS Magn… https:/…  1591352536000 pr20…  2.58 "12 … 1.59e12 1.59e12 http…
#>  3 USGS Magn… https:/…  1591352536000 us60…  5.2  "128… 1.59e12 1.59e12 http…
#>  4 USGS Magn… https:/…  1591352536000 us60…  4.1  "107… 1.59e12 1.59e12 http…
#>  5 USGS Magn… https:/…  1591352536000 pr20…  2.85 "2 k… 1.59e12 1.59e12 http…
#>  6 USGS Magn… https:/…  1591352536000 us60…  5.1  "198… 1.59e12 1.59e12 http…
#>  7 USGS Magn… https:/…  1591352536000 us60…  3.2  "12 … 1.59e12 1.59e12 http…
#>  8 USGS Magn… https:/…  1591352536000 us60…  4.5  "50 … 1.59e12 1.59e12 http…
#>  9 USGS Magn… https:/…  1591352536000 us60…  4.5  "54 … 1.59e12 1.59e12 http…
#> 10 USGS Magn… https:/…  1591352536000 us60…  4.1  "9 k… 1.59e12 1.59e12 http…
#> # … with 29 more rows, and 21 more variables: detail <chr>, felt <int>,
#> #   cdi <dbl>, mmi <dbl>, alert <chr>, status <chr>, tsunami <int>, sig <int>,
#> #   net <chr>, code <chr>, ids <chr>, sources <chr>, types <chr>, nst <int>,
#> #   dmin <dbl>, rms <dbl>, gap <dbl>, magType <chr>, type <chr>, title <chr>,
#> #   geometry <POINT [°]>
```

### geo-Atom example

``` r
tidygeo("https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_hour.atom")
#> GET request successful. Parsing...
#> Simple feature collection with 14 features and 13 fields
#> geometry type:  POINT
#> dimension:      XY
#> bbox:           xmin: 35.621 ymin: -149.9918 xmax: 64.6012 ymax: -117.4023
#> CRS:            NA
#> # A tibble: 14 x 14
#>    feed_title feed_url feed_last_updated   feed_author feed_link feed_icon
#>    <chr>      <chr>    <dttm>              <chr>       <chr>     <chr>    
#>  1 USGS All … https:/… 2020-06-05 09:22:42 U.S. Geolo… https://… https://…
#>  2 USGS All … https:/… 2020-06-05 09:22:42 U.S. Geolo… https://… https://…
#>  3 USGS All … https:/… 2020-06-05 09:22:42 U.S. Geolo… https://… https://…
#>  4 USGS All … https:/… 2020-06-05 09:22:42 U.S. Geolo… https://… https://…
#>  5 USGS All … https:/… 2020-06-05 09:22:42 U.S. Geolo… https://… https://…
#>  6 USGS All … https:/… 2020-06-05 09:22:42 U.S. Geolo… https://… https://…
#>  7 USGS All … https:/… 2020-06-05 09:22:42 U.S. Geolo… https://… https://…
#>  8 USGS All … https:/… 2020-06-05 09:22:42 U.S. Geolo… https://… https://…
#>  9 USGS All … https:/… 2020-06-05 09:22:42 U.S. Geolo… https://… https://…
#> 10 USGS All … https:/… 2020-06-05 09:22:42 U.S. Geolo… https://… https://…
#> 11 USGS All … https:/… 2020-06-05 09:22:42 U.S. Geolo… https://… https://…
#> 12 USGS All … https:/… 2020-06-05 09:22:42 U.S. Geolo… https://… https://…
#> 13 USGS All … https:/… 2020-06-05 09:22:42 U.S. Geolo… https://… https://…
#> 14 USGS All … https:/… 2020-06-05 09:22:42 U.S. Geolo… https://… https://…
#> # … with 8 more variables: entry_title <chr>, entry_url <chr>,
#> #   entry_last_updated <dttm>, entry_link <chr>, entry_summary <chr>,
#> #   entry_category <list>, entry_latlon <POINT>, entry_elev <dbl>
```

### geoRSS example

``` r
tidygeo("http://www.geograph.org.uk/syndicator.php?format=GeoRSS")
#> GET request successful. Parsing...
#> Simple feature collection with 15 features and 7 fields
#> geometry type:  POINT
#> dimension:      XY
#> bbox:           xmin: 50.55285 ymin: -3.620593 xmax: 55.58201 ymax: 0.018502
#> CRS:            NA
#> # A tibble: 15 x 8
#>    feed_title feed_link feed_description item_title item_link item_description
#>    <chr>      <chr>     <chr>            <chr>      <chr>     <chr>           
#>  1 Geograph … https://… Latest Images    SK5023 : … https://… "Lock #55 on th…
#>  2 Geograph … https://… Latest Images    NT2732 : … https://…  <NA>           
#>  3 Geograph … https://… Latest Images    SK5023 : … https://… "Carrying a bri…
#>  4 Geograph … https://… Latest Images    TL3763 : … https://… "The Pavilion f…
#>  5 Geograph … https://… Latest Images    SP9123 : … https://…  <NA>           
#>  6 Geograph … https://… Latest Images    SK5023 : … https://… "A canalised se…
#>  7 Geograph … https://… Latest Images    SK5023 : … https://… "One of two wei…
#>  8 Geograph … https://… Latest Images    SK5023 : … https://… "One of two wei…
#>  9 Geograph … https://… Latest Images    SK6111 : … https://… "Ordnance Surve…
#> 10 Geograph … https://… Latest Images    SK5023 : … https://… "One of two wei…
#> 11 Geograph … https://… Latest Images    SP9121 : … https://…  <NA>           
#> 12 Geograph … https://… Latest Images    NZ2947 : … https://…  <NA>           
#> 13 Geograph … https://… Latest Images    SK5023 : … https://… "The river flow…
#> 14 Geograph … https://… Latest Images    SX8573 : … https://… "Visible on the…
#> 15 Geograph … https://… Latest Images    ST9752 : … https://… "Looking over t…
#> # … with 2 more variables: item_category <list>, item_latlon <POINT>
```
