#' Get SoFIFA IDs for leagues, teams, or players.
#'
#' @param league_id Numeric ID obtained via \code{get_leagues()}.
#' @param team_id Numeric ID obtained via \code{get_teams()}.
#' @return \code{leagues}, \code{teams}, \code{players},
#'   a data frame.
#' @examples
#' # get all available leagues
#' leagues <- get_leagues()
#'
#' # get all Premier League teams
#' teams <- get_teams(13)
#'
#' # get all Tottenham Hotspur players
#' players <- get_players(18)
#' @name get_players
#' @export
get_leagues <- function() {
  # build url
  url <- paste0(base_url, "/leagues")
  # read html page (overview)
  html <- xml2::read_html(GET_stealthy(url))
  # extract league links
  tmp <- xml2::xml_find_all(html, xpath = "//a[contains(@href,'/league/')]")
  # prepare empty data frame
  leagues <- data.frame(league_id = rep(0, length(tmp)), league_name = NA)
  # extract league IDs from links
  leagues$league_id <- tmp %>%
    rvest::html_attr("href") %>%
    stringr::str_replace("/league/", "") %>%
    as.numeric()
  # extract league names from links
  leagues$league_name <- rvest::html_text(tmp)
  # return data frame
  leagues
}

#' @rdname get_players
#' @export
get_teams <- function(league_id) {
  # build url
  url <- paste0(base_url, "/teams?lg=", league_id)
  # read html page (league overview)
  html <- xml2::read_html(GET_stealthy(url))
  # extract team links
  tmp <- xml2::xml_find_all(html, xpath = "//a[contains(@href,'/team/')]")
  # prepare empty data frame
  teams <- data.frame(team_id = rep(0, length(tmp)), team_name = NA)
  # extract team IDs from links
  teams$team_id <- tmp %>%
    rvest::html_attr("href") %>%
    stringr::str_replace("/team/", "") %>%
    as.numeric()
  # extract team names from links
  teams$team_name <- rvest::html_text(tmp)
  # return data frame
  teams
}

#' @rdname get_players
#' @export
get_players <- function(team_id) {
  # build url
  url <- paste0(base_url, "/team/", team_id)
  # read html page (team overview)
  html <- xml2::read_html(GET_stealthy(url))
  # extract player links
  tmp <- xml2::xml_find_all(html, xpath = "//a[contains(@href,'/player/')]")
  # prepare empty data frame
  players <- data.frame(player_id = rep(0, length(tmp)), player_name = NA)
  # extract player IDs from links
  players$player_id <- tmp %>%
    rvest::html_attr("href") %>%
    stringr::str_replace("/player/", "") %>%
    as.numeric()
  # extract player names from links
  players$player_name <- rvest::html_attr(tmp, "title")
  # return data frame with distinct entries (removing duplicates)
  dplyr::distinct(players)
}

get_scores <- function(player_id) {
  # build url
  url <- paste0(base_url, "/player/", player_id)
  # read html page (player profile)
  html <- xml2::read_html(GET_stealthy(url))
  # prepare vector with pre-defined score labels
  scores <- rep(0, length(score_labels))
  # extract scores one-by-one
  for (s in 1:length(scores)) {
    # extract score via label matching
    tmp <- html %>%
      rvest::html_nodes(xpath = paste0("//*[not(self::script)][text()[contains(.,'",
                                       score_labels[s], "')]]")) %>%
      rvest::html_children()
    if (length(tmp) >= 1) {
      # for multiple matches, only accept first match
      scores[s] <- tmp[1] %>%
        rvest::html_text() %>%
        as.numeric()
    } else {
      # if there's no match, put NA
      scores[s] <- NA
    }
  }
  # store scores in data frame
  scores <- as.data.frame(t(scores))
  # use score lables as column names
  colnames(scores) <- score_labels
  # return data frame
  scores
}

# define base url
base_url <- "https://sofifa.com"

# define labels to use for score extraction from player profile pages
score_labels <- c("Overall Rating", "Potential",
                  "Crossing", "Finishing", "Heading Accuracy", "Short Passing", "Volleys",
                  "Dribbling", "Curve", "FK Accuracy", "Long Passing", "Ball Control",
                  "Acceleration", "Sprint Speed", "Agility", "Reactions", "Balance",
                  "Shot Power", "Jumping", "Stamina", "Strength", "Long Shots",
                  "Aggression", "Interceptions", "Positioning", "Vision", "Penalties", "Composure",
                  "Marking", "Standing Tackle", "Sliding Tackle",
                  "GK Diving", "GK Handling", "GK Kicking", "GK Positioning", "GK Reflexes")
