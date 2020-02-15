# default value for empty elements
def <- NA_character_
# stop() message
msg <- "This does not appear to be a valid *geo* feed. 
  Please check the feed or open an issue at:
  https://github.com/RobertMyles/tidygeoRSS/issues"
# clean HTML tags
# adapted from https://stackoverflow.com/a/17227415/4296028
rmtags <- function(html) {
  return(gsub("<.*?>", " ", html))
}
# safer: https://stackoverflow.com/a/34344957/4296028
strip_html <- function(s) {
  html_text(read_html(s))
}
