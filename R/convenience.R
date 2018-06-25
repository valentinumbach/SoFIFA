#' Get SoFIFA scores for players, teams, or complete leagues.
#'
#' @param player_ids Numeric (vector of) ID(s) obtained via \code{get_players()}.
#' @param team_id Numeric ID obtained via \code{get_teams()}.
#' @param league_id Numeric ID obtained via \code{get_leagues()}.
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
#' team_scores <- get_team_scores(18)
#'
#' \dontrun{
#' # get scores for all Premier League players
#' league_scores <- get_league_scores(13)
#' }
#' @export
get_player_scores <- function(player_ids) {
  # initialize counter for progress display
  i <- 1
  for (player_id in player_ids) {
    # progress display
    cat("Fetching player", i, "of", length(player_ids), "\n")
    # get player scores
    player_scores <- get_scores(player_id)
    # add column with player ID
    player_scores$player_id <- player_id
    # append data frame, if exists
    if (!exists("all_scores")) {
      all_scores <- player_scores
    } else {
      all_scores <- rbind(all_scores, player_scores)
    }
    # increment counter for progress display
    i <- i + 1
  }
  # return data frame
  all_scores
}

#' @rdname get_player_scores
#' @export
get_team_scores <- function(team_id) {
  # get team players
  players <- get_players(team_id)
  # get player scores
  scores <- get_player_scores(players$player_id)
  # join to add player names to scores
  team_scores <- players %>%
    dplyr::left_join(scores, by = c("player_id"))
  # return data frame
  team_scores
}

#' @rdname get_player_scores
#' @export
get_league_scores <- function(league_id) {
  # get league teams
  teams <- get_teams(league_id)
  # initialize counter for progress display
  i <- 1
  for (team_id in teams$team_id) {
    # progress display
    cat("Fetching team", i, "of", nrow(teams), "\n")
    # get team scores
    team_scores <- get_team_scores(team_id)
    # add column with team ID
    team_scores$team_id <- team_id
    # append data frame, if exists
    if (!exists("scores")) {
      scores <- team_scores
    } else {
      scores <- rbind(scores, team_scores)
    }
    # increment counter for progress display
    i <- i + 1
  }
  # join to add team names to scores
  league_scores <- teams %>%
    dplyr::left_join(scores, by = c("team_id"))
  # return data frame
  league_scores
}
