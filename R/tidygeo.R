#' @importFrom xml2 xml_contents as_list xml_find_all read_xml xml_text
#' @importFrom xml2 xml_attr xml_find_first xml_type read_html
#' @importFrom dplyr full_join tibble select case_when bind_cols mutate
#' @importFrom dplyr select_if
#' @importFrom purrr map safely compact map_if
#' @importFrom lubridate parse_date_time
#' @importFrom stringr str_extract
#' @importFrom strex str_before_first str_after_first
#' @importFrom httr GET user_agent
#' @importFrom sf read_sf st_point st_linestring st_polygon st_bbox
#' @importFrom jsonlite parse_json
#' @importFrom rvest html_text
#' @importFrom magrittr "%>%"
#' @param clean_tags default \code{TRUE}. Clean HTML tags from summary and content?
#' @param list default \code{FALSE}. Return metadata and entry information in separate dataframes?
#' These will be combined in a list.
#' @export
tidygeo <- function(feed, config = list(), clean_tags = TRUE, list = FALSE) {
  # checks
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
    res <- geo_rss_parse(res, feed, clean_tags)
  } else if (typ == "atom") {
    res <- geo_atom_parse(res, feed, clean_tags)
  } else if (typ == "json") {
    res <- geo_json_parse(res, feed, clean_tags)
  } else {
    # TODO
    stop("")
  }
  # parse dates?
  # clean content?
  # sf install instructions
  # remove lubridate?
  return(res)
}
