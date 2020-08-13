#' Get SoFIFA IDs for leagues, teams, or players.
#'
#' @param league_id Numeric ID obtained via \code{get_leagues()}.
#' @param team_id Numeric ID obtained via \code{get_teams()}.
#' @param include_on_loan Logical indicating if players actually on loan should
#'   be included. Defaults to TRUE.
#' @return \code{leagues}, \code{teams}, \code{players},
#'   a data frame.
#' @examples
#' \dontrun{
#' # get all available leagues
#' leagues <- get_leagues()
#'
#' # get all Premier League teams
#' teams <- get_teams(13)
#'
#' # get all Tottenham Hotspur players
#' players <- get_players(18)
#' }
#' @name get_players
#' @export
get_leagues <- function() {
  # build url
  url <- paste0(base_url, "/leagues")
  # read html page (overview)
  html <- xml2::read_html(GET_stealthy(url))
  # get the leagues table
  table <- rvest::html_node(html, ".table-hover") %>%
    rvest::html_node("tbody") %>%
    rvest::html_nodes("tr")
  # for each row get league ID, name, and number of teams
  leagues <- data.frame(do.call(rbind, lapply(table, function(row) {
    league <- rvest::html_node(row, ".col-league")
    id <- rvest::html_node(league, "a") %>%
      rvest::html_attr("href") %>%
      stringr::str_replace("/league/", "")
    name <- rvest::html_text(league, trim = TRUE)
    n_teams <- rvest::html_node(row, ".col") %>%
      rvest::html_text(trim = TRUE)
    c(id, name, n_teams)
  })), stringsAsFactors = FALSE)
  colnames(leagues) <- c("league_id", "league_name", "n_teams")
  # convert id and n_teams from character to numeric
  leagues$league_id <- as.numeric(leagues$league_id)
  leagues$n_teams <- as.numeric(leagues$n_teams)
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
  # get the teams table
  table <- rvest::html_node(html, ".table-hover") %>%
    rvest::html_node("tbody") %>%
    rvest::html_nodes("tr")
  # for each row get team ID, name, and summary statistics
  teams <- data.frame(do.call(rbind, lapply(table, function(row) {
    team <- rvest::html_node(row, ".col-name-wide")
    id <- rvest::html_node(team, "a") %>%
      rvest::html_attr("href") %>%
      stringr::str_replace("/team/", "") %>%
      stringr::str_replace("/.*", "")
    name <- rvest::html_text(team, trim = TRUE)
    oa <- rvest::html_node(row, ".col-oa") %>% rvest::html_text(trim = TRUE)
    at <- rvest::html_node(row, ".col-at") %>% rvest::html_text(trim = TRUE)
    md <- rvest::html_node(row, ".col-md") %>% rvest::html_text(trim = TRUE)
    df <- rvest::html_node(row, ".col-df") %>% rvest::html_text(trim = TRUE)
    tb <- rvest::html_node(row, ".col-tb") %>% rvest::html_text(trim = TRUE)
    ps <- rvest::html_node(row, ".col-ps") %>% rvest::html_text(trim = TRUE)
    c(id, name, oa, at, md, df, tb, ps)
  })), stringsAsFactors = FALSE)
  colnames(teams) <- c(
    "team_id", "team_name", "overall", "attack", "midfield", "defense",
    "transfer_budget", "n_players"
  )
  # convert id and metrics from character to numeric
  teams$team_id <- as.numeric(teams$team_id)
  teams$overall <- as.numeric(teams$overall)
  teams$attack <- as.numeric(teams$attack)
  teams$midfield <- as.numeric(teams$midfield)
  teams$defense <- as.numeric(teams$defense)
  teams$n_players <- as.numeric(teams$n_players)
  # return data frame
  teams
}

#' @rdname get_players
#' @export
get_players <- function(team_id, include_on_loan = TRUE) {
  # build url
  url <- paste0(base_url, "/team/", team_id)
  # read html page (team overview)
  html <- xml2::read_html(GET_stealthy(url))
  # get the teams table
  table <- rvest::html_nodes(html, ".table-hover") %>%
    rvest::html_node("tbody")
  if (!include_on_loan) {
    # if loan players should not be included, then keep just the first table
    table <- table[[1]]
  }
  table <- rvest::html_nodes(table, "tr")
  # for each row get team ID, name, and summary statistics
  players <- data.frame(do.call(rbind, lapply(table, function(row) {
    player <- rvest::html_node(row, ".col-name")
    id <- rvest::html_node(player, "a") %>%
      rvest::html_attr("href") %>%
      stringr::str_replace("/player/", "") %>%
      stringr::str_replace("/.*", "")
    name <- rvest::html_node(row, ".tooltip") %>%
      rvest::html_attr("data-tooltip")
    pos <- rvest::html_nodes(row, ".pos") %>%
      rvest::html_text(trim = TRUE) %>%
      unique() %>%
      paste(collapse = " ")
    ae <- rvest::html_node(row, ".col-ae") %>% rvest::html_text(trim = TRUE)
    oa <- rvest::html_node(row, ".col-oa") %>% rvest::html_text(trim = TRUE)
    pt <- rvest::html_node(row, ".col-pt") %>% rvest::html_text(trim = TRUE)
    vl <- rvest::html_node(row, ".col-vl") %>% rvest::html_text(trim = TRUE)
    wg <- rvest::html_node(row, ".col-wg") %>% rvest::html_text(trim = TRUE)
    c(id, name, pos, ae, oa, pt, vl, wg)
  })), stringsAsFactors = FALSE)
  colnames(players) <- c(
    "player_id", "player_name", "position", "age", "overall", "potential",
    "value", "wage"
  )
  # convert id and metrics from character to numeric
  players$player_id <- as.numeric(players$player_id)
  players$age <- as.numeric(players$age)
  players$overall <- as.numeric(players$overall)
  players$potential <- as.numeric(players$potential)
  # return data frame
  players
}

#' @importFrom stats setNames
get_scores <- function(player_id) {
  # build url
  url <- paste0(base_url, "/player/", player_id)
  # read html page (player profile)
  html <- xml2::read_html(GET_stealthy(url))
  # get the scores table
  tables <- rvest::html_nodes(html, ".pl")
  scores <- tables %>%
    rvest::html_nodes("li") %>%
    rvest:: html_text(trim = TRUE)
  names <- sub("[[:digit:]]+ ", "", scores)
  scores <- sub(" .*", "", scores)
  names(scores) <- names
  # keep only interest scores
  scores <- scores[score_labels]
  # convert scores to numeric
  num_scores <- setNames(as.numeric(scores), names(scores))
  # add player id
  num_scores <- c(player_id = player_id, num_scores)
  # store scores in data frame and return it
  as.data.frame(t(num_scores))
}

# define base url
base_url <- "https://sofifa.com"

# define labels to use for score extraction from player profile pages
score_labels <- c(
  "Crossing", "Finishing", "Heading Accuracy", "Short Passing", "Volleys",
  "Dribbling", "Curve", "FK Accuracy", "Long Passing", "Ball Control",
  "Acceleration", "Sprint Speed", "Agility", "Reactions", "Balance",
  "Shot Power", "Jumping", "Stamina", "Strength", "Long Shots",
  "Aggression", "Interceptions", "Positioning", "Vision", "Penalties", "Composure",
  "Defensive Awareness", "Standing Tackle", "Sliding Tackle",
  "GK Diving", "GK Handling", "GK Kicking", "GK Positioning", "GK Reflexes"
)
