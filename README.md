
<!-- README.md is generated from README.Rmd. Please edit that file -->

# tidygeoRSS 🌎 🌍 🌏

![R-CMD-check](https://github.com/RobertMyles/tidygeoRSS/workflows/R-CMD-check/badge.svg)

The idea of tidygeoRSS is to parse ‘geo’ feeds – RSS, Atom and JSON –
and return them as tibbles complete with the geographical information in
a way that is compatible with the
[sf](https://r-spatial.github.io/sf/articles/sf1.html) library.

For more information on these formats, see:

  - geo-RSS & geo-Atom: <http://www.georss.org/>  
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
#> # A tibble: 52 x 30
#>    feed_title feed_url time_generated id      mag place    time updated url  
#>    <chr>      <chr>             <dbl> <chr> <dbl> <chr>   <dbl>   <dbl> <chr>
#>  1 USGS Magn… https:/…  1591182375000 us60…  4.4  "409… 1.59e12 1.59e12 http…
#>  2 USGS Magn… https:/…  1591182375000 nn00…  2.5  "34 … 1.59e12 1.59e12 http…
#>  3 USGS Magn… https:/…  1591182375000 us60…  5.9  "408… 1.59e12 1.59e12 http…
#>  4 USGS Magn… https:/…  1591182375000 nn00…  2.5  "29 … 1.59e12 1.59e12 http…
#>  5 USGS Magn… https:/…  1591182375000 us60…  5.2  "74 … 1.59e12 1.59e12 http…
#>  6 USGS Magn… https:/…  1591182375000 us60…  4.9  "30 … 1.59e12 1.59e12 http…
#>  7 USGS Magn… https:/…  1591182375000 us60…  4.6  "62 … 1.59e12 1.59e12 http…
#>  8 USGS Magn… https:/…  1591182375000 us60…  6.8  "48 … 1.59e12 1.59e12 http…
#>  9 USGS Magn… https:/…  1591182375000 us60…  4.8  "240… 1.59e12 1.59e12 http…
#> 10 USGS Magn… https:/…  1591182375000 pr20…  2.99 "2 k… 1.59e12 1.59e12 http…
#> # … with 42 more rows, and 21 more variables: detail <chr>, felt <int>,
#> #   cdi <dbl>, mmi <dbl>, alert <chr>, status <chr>, tsunami <int>, sig <int>,
#> #   net <chr>, code <chr>, ids <chr>, sources <chr>, types <chr>, nst <int>,
#> #   dmin <dbl>, rms <dbl>, gap <dbl>, magType <chr>, type <chr>, title <chr>,
#> #   geometry <POINT [°]>
```

### geo-Atom example

``` r
tidygeo("https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_hour.atom")
#> GET request successful. Parsing...
#> Simple feature collection with 21 features and 13 fields
#> geometry type:  POINT
#> dimension:      XY
#> bbox:           xmin: 33.45283 ymin: -118.0382 xmax: 46.9145 ymax: 152.5861
#> CRS:            NA
#> # A tibble: 21 x 14
#>    feed_title feed_url feed_last_updated   feed_author feed_link feed_icon
#>    <chr>      <chr>    <dttm>              <chr>       <chr>     <chr>    
#>  1 USGS All … https:/… 2020-06-03 10:06:32 U.S. Geolo… https://… https://…
#>  2 USGS All … https:/… 2020-06-03 10:06:32 U.S. Geolo… https://… https://…
#>  3 USGS All … https:/… 2020-06-03 10:06:32 U.S. Geolo… https://… https://…
#>  4 USGS All … https:/… 2020-06-03 10:06:32 U.S. Geolo… https://… https://…
#>  5 USGS All … https:/… 2020-06-03 10:06:32 U.S. Geolo… https://… https://…
#>  6 USGS All … https:/… 2020-06-03 10:06:32 U.S. Geolo… https://… https://…
#>  7 USGS All … https:/… 2020-06-03 10:06:32 U.S. Geolo… https://… https://…
#>  8 USGS All … https:/… 2020-06-03 10:06:32 U.S. Geolo… https://… https://…
#>  9 USGS All … https:/… 2020-06-03 10:06:32 U.S. Geolo… https://… https://…
#> 10 USGS All … https:/… 2020-06-03 10:06:32 U.S. Geolo… https://… https://…
#> # … with 11 more rows, and 8 more variables: entry_title <chr>,
#> #   entry_url <chr>, entry_last_updated <dttm>, entry_link <chr>,
#> #   entry_summary <chr>, entry_category <list>, entry_latlon <POINT>,
#> #   entry_elev <dbl>
```

### geoRSS example

``` r
tidygeo("http://www.geograph.org.uk/syndicator.php?format=GeoRSS")
#> GET request successful. Parsing...
#> Simple feature collection with 15 features and 7 fields
#> geometry type:  POINT
#> dimension:      XY
#> bbox:           xmin: 50.1025 ymin: -5.27586 xmax: 58.01868 ymax: 0.937893
#> CRS:            NA
#> # A tibble: 15 x 8
#>    feed_title feed_link feed_description item_title item_link item_description
#>    <chr>      <chr>     <chr>            <chr>      <chr>     <chr>           
#>  1 Geograph … https://… Latest Images    SX0990 : … https://… Forraburry Chur…
#>  2 Geograph … https://… Latest Images    SK1707 : … https://… Tamhorn Farm Br…
#>  3 Geograph … https://… Latest Images    NZ2066 : … https://… Looking towards…
#>  4 Geograph … https://… Latest Images    NZ2066 : … https://… Looking towards…
#>  5 Geograph … https://… Latest Images    SK1707 : … https://… Looking north-n…
#>  6 Geograph … https://… Latest Images    ST4166 : … https://… <NA>            
#>  7 Geograph … https://… Latest Images    TQ4730 : … https://… This section of…
#>  8 Geograph … https://… Latest Images    SK1707 : … https://… Looking north-n…
#>  9 Geograph … https://… Latest Images    SX1083 : … https://… Trevia Cross, a…
#> 10 Geograph … https://… Latest Images    NS5573 : … https://… This worker tre…
#> 11 Geograph … https://… Latest Images    TF9742 : … https://… <NA>            
#> 12 Geograph … https://… Latest Images    SK6514 : … https://… <NA>            
#> 13 Geograph … https://… Latest Images    SW6527 : … https://… Cross Street Cr…
#> 14 Geograph … https://… Latest Images    NT2570 : … https://… Having never se…
#> 15 Geograph … https://… Latest Images    NC5106 : … https://… The burn is muc…
#> # … with 2 more variables: item_category <list>, item_latlon <POINT>
```
