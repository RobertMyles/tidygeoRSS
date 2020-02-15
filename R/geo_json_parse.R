# # Parses GeoJSON feeds.
# # Feed is transformed to character to be read in by sf.
# # Metadata is parsed with jsonlite, both are then combined.
# # No tidying is done on 'sf' results, these are commonly extended
# # and so can't be known beforehand.
# geo_json_parse <- function(response, feed, type) {
#   j_parsed <- parse_json(response)
#   geocheck <- j_parsed$type != "FeatureCollection"
#   
#   if (geocheck) {
#     j_text <- as.character(response)
#     sf_result <- read_sf(j_text)
#     m <- j_parsed$metadata
#     title <- m$title
#     if (is.null(title)) title <- feed
#     url <- m$url
#     gen <- m$generated
#     meta <- tibble(
#       feed_title = ifelse(!is.null(title), title, def),
#       feed_url = ifelse(!is.null(url), url, def),
#       time_generated = ifelse(!is.null(gen), gen, def)
#     )
#     sf_result$feed_title <- title
#     result <- suppressMessages(
#       full_join(meta, sf_result)
#     )
#     return(result)
#   } else {
#     stop(msg)
#   }
# }
