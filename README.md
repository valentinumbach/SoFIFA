---
title: "SoFIFA API for R"
output: github_document
---

[![Travis-CI Build Status](https://travis-ci.org/valentinumbach/SoFIFA.svg?branch=master)](https://travis-ci.org/valentinumbach/SoFIFA)

[SoFIFA.com](https://sofifa.com) offers up-to-date, detailed scores on all players 
from [EA Sports FIFA](https://www.easports.com/fifa). 
This package makes it easy to load that data into R -- for individual players, 
teams, or complete leagues.

## Usage

The `SoFIFA` package offers 2 groups of functions. The first group will help you
get SoFIFA.com IDs for leagues, teams, or individual players. The second group 
will load the SoFIFA scores for those IDs.

### Getting IDs

To begin, you will typically start at the league level. Get all currently
available leagues with `get_leagues()`.


```r
library(SoFIFA)
library(magrittr)
leagues <- get_leagues()
```


| league_id|league_name                       |
|---------:|:---------------------------------|
|         1|Danish Superliga (1)              |
|         4|Belgian Jupiler Pro League (1)    |
|         7|Campeonato Brasileiro Série A (1) |
|        10|Holland Eredivisie (1)            |
|        13|English Premier League (1)        |
|        14|English League Championship (2)   |


Let's say we're interested in the English Premier League. We will next get the
IDs for all teams from that league with `get_teams()`, using the `league_id` we
just got.


```r
teams <- get_league_teams(13)
```


| league_id| team_id|team_name         |
|---------:|-------:|:-----------------|
|        13|      10|Manchester City   |
|        13|       5|Chelsea           |
|        13|       9|Liverpool         |
|        13|      11|Manchester United |
|        13|      18|Tottenham Hotspur |
|        13|       1|Arsenal           |

Finally, we want to get all the player IDs for Tottenham Hotspur. We use their
`team_id` with the `get_players()` function.


```r
players <- get_team_players(18)
```

```
## Fetching team 1 / 1
```


| team_id| player_id|player_name       |
|-------:|---------:|:-----------------|
|      18|    167948|Hugo Lloris       |
|      18|    186345|Kieran Trippier   |
|      18|    184087|Toby Alderweireld |
|      18|    172871|Jan Vertonghen    |
|      18|    169595|Danny Rose        |
|      18|    183394|Moussa Sissoko    |

### Getting scores

Of course, what we're really after are the SoFIFA scores. So we can now use the
IDs we got in the first step.

Let's start with an individual player. The `get_player_scores()` function let's 
us collect scores from one or many players, using their `player_id`.
Here, we're looking for the scores from Harry Kane.


```r
player_scores <- get_player_scores(202126)
```

```
## Fetching player 1 / 1
```


| player_id|player_name |fifa_version |date       | Overall.Rating| Potential| Crossing| Finishing| Heading.Accuracy| Short.Passing| Volleys| Dribbling| Curve| FK.Accuracy| Long.Passing| Ball.Control| Acceleration| Sprint.Speed| Agility| Reactions| Balance| Shot.Power| Jumping| Stamina| Strength| Long.Shots| Aggression| Interceptions| Positioning| Vision| Penalties| Composure| Marking| Standing.Tackle| Sliding.Tackle| GK.Diving| GK.Handling| GK.Kicking| GK.Positioning| GK.Reflexes|Preferred.Foot | International.Reputation| Weak.Foot|Body.Type |
|---------:|:-----------|:------------|:----------|--------------:|---------:|--------:|---------:|----------------:|-------------:|-------:|---------:|-----:|-----------:|------------:|------------:|------------:|------------:|-------:|---------:|-------:|----------:|-------:|-------:|--------:|----------:|----------:|-------------:|-----------:|------:|---------:|---------:|-------:|---------------:|--------------:|---------:|-----------:|----------:|--------------:|-----------:|:--------------|------------------------:|---------:|:---------|
|    202126|Harry Kane  |19           |2019-03-14 |             90|        92|       75|        94|               86|            82|      85|        80|    78|          68|           83|           84|           68|           72|      71|        91|      73|         88|      79|      89|       84|         86|         78|            35|          93|     81|        90|        91|      56|              36|             38|         8|          10|         11|             14|          11|Right          |                        3|         4|Normal    |

Next, we want to see scores from all players of Tottenham Hotspur. We can use
the `get_player_scores()` function with the player id obtained from `get_team_players`.


```r
team_scores <- get_team_players(18)$player_id %>% head(5) %>% get_player_scores()
```

```
## Fetching team 1 / 1
```

```
## Fetching player 1 / 5
```

```
## Fetching player 2 / 5
```

```
## Fetching player 3 / 5
```

```
## Fetching player 4 / 5
```

```
## Fetching player 5 / 5
```


| player_id|player_name       |fifa_version |date       | Overall.Rating| Potential| Crossing| Finishing| Heading.Accuracy| Short.Passing| Volleys| Dribbling| Curve| FK.Accuracy| Long.Passing| Ball.Control| Acceleration| Sprint.Speed| Agility| Reactions| Balance| Shot.Power| Jumping| Stamina| Strength| Long.Shots| Aggression| Interceptions| Positioning| Vision| Penalties| Composure| Marking| Standing.Tackle| Sliding.Tackle| GK.Diving| GK.Handling| GK.Kicking| GK.Positioning| GK.Reflexes|Preferred.Foot | International.Reputation| Weak.Foot|Body.Type |
|---------:|:-----------------|:------------|:----------|--------------:|---------:|--------:|---------:|----------------:|-------------:|-------:|---------:|-----:|-----------:|------------:|------------:|------------:|------------:|-------:|---------:|-------:|----------:|-------:|-------:|--------:|----------:|----------:|-------------:|-----------:|------:|---------:|---------:|-------:|---------------:|--------------:|---------:|-----------:|----------:|--------------:|-----------:|:--------------|------------------------:|---------:|:---------|
|    167948|Hugo Lloris       |19           |2019-03-14 |             88|        88|       13|        10|               10|            50|      11|        10|    11|          10|           50|           34|           65|           62|      55|        85|      54|         23|      74|      41|       43|         14|         31|            27|          10|     30|        40|        65|      29|              10|             18|        88|          84|         68|             83|          92|Left           |                        4|         1|Lean      |
|    186345|Kieran Trippier   |19           |2019-03-14 |             81|        81|       89|        48|               73|            79|      54|        75|    87|          83|           78|           81|           76|           75|      74|        78|      74|         75|      73|      88|       65|         70|         70|            79|          75|     80|        66|        73|      76|              82|             79|        11|          14|          8|             11|          10|Right          |                        2|         4|Normal    |
|    184087|Toby Alderweireld |19           |2019-03-14 |             87|        87|       64|        45|               82|            79|      38|        62|    63|          69|           85|           75|           61|           67|      60|        88|      50|         78|      84|      78|       79|         65|         81|            87|          58|     67|        58|        84|      90|              91|             86|        16|           6|         14|             16|          14|Right          |                        3|         3|Normal    |
|    172871|Jan Vertonghen    |19           |2019-03-14 |             87|        87|       72|        56|               80|            79|      52|        71|    63|          73|           74|           77|           61|           65|      61|        85|      60|         80|      85|      75|       79|         66|         84|            89|          60|     68|        66|        83|      89|              87|             88|         6|          10|          9|             12|           7|Left           |                        3|         3|Normal    |
|    169595|Danny Rose        |19           |2019-03-14 |             81|        81|       82|        57|               62|            77|      64|        80|    64|          57|           66|           77|           79|           77|      72|        82|      79|         68|      75|      82|       72|         67|         87|            81|          68|     73|        57|        76|      77|              83|             84|        10|          11|          8|             13|          13|Left           |                        3|         3|Normal    |

Finally, we can also collect scores for all players in the Premier League. We
use the `get_league_scores()` function with `league_id`. Note that we will use
magrittr to avoid a bracket hell:


```r
league_scores <- get_league_teams(13)$team_id    %>% head(1) %>%
                 {get_team_players(.)$player_id} %>% head(5) %>%
                 get_player_scores()
```

## Installation

Install from GitHub


```r
# install.packages("devtools")
devtools::install_github("valentinumbach/SoFIFA")
```

