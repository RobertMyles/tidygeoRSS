# set user agent
set_user <- function(config) {
  if (length(config) == 0 | length(config$options$`user-agent`) == 0) {
    ua <- user_agent("http://github.com/robertmyles/tidyRSS")
    return(ua)
  } else {
    return(config)
  }
}
