GET_stealthy <- function(url, ...) {
  if (is.null(stealth.env$proxy)) {
    stealth.env$proxy <- get_proxy()
  }
  if (is.null(stealth.env$useragent)) {
    stealth.env$useragent <- get_useragent()
  }
  while (TRUE) {
    r <- try(httr::GET(url,
                       httr::use_proxy(stealth.env$proxy$ip,
                                       stealth.env$proxy$port),
                       httr::user_agent(stealth.env$useragent),
                       httr::add_headers(...)),
             silent = TRUE)
    if (is_error(r)) {
      Sys.sleep(1)
      stealth.env$proxy <- get_proxy()
      stealth.env$useragent <- get_useragent()
    }
    else {
      return(r)
    }
  }
}

get_proxy <- function() {
  if (is.null(stealth.env$proxy_list)) {
    r <- httr::GET("https://raw.githubusercontent.com/clarketm/proxy-list/master/proxy-list.txt")
    c <- httr::content(r)
    s <- strsplit(c, "\n")[[1]]
    s <- s[5:(length(s) - 2)]
    ip <- gsub("(.*?)(:.*)", "\\1", s)
    port <- gsub(".*:(.*?)\\s.*", "\\1", s)
    https <- grepl("-S", s)
    ip <- ip[https == TRUE]
    port <- as.numeric(port[https == TRUE])
    stealth.env$proxy_list <- list(ip = ip, port = port)
  }
  d <- sample(1:length(stealth.env$proxy_list$ip), 1)
  list(ip = stealth.env$proxy_list$ip[d], port = stealth.env$proxy_list$port[d])
}


get_useragent <- function() {
  if (is.null(stealth.env$useragent_list)) {
    r <- httr::GET("https://raw.githubusercontent.com/debbbbie/useragents-rb/master/lib/useragents.txt")
    c <- httr::content(r)
    s <- strsplit(c, "\n")[[1]]
    stealth.env$useragent_list <- s
  }
  sample(stealth.env$useragent_list, 1)
}

stealth.env <- new.env()
stealth.env$proxy_list <- NULL
stealth.env$useragent_list <- NULL
stealth.env$proxy <- NULL
stealth.env$useragent <- NULL
