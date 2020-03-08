# default value for empty elements
def <- NA_character_
# stop() message
msg <- "This does not appear to be a valid *geo* feed. 
  Please check the feed or open an issue at:
  https://github.com/RobertMyles/tidygeoRSS/issues"
# error message
error_msg <- "Error in feed parse; please check URL.\n
  If you're certain that this is a valid rss feed,
  please file an issue at https://github.com/RobertMyles/tidygeoRSS/issues.
  Please note that the feed may also be undergoing maintenance."
# clean HTML tags
# from https://stackoverflow.com/a/17227415/4296028
# removal != parsing!
cleanFun <- function(htmlString) {
  return(gsub("<.*?>", "", htmlString))
}
# check for multiple elements, reduce and check if !NA for map_if
check_p <- function(x) {
  z <- unique(x)
  if (length(z) > 1) {
    ret <- all(!is.na(z))
  } else {
    ret <- !is.na(z)
  }
  ret
}
# delist list-columns of one element
delist <- function(x) {
  safe_compact <- safely(compact)
  y <- safe_compact(x)
  if (is.null(y$error)) z <- y$result else z <- NA
  if (length(z) == 0) z <- NA_character_
  z
}

# parse dates
date_parser <- function(df, kol) {
  column <- enquo(kol) %>% as_name()
  if (has_name(df, column)) {
    df <- df %>% mutate({{ kol }} := anytime({{ kol }}))
  }
  df
}
# check if JSON or XML
# simply reads 'content-type' of response to check type.
# if contains both atom & rss, prefers rss
type_check <- function(response) {
  content_type <- response$headers$`content-type`
  typ <- case_when(
    grepl(x = content_type, pattern = "atom") ~ "atom",
    grepl(x = content_type, pattern = "xml") ~ "rss",
    grepl(x = content_type, pattern = "rss") ~ "rss",
    grepl(x = content_type, pattern = "json") ~ "json",
    TRUE ~ "unknown"
  )
  return(typ)
}
# set user agent
set_user <- function(config) {
  if (length(config) == 0 | length(config$options$`user-agent`) == 0) {
    ua <- user_agent("http://github.com/robertmyles/tidyRSS")
    return(ua)
  } else {
    return(config)
  }
}

# check these are 'geo' feeds
geocheck <- function(x) {
  point <- xml_find_all(x, "//*[name()='georss:point']") %>% length()
  line <- xml_find_all(x, "//*[name()='georss:line']") %>% length()
  polygon <- xml_find_all(x, "//*[name()='georss:polygon']") %>% length()
  box <- xml_find_all(x, "//*[name()='georss:box']") %>% length()
  f_type <- xml_find_all(x, "//*[name()='georss:featuretypetag']") %>% length()
  r_tag <- xml_find_all(x, "//*[name()='georss:relationshiptag']") %>% length()
  f_name <- xml_find_all(x, "//*[name()='georss:featurename']") %>% length()
  geo_elements <- c(point, line, polygon, box, f_type, r_tag, f_name)
  
  if (all(geo_elements < 1)) {
    message("This feed does not appear to contain geographic information. 
If you are sure that it is a 'geo' type feed, please open an issue at:
https://github.com/RobertMyles/tidygeoRSS/issues")
  } else {
    return(TRUE)
  }
}
