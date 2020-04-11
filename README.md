
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

And the development version from [GitHub](https://github.com/) with:

``` r
# install.packages("remotes")
remotes::install_github("RobertMyles/tidygeoRSS")
```

### Installing sf

tidygeoRSS relies on sf, which also relies on some system dependencies,
so you will most likely have to install certain things before using
tidygeoRSS. More information is available
[here](https://r-spatial.github.io/sf/index.html#installing).
