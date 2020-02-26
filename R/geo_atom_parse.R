geo_atom_parse <- function(response, list, clean_tags) {
  res <- read_xml(response)
  geocheck <- grepl(
    "http://www.georss.org/georss",
    xml_attr(res, "xmlns:georss")
  )
  if (geocheck) {
    # parse
    # check Atom spec
    # metadata: id, title, updated necessary
    metadata <- tibble(
      feed_title = xml_find_first(res, "//*[name()='title']") %>% xml_text(),
      feed_url = xml_find_first(res, "//*[name()='id']") %>% xml_text(),
      last_updated = xml_find_first(res, "//*[name()='updated']") %>% xml_text()
    )
    # optional: author, link, category, contributor, generator, icon, logo,
    # rights, subtitle
    link <- xml_find_first(res, "//*[name()='link']") %>% xml_attr("href")
    meta_optional <- tibble(
      feed_author = safe_run(res, "first", "//*[name()='author']"),
      feed_link = ifelse(!is.null(link), link, def),
      feed_category = list(safe_run(res, "first", "//*[name()='category']")),
      feed_icon = safe_run(res, "first", "//*[name()='icon']")
    )
    meta <- bind_cols(metadata, meta_optional)
    # entries
    # necessary: id, title, updated
    res_entry <- xml_find_all(res, "//*[name()='entry']")
    e_link <- xml_find_first(res_entry, "//*[name()='link']") %>%
      xml_attr("href")

    entries <- tibble(
      entry_title = xml_find_first(res_entry, "//*[name()='title']") %>%
        xml_text(),
      entry_url = xml_find_first(res_entry, "//*[name()='id']") %>%
        xml_text(),
      entry_last_updated = xml_find_first(
        res_entry, "//*[name()='updated']"
      ) %>%
        xml_text(),
      entry_author = safe_run(res_entry, "all", "//*[name()='author']"),
      entry_content = safe_run(res_entry, "all", "//*[name()='content']"),
      entry_link = ifelse(!is.null(e_link), e_link, def),
      entry_summary = safe_run(res_entry, "all", "//*[name()='summary']"),
      entry_category = list(NA),
      entry_published = safe_run(res_entry, "all", "//*[name()='published']"),
      entry_rights = safe_run(res_entry, "all", "//*[name()='rights']"),
      entry_latlon = safe_run(
        res_entry, "all", "//*[name()='georss:point']"
      ) %>%
        map_if(.p = ~ {
          !is.na(.x)
        }, ~ {
          # take out elements of character vector, join together
          # transform into POINT
          x1 <- str_before_first(.x, " ") %>% as.numeric()
          x2 <- str_after_first(.x, " ") %>% as.numeric()
          x <- c(x1, x2)
          x
        }) %>%
        map_if(.p = ~ {
          check_p(.x)
        }, st_point),
      entry_line = safe_run(res_entry, "all", "//*[name()='georss:line']") %>%
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
      entry_pgon = safe_run(
        res_entry, "all", "//*[name()='georss:ploygon']"
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
      entry_bbox = safe_run(res_entry, "all", "//*[name()='georss:box']") %>%
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
      entry_elev = safe_run(res_entry, "all", "//*[name()='georss:elev']") %>%
        as.numeric(),
      entry_floor = safe_run(res_entry, "all", "//*[name()='georss:floor']") %>%
        as.numeric(),
      entry_radius = safe_run(
        res_entry, "all", "//*[name()='georss:radius']"
      ) %>% as.numeric()
    )
    # categories are stored as attributes of xml nodes:
    for (i in seq_len(length(res_entry))) {
      entries$entry_category[[i]] <- res_entry[[i]] %>%
        xml_contents() %>%
        as_list() %>%
        map(attributes) %>%
        map("term") %>%
        compact()
      names(entries$entry_category[[i]]) <- res_entry[[i]] %>%
        xml_contents() %>%
        as_list() %>%
        map(attributes) %>%
        map("label") %>%
        compact()
    }
    
    meta <- clean_up(meta, "atom", clean_tags)
    entries <- clean_up(entries, "atom", clean_tags)

    if (isTRUE(list)) {
      result <- list(meta = meta, entries = entries)
    } else {
      entries$feed_title <- meta$feed_title
      result <- suppressMessages(full_join(meta, entries))
    }
    return(result)
  } else {
    stop(msg)
  }
}
