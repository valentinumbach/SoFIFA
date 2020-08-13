#' Get SoFIFA scores for players, teams, or complete leagues.
#'
#' @param player_ids Numeric (vector of) ID(s) obtained via \code{get_players()}.
#' @param team_id Numeric ID obtained via \code{get_teams()}.
#' @param league_id Numeric ID obtained via \code{get_leagues()}.
#' @param max_results Numeric maximum results returned. Defaults to \code{Inf}.
#' @param include_on_loan Logical indicating if players actually on loan should
#'   be included. Defaults to TRUE.
#' @return \code{player_scores}, \code{team_scores}, \code{league_scores},
#'   a data frame.
#' @examples
#' \dontrun{
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
#' }
#' @export
get_player_scores <- function(player_ids, max_results = Inf) {
  # initialize counter for progress display
  i <- 1
  all_scores <- data.frame()
  for (player_id in player_ids) {
    # progress display
    cat("Fetching player", i, "of", length(player_ids), "\n")
    # get player scores
    player_scores <- get_scores(player_id)
    # append data frame
    all_scores <- rbind(all_scores, player_scores)
    # increment counter for progress display
    i <- i + 1
    # break for loop to deliver <= max_results
    if (i > max_results) {
      pkg.env$max_results_reached <- TRUE
      break
    }
  }
  # return data frame, limit to max_results
  head(all_scores, n = max_results)
}

#' @rdname get_player_scores
#' @export
get_team_scores <- function(team_id, max_results = Inf, include_on_loan = TRUE) {
  # get team players
  players <- get_players(team_id, include_on_loan)
  # get player scores
  scores <- get_player_scores(players$player_id, max_results)
  # join to add player names to scores
  team_scores <- players %>%
    dplyr::left_join(scores, by = c("player_id"))
  # return data frame, limit to max_results
  head(team_scores, n = max_results)
}

#' @rdname get_player_scores
#' @export
get_league_scores <- function(league_id, max_results = Inf, include_on_loan = TRUE) {
  # get league teams
  teams <- get_teams(league_id)
  # initialize counter for progress display
  i <- 1
  scores <- data.frame()
  for (team_id in teams$team_id) {
    # progress display
    cat("Fetching team", i, "of", nrow(teams), "\n")
    # get team scores
    team_scores <- get_team_scores(team_id, max_results, include_on_loan)
    # add column with team ID
    team_scores$team_id <- team_id
    # append data frame
    scores <- rbind(scores, team_scores)
    # increment counter for progress display
    i <- i + 1
    # break for loop if max results reached in get_player_scores()
    if (pkg.env$max_results_reached) break
  }
  # join to add team names to scores
  league_scores <- teams %>%
    dplyr::left_join(scores, by = c("team_id"), suffix = c("_team", "_player"))
  # return data frame, limit to max results
  head(league_scores, n = max_results)
}

# initialize max results check
pkg.env <- new.env()
pkg.env$max_results_reached <- FALSE
