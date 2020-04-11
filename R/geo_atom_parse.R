geo_atom_parse <- function(response, list, clean_tags, parse_dates) {
  parsed <- suppressMessages(atom_parse(response, list = TRUE, clean_tags, parse_dates))
  entries <- parsed$entries
  res <- read_xml(response)
  res_entry <- xml_find_all(res, "//*[name()='entry']")

  if (geocheck(res)) {
    entries <- entries %>%
      mutate(
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

    meta <- parsed$meta
    meta <- clean_up(meta, "atom", clean_tags, parse_dates)
    entries <- clean_up(entries, "atom", clean_tags, parse_dates) %>%
      st_as_sf()

    if (isTRUE(list)) {
      result <- list(meta = meta, entries = entries)
      return(result)
    } else {
      if (!has_name(meta, "feed_title")) {
        meta$feed_title <- NA_character_ # nocov
      }
      entries$feed_title <- meta$feed_title
      out <- suppressMessages(safe_join(meta, entries))
      if (is.null(out$error)) {
        out <- out$result
        if (all(is.na(out$feed_title))) out <- out %>% select(-feed_title) # nocov
        return(out)
      }
    }
  } else {
    stop(msg)
  }
}
