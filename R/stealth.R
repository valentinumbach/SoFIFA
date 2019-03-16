GET_stealthy <- function(url) {
  if (is.null(stealth.env$proxy)) {
    stealth.env$proxy <- get_proxy()
  }
  if (is.null(stealth.env$useragent)) {
    stealth.env$useragent <- get_useragent()
  }
  r <- try(httr::GET(url,
                     httr::use_proxy(stealth.env$proxy$ip,
                                     stealth.env$proxy$port),
                     httr::user_agent(stealth.env$useragent)),
           silent = TRUE)
  while (is_error(r)) {
    Sys.sleep(1)
    stealth.env$proxy <- get_proxy()
    stealth.env$useragent <- get_useragent()
    r <- try(httr::GET(url,
                       httr::use_proxy(stealth.env$proxy$ip,
                                       stealth.env$proxy$port),
                       httr::user_agent(stealth.env$useragent)),
             silent = TRUE)
  }
  return(r)
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
    stealth.env$useragent_list <- c(
      'Mozilla/5.0 (X11; Linux x86_64; rv:65.0) Gecko/20100101 Firefox/65.0',
      'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/73.0.3683.75 Safari/537.36'
    )
  }
  sample(stealth.env$useragent_list, 1)
}

stealth.env <- new.env()
stealth.env$proxy_list <- NULL
stealth.env$useragent_list <- NULL
stealth.env$proxy <- NULL
stealth.env$useragent <- NULL
