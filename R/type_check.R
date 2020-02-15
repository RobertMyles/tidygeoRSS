# check if JSON or XML
# simply reads 'content-type' of response to check type.
type_check <- function(response) {
  content_type <- response$headers$`content-type`
  typ <- case_when(
    grepl(x = content_type, pattern = "application/atom") ~ "atom",
    grepl(x = content_type, pattern = "application/xml") ~ "rss",
    grepl(x = content_type, pattern = "application/json") ~ "json",
    TRUE ~ "unknown"
  )
  return(typ)
}
