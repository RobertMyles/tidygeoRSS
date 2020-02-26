geo_rss_parse <- function(response, list, clean_tags) {
  res <- response %>% read_xml()
  geocheck <- grepl(
    "http://www.georss.org/georss",
    xml_attr(res, "xmlns:georss")
  )
  if (isTRUE(geocheck)) {
    channel <- xml_find_first(res, "//*[name()='channel']")
    # meta data. Necessary: title, link, description
    metadata <- tibble(
      feed_title = xml_find_first(channel, "//*[name()='title']") %>% xml_text(),
      feed_link = xml_find_first(channel, "//*[name()='link']") %>% xml_text(),
      feed_description = xml_find_first(channel, "//*[name()='description']") %>%
        xml_text()
    )
    # optional metadata: language, copyright, managingEditor, webMaster, pubDate,
    # lastBuildDate; category, generator, docs, cloud, ttl, image, textInput,
    # skipHours, skipDays
    meta_optional <- tibble(
      feed_language = safe_run(channel, "first", "//*[name()='language']"),
      feed_managing_editor = safe_run(
        channel,
        "first", "//*[name()='managingEditor']"
      ),
      feed_web_master = safe_run(channel, "first", "//*[name()='webMaster']"),
      feed_pub_date = safe_run(channel, "first", "//*[name()='pubDate']"),
      feed_last_build_date = safe_run(
        channel,
        "first", "//*[name()='lastBuildDate']"
      ),
      feed_category = list(category = safe_run(
        channel, "first", "//*[name()='category']"
      )),
      feed_generator = safe_run(channel, "first", "//*[name()='generator']"),
      feed_docs = safe_run(channel, "first", "//*[name()='docs']"),
      feed_ttl = safe_run(channel, "first", "//*[name()='ttl']")
    )
    meta <- bind_cols(metadata, meta_optional)

    # entries
    # necessary: title or description
    res_entry <- xml_find_all(channel, "//*[name()='item']") %>% as_list()
    res_entry_xml <- xml_find_all(channel, "//*[name()='item']")

    entries <- tibble(
      item_title = map(res_entry, "title", .default = def) %>% unlist(),
      item_link = map(res_entry, "link", .default = def) %>% unlist(),
      item_description = map(res_entry, "description", .default = def) %>%
        unlist(),
      item_pub_date = map(res_entry, "pubDate", .default = def) %>% unlist(),
      item_guid = map(res_entry, "guid", .default = def) %>% unlist(),
      item_author = map(res_entry, "author", .default = def),
      item_category = map(res_entry_xml, ~ {
        xml_find_all(.x, "category") %>% map(xml_text)
      }),
      item_comments = map(res_entry, "comments", .default = def) %>% unlist()
    ) %>%
      # add geo information
      mutate(
        item_latlon = safe_run(
          res_entry_xml, "all", "//*[name()='georss:point']"
        ) %>%
          map_if(
            .p = ~ {
              !is.na(.x)
            },
            ~ {
              # take out elements of character vector, join together
              # transform into POINT
              x1 <- str_before_first(.x, " ") %>% as.numeric()
              x2 <- str_after_first(.x, " ") %>% as.numeric()
              x <- c(x1, x2)
              x
            }
          ) %>%
          map_if(.p = ~ {
            check_p(.x)
          }, st_point),
        item_line = safe_run(res_entry_xml, "all", "//*[name()='georss:line']") %>%
          map_if(.p = ~ {
            !is.na(.x)
          }, ~ {
            # count how many elements, create matrix of (elements/2)*2
            # place pairs in matrix
            # matrix becomes LINESTRING
            wspaces <- stringr::str_count(.x, " ") + 1
            w_len <- wspaces / 2
            geomatrix <- matrix(nrow = wspaces / 2, ncol = 2)
            for (i in 1:w_len) {
              geomatrix[i, 1] <- str_before_first(.x, " ") %>% as.numeric()
              .x <- str_after_first(.x, " ")
              if (i < w_len) {
                geomatrix[i, 2] <- str_before_first(.x, " ") %>% as.numeric()
                .x <- str_after_first(.x, " ")
              } else {
                geomatrix[i, 2] <- .x %>% as.numeric()
              }
            }
            geomatrix
          }) %>%
          map_if(.p = ~ {
            check_p(.x)
          }, st_linestring),
        item_pgon = safe_run(
          res_entry_xml, "all", "//*[name()='georss:ploygon']"
        ) %>%
          map_if(.p = ~ {
            !is.na(.x)
          }, ~ {
            # same as LINETSRING, except input is list
            wspaces <- stringr::str_count(.x, " ") + 1
            w_len <- wspaces / 2
            geomatrix <- matrix(nrow = wspaces / 2, ncol = 2)
            for (i in 1:w_len) {
              geomatrix[i, 1] <- str_before_first(.x, " ") %>% as.numeric()
              .x <- str_after_first(.x, " ")
              if (i < w_len) {
                geomatrix[i, 2] <- str_before_first(.x, " ") %>% as.numeric()
                .x <- str_after_first(.x, " ")
              } else {
                geomatrix[i, 2] <- .x %>% as.numeric()
              }
            }
            list(geomatrix)
          }) %>%
          map_if(.p = ~ {
            check_p(.x)
          }, st_polygon),
        item_bbox = safe_run(res_entry_xml, "all", "//*[name()='georss:box']") %>%
          map_if(.p = ~ {
            !is.na(.x)
          }, ~ {
            # get first pair, create POINT
            b1 <- str_before_first(y, " ") %>% as.numeric()
            b2 <- str_after_first(y, " ") %>%
              str_before_first(" ") %>%
              as.numeric()
            b12 <- c(b1, b2) %>% st_point()
            # second pair
            b3 <- str_after_nth(y, " ", 2) %>%
              str_before_first(" ") %>%
              as.numeric()
            b4 <- str_after_nth(y, " ", 3) %>% as.numeric()
            b34 <- c(b3, b4) %>% st_point()
            # join and make BBOX
            x <- c(b12, b34)
            x
          }) %>%
          map_if(.p = ~ {
            check_p(.x)
          }, st_bbox),
        item_elev = safe_run(res_entry_xml, "all", "//*[name()='georss:elev']") %>%
          as.numeric(),
        item_floor = safe_run(res_entry_xml, "all", "//*[name()='georss:floor']") %>%
          as.numeric(),
        item_radius = safe_run(
          res_entry_xml, "all", "//*[name()='georss:radius']"
        ) %>% as.numeric()
      )
    
    # clean up
    meta <- clean_up(meta, "rss", clean_tags)
    entries <- clean_up(entries, "rss", clean_tags)
    
    if (isTRUE(list)) {
      result <- list(meta = meta, entries = entries)
    } else {
      entries$feed_title <- meta$feed_title
      result <- suppressMessages(
        full_join(meta, entries)
      )
    }
    return(result)
  } else {
    stop(msg)
  }
}
