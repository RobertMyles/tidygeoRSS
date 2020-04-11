#' @title Extract a tidy data frame from geoRSS, geo-Atom and geoJSON feeds
#' @importFrom xml2 xml_contents as_list xml_find_all read_xml xml_text
#' @importFrom xml2 xml_attr xml_find_first xml_type read_html
#' @importFrom dplyr full_join tibble select case_when bind_cols mutate
#' @importFrom dplyr select_if mutate_if
#' @importFrom purrr map safely compact map_if keep map_df
#' @importFrom anytime anytime
#' @importFrom stringr str_extract
#' @importFrom strex str_before_first str_after_first
#' @importFrom httr GET user_agent
#' @importFrom sf read_sf st_point st_linestring st_polygon st_bbox st_as_sf
#' @importFrom jsonlite parse_json
#' @importFrom rlang has_name as_name enquo
#' @importFrom magrittr "%>%"
#' @import tidyRSS
#' @importFrom utils getFromNamespace
#' @param feed \code{character}, the url for the feed that you want to parse,
#' e.g. "https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_hour.atom".
#' @param config Arguments passed off to \code{httr::GET()}.
#' @param clean_tags default \code{TRUE}. Clean HTML tags from summary and content?
#' @param list default \code{FALSE}. Return metadata and entry information in separate dataframes?
#' These will be combined in a named list.
#' @param parse_dates \code{logical}, default \code{TRUE}.
#' If \code{TRUE}, tidyRSS will attempt to parse columns that contain
#' datetime values, although this may fail, see note.
#' @note \code{tidygeo()} attempts to parse columns that should contain
#' dates. This can fail, as can be seen in tidyRSS
#' \href{https://github.com/RobertMyles/tidyRSS/issues/37}{here}. If you need
#' lower-level control over the parsing of dates, it's better to leave
#' \code{parse_dates} equal to \code{FALSE} and then parse these yourself.
#' @export
tidygeo <- function(feed, config = list(), clean_tags = TRUE, list = FALSE,
                    parse_dates = TRUE) {
  # checks
  # checks
  if (!identical(length(feed), 1L)) stop("Please supply only one feed at a time.")
  if (!is.logical(list)) stop("`list` may be FALSE or TRUE only.")
  if (!is.logical(clean_tags)) stop("`clean_tags` may be FALSE or TRUE only.")
  if (!is.list(config)) stop("`config` should be a list only.")
  if (!is.logical(parse_dates)) stop("`parse_dates` may be FALSE or TRUE only.")
  feed <- trimws(feed)
  
  # send user agent
  ua <- set_user(config)
  # try to get response
  res <- safe_get(feed, config = ua)
  # check type
  typ <- type_check(res)
  # send to parsers
  if (typ == "rss") {
    res <- geo_rss_parse(res, list, clean_tags, parse_dates)
  } else if (typ == "atom") {
    res <- geo_atom_parse(res, list, clean_tags, parse_dates)
  } else if (typ == "json") {
    res <- geo_json_parse(res, feed, list, clean_tags, parse_dates)
  } else {
    stop(error_msg)
  }
  # geojson is already sf-ified
  # atom & rss need it here
  return(res)
}
