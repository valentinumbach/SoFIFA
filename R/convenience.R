#' Get SoFIFA scores for players, teams, or complete leagues.
#'
#' @param player_ids Numeric (vector of) ID(s) obtained via \code{get_players()}.
#' @param team_id Numeric ID obtained via \code{get_teams()}.
#' @param league_id Numeric ID obtained via \code{get_leagues()}.
#' @param max_results Numeric maximum results returned. Defaults to \code{Inf}.
#' @return \code{player_scores}, \code{team_scores}, \code{league_scores},
#'   a data frame.
#' @examples
#' # get scores for Harry Kane
#' player_scores <- get_player_scores(202126)
#'
#' # get scores for Harry Kane and Dele Alli
#' player_scores <- get_player_scores(c(202126, 211117))
#'
#' # get scores for all Tottenham Hotspur players
#' team_scores <- get_team_scores(18, max_results = 5)
#'
#' # get scores for all Premier League players
#' league_scores <- get_league_scores(13, max_results = 5)
#' @export
get_player_scores <- function(player_ids, version=NULL, exportdate=NULL) {
  get_scores_progress <- function(progress, ...) {
    message("Fetching player ", progress, " / ", length(player_ids))
    get_scores(...)
  }
  i <- 1:length(player_ids)
  if (!is.null(version) && !is.null(exportdate)) {
    do.call(rbind, mapply(get_scores_progress, i, player_ids, version, exportdate, SIMPLIFY = FALSE))
  }
  else {
    do.call(rbind, mapply(get_scores_progress, i, player_ids, SIMPLIFY = FALSE))
  }
}

#' @rdname get_player_scores
#' @export
get_player_history <- function(player_ids) {
  do.call(rbind, lapply(player_ids, function(pid) {
    # build required http header
    referer <- paste0(base_url, "/player/", pid)
    # build url
    url <- paste0(base_url, "/ajax.php?action=history&type=player&id=", pid)
    # make request and parse result
    r <- GET_stealthy(url, Referer = referer, 'X-Requested-With' = 'XMLHttpRequest')
    versions <- jsonlite::fromJSON(httr::content(r, as = "text"))$versions
    # note that SoFIFA uses a non-iso date format. E.g: Sep 4, 2008
    # we will parse the dates automatically for the user
    versions$date <- as.Date(versions$date, format=sofifa_date_fmt)
    # add player_ids column and return
    versions$player_ids = rep(pid, nrow(versions))
    versions
  }))
}

#' @rdname get_player_scores
#' @export
get_team_players <- function(team_ids, include.onloan = FALSE) {
  do.call(rbind, mapply(function(tid, i) {
    message("Fetching team ", i, " / ", length(team_ids))
    # build url
    url <- paste0(base_url, "/team/", tid)
    # read html page (team overview)
    html <- xml2::read_html(GET_stealthy(url))
    # extract player names and ids from links
    nodes <- rvest::html_nodes(html, xpath = '//article//h5[text()="Squad"]/../table//a[contains(@href,"/player/")]')

    get_player_ids <- function(nodes) gsub("/player/([0-9]+).*", "\\1", rvest::html_attr(nodes, "href")) %>%
                                      as.numeric()

    get_player_names <- function(nodes) rvest::html_attr(nodes, "title")

    player_ids <- get_player_ids(nodes)
    player_names <- get_player_names(nodes)
    # we use rep explicitly because length(team_ids) may be 0
    tids <- rep(tid, length(player_ids))

    if (include.onloan) {
      # note that we also get the data of the team loaned to
      table        <- rvest::html_nodes(html,  xpath = '//article//h5[text()="On Loan"]/../table')
      player_nodes <- rvest::html_nodes(table, xpath = './/tbody//a[contains(@href,"/player/")]')
      team_nodes   <- rvest::html_nodes(table, xpath = './/tbody//a[contains(@href,"/team/")]')
      print(player_nodes)
      print(team_nodes)

      player_ids <- c(player_ids, get_player_ids(player_nodes))
      player_names <- c(player_names, get_player_names(player_nodes))
      tids <- c(tids, gsub("/team/([0-9]+).*", "\\1", rvest::html_attr(team_nodes, "href")) %>%
                      as.numeric())
    }
    data.frame(team_id=tids, player_id=player_ids, player_name=player_names)
  }, team_ids, 1:length(team_ids), SIMPLIFY = FALSE))
}

#' @rdname get_players
#' @export
get_league_teams <- function(league_ids) {
  do.call(rbind, lapply(league_ids, function(lid) {
    # build url
    url <- paste0(base_url, "/teams?lg=", lid)
    # read html page (league overview)
    html <- xml2::read_html(GET_stealthy(url))
    # extract team names and ids from links
    nodes <- rvest::html_nodes(html, xpath = "//article//a[contains(@href,'/team/')]")
    team_ids <- gsub("/team/([0-9]+).*", "\\1", rvest::html_attr(nodes, "href")) %>% as.numeric()
    team_names <- nodes %>% rvest::html_text()
    # we use rep explicitly because length(team_ids) may be 0
    lid <- rep(lid, length(team_ids))
    data.frame(league_id=lid, team_id=team_ids, team_name=team_names)
  }))
}
