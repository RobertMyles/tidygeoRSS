# default value for empty elements
def <- NA_character_
# stop() message
msg <- "This does not appear to be a valid *geo* feed. 
  Please check the feed or open an issue at:
  https://github.com/RobertMyles/tidygeoRSS/issues"
# clean HTML tags
# from: https://stackoverflow.com/a/34344957/4296028
strip_html <- function(s) {
  html_text(read_html(s))
}
# remove all NA columns
no_na <- function(x) all(!is.na(x))
# remove nchar < 1 columns
no_empty_char <- function(x) all(!nchar(x) < 1)
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
