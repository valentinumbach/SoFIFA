#' Get SoFIFA IDs for leagues
#'
#' @return A data frame with columns \code{league_id}, \code{league_name}
#' @examples
#' # get all available leagues
#' leagues <- get_leagues()
#'
#' # get all Premier League teams
#' teams <- get_league_teams(13)
#'
#' # get all Tottenham Hotspur players
#' players <- get_team_players(18)
#' @export
get_leagues <- function() {
  # build url
  url <- paste0(base_url, "/leagues")
  # read html page (overview)
  html <- xml2::read_html(GET_stealthy(url))
  # extract league links
  tmp <- xml2::xml_find_all(html, xpath = "//article//a[contains(@href,'/league/')]")
  # prepare empty data frame
  leagues <- data.frame(league_id = rep(0, length(tmp)), league_name = NA)
  # extract league IDs from links
  leagues$league_id <- gsub("/league/([0-9]+).*", "\\1", rvest::html_attr(tmp, "href")) %>% as.numeric()
  # extract league names from links
  leagues$league_name <- rvest::html_text(tmp)
  # return data frame
  leagues
}

get_scores <- function(player_id, version=NULL, exportdate=NULL) {
  # build url
  url <- paste0(base_url, "/player/", player_id)
  if (!is.null(version) && !is.null(exportdate)) {
    url <- paste0(url, "/", version, "/", exportdate)
  }
  # read html page (player profile)
  html <- xml2::read_html(GET_stealthy(url))

  scores <- list()
  scores$player_id = player_id

  # extract player name, fifa version and date of update from title
  text <- rvest::html_node(html, xpath = "//title") %>% rvest::html_text(trim = TRUE)
  matches <- regmatches(text, regexec('(.+) FIFA (.+) ([^ ]+ [0-9]+, [0-9]+) SoFIFA', text, perl=T))[[1]]
  if (length(matches > 0)) {
    scores$player_name = gsub(' *\\(.+\\) *', '', matches[2])
    # matches[3] is full name, but we wont use that
    scores$fifa_version = matches[3]
    scores$date = as.Date(matches[4], format=sofifa_date_fmt)
  }

  # extract scores from html text
  text <- rvest::html_nodes(html, xpath = "//article//span[contains(@class, 'label p')]/..") %>%
          rvest::html_text(trim = TRUE)

  text <- gsub('[+-][0-9]+', '', text)

  # parse node text (remove text to get values and remove numbers to get keys)
  values <- gsub('[^0-9]',     '', text) %>% as.numeric()
  keys   <- gsub('[^a-zA-Z ]', '', text) %>% trimws()


  for (scorestr in score_labels) {
    scores[[scorestr]] <- values[match(scorestr, keys)]
  }

  nodes <- rvest::html_nodes(html, css = "article ul.pl li")
  for (scorestr in score_extras) {
    # build a query to match the label
    q <- paste0('//label[text()="', scorestr, '"]/..')
    # remove the matched label from the html text
    v <- rvest::html_nodes(nodes, xpath = q) %>%
         rvest::html_text(trim = TRUE)
    v <- sub(scorestr, '', v, fixed = TRUE)
    # get value and convert to numeric if possible
    if (length(v) == 0) v <- NA
    scores[[scorestr]] <- if (suppressWarnings(!is.na(as.numeric(v)))) as.numeric(v[1]) else v[1]
  }

  as.data.frame(scores)
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

# scores for other labels (may be non-numeric)
score_extras <- c('Preferred Foot', 'International Reputation', 'Weak Foot', 'Body Type')

sofifa_date_fmt <- '%b %d, %Y'
