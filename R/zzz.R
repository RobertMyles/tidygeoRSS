# nocov start
.onLoad <- function(libname = find.package("tidyRSS"), pkgname = "tidyRSS") {
  # CRAN Note avoidance
  if (getRversion() >= "2.15.1") {
    utils::globalVariables(c(
      ".", ":=", "entry_last_updated", "entry_published", "feed_last_build_date",
      "feed_last_updated", "feed_pub_date", "feed_title", "item_content_html",
      "item_date_modified", "item_date_published", "item_pub_date", "last_updated", "tmp"
    ))
  }
  invisible()
}
# nocov end