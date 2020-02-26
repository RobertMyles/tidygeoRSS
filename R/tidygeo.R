#' @title Extract a tidy data frame from geoRSS, geo-Atom and geoJSON feeds
#' @importFrom xml2 xml_contents as_list xml_find_all read_xml xml_text
#' @importFrom xml2 xml_attr xml_find_first xml_type read_html
#' @importFrom dplyr full_join tibble select case_when bind_cols mutate
#' @importFrom dplyr select_if  mutate_if
#' @importFrom purrr map safely compact map_if keep map_df
#' @importFrom anytime anytime
#' @importFrom stringr str_extract
#' @importFrom strex str_before_first str_after_first
#' @importFrom httr GET user_agent
#' @importFrom sf read_sf st_point st_linestring st_polygon st_bbox
#' @importFrom jsonlite parse_json
#' @importFrom rlang has_name as_name enquo
#' @importFrom magrittr "%>%"
#' @import tidyRSS 
#' @param clean_tags default \code{TRUE}. Clean HTML tags from summary and content?
#' @param list default \code{FALSE}. Return metadata and entry information in separate dataframes?
#' These will be combined in a named list.
#' @export
tidygeo <- function(feed, config = list(), clean_tags = TRUE, list = FALSE) {
  # checks
  stopifnot(identical(length(feed), 1L))
  if (!clean_tags %in% c(TRUE, FALSE)) {
    stop("`clean_tags` may be TRUE or FALSE only.")
  }
  # send user agent
  ua <- set_user(config)
  # try to get response
  res <- safe_get(feed, config = ua)
  # check type
  typ <- type_check(res)
  # send to parsers
  if (typ == "rss") {
    res <- geo_rss_parse(res, list, clean_tags)
  } else if (typ == "atom") {
    res <- geo_atom_parse(res, list, clean_tags)
  } else if (typ == "json") {
    res <- geo_json_parse(res, feed, list, clean_tags)
  } else {
    stop(error_msg)
  }
  # geojson is already sf-ified
  # atom & rss need it here
  return(res)
}
