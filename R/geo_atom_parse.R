geo_atom_parse <- function(response, feed, clean_tags) {
  res <- read_xml(response)
  geocheck <- grepl("http://www.georss.org/georss", 
                    xml_attr(res, "xmlns:georss"))
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
    meta_optional = tibble(
      feed_author = safe_run(res, "first", "//*[name()='author']"),
      feed_link = ifelse(!is.null(link), link, def),
      feed_category = list(safe_run(res, "first", "//*[name()='category']")),
      feed_icon = safe_run(res, "first", "//*[name()='icon']")
    )
    meta <- bind_cols(metadata, meta_optional)
    # entries
    # necessary: id, title, updated
    res_entry <- xml_find_all(res, "//*[name()='entry']")
    # likely to be CDATA: summary, content
    # check for CDATA
    cdsummary <- res_entry %>% 
      xml_find_all("//*[name()='summary']") %>% 
      xml_contents() %>% 
      xml_type()
    cdcontent <- res_entry %>% 
      xml_find_all("//*[name()='content']") %>% 
      xml_contents() %>% 
      xml_type()
    
    e_link <- xml_find_first(res_entry, "//*[name()='link']") %>% xml_attr("href")
    
    entries <- tibble(
      entry_title = xml_find_first(res_entry, "//*[name()='title']") %>% xml_text(),
      entry_url = xml_find_first(res_entry, "//*[name()='id']") %>% xml_text(),
      entry_last_updated = xml_find_first(res_entry, "//*[name()='updated']") %>% xml_text(),
      entry_author = safe_run(res_entry, "all", "//*[name()='author']"),
      entry_content = safe_run(res_entry, "all", "//*[name()='content']"),
      entry_link = ifelse(!is.null(e_link), e_link, def),
      entry_summary = safe_run(res_entry, "all", "//*[name()='summary']"),
      entry_category = list(NA),
      entry_latlon = safe_run(res_entry, "all", "//*[name()='georss:point']") %>% 
        map_if(.p = ~{!is.na(.x)}, ~{
          x1 <- str_before_first(.x, " ") %>% as.numeric()
          x2 <- str_after_first(.x, " ") %>% as.numeric()
          x <- c(x1, x2)
          x
        }) %>% map_if(.p = ~{
          check_p(.x)
          }, st_point),
      entry_line = safe_run(res_entry, "all", "//*[name()='georss:line']") %>% 
        map_if(.p = ~{!is.na(.x)}, ~{
          wspaces <- stringr::str_count(.x, " ") + 1
          w_len <- wspaces/2
          geomatrix <- matrix(nrow = wspaces/2, ncol = 2)
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
        }) %>% map_if(.p = ~{
          check_p(.x)
          }, st_linestring),
      entry_pgon = safe_run(res_entry, "all", "//*[name()='georss:ploygon']"),
      entry_bbox = safe_run(res_entry, "all", "//*[name()='georss:box']"),
      entry_elev = safe_run(res_entry, "all", "//*[name()='georss:elev']"),
      entry_floor = safe_run(res_entry, "all", "//*[name()='georss:floor']"),
      entry_radius = safe_run(res_entry, "all", "//*[name()='georss:radius']")
      ) 
    
    for (i in 1:length(res_entry)) {
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
    
    if (clean_tags) {
      entries <- entries %>% 
        mutate(
          entry_summary = ifelse(!is.na(entry_summary), 
                                 strip_html(entry_summary),
                                 entry_summary),
          entry_content = ifelse(!is.na(entry_content),
                                 strip_html(entry_content),
                                 entry_content)
        )
    }
    
    return(entries)
  } else {
    stop(msg)
  }
}
