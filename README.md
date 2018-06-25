SoFIFA API for R
================

[![Travis-CI Build Status](https://travis-ci.org/valentinumbach/SoFIFA.svg?branch=master)](https://travis-ci.org/valentinumbach/SoFIFA)

[SoFIFA.com](https://sofifa.com) offers up-to-date, detailed scores on all players from [EA Sports FIFA](https://www.easports.com/fifa). This package makes it easy to load that data into R -- for individual players, teams, or complete leagues.

Usage
-----

The `SoFIFA` package offers 2 groups of functions. The first group will help you get SoFIFA.com IDs for leagues, teams, or individual players. The second group will load the SoFIFA scores for those IDs.

### Getting IDs

To begin, you will typically start at the league level. Get all currently available leagues with `get_leagues()`.

``` r
library(SoFIFA)
leagues <- get_leagues()
```

|  league\_id| league\_name                      |
|-----------:|:----------------------------------|
|           1| Danish Superliga (1)              |
|           4| Belgian Jupiler Pro League (1)    |
|           7| Campeonato Brasileiro Série A (1) |
|          10| Holland Eredivisie (1)            |
|          13| English Premier League (1)        |
|          14| English League Championship (2)   |

Let's say we're interested in the English Premier League. We will next get the IDs for all teams from that league with `get_teams()`, using the `league_id` we just got.

``` r
teams <- get_teams(13)
```

|  team\_id| team\_name        |
|---------:|:------------------|
|        10| Manchester City   |
|         5| Chelsea           |
|        11| Manchester United |
|        18| Tottenham Hotspur |
|         1| Arsenal           |
|         9| Liverpool         |

Finally, we want to get all the player IDs for Tottenham Hotspur. We use their `team_id` with the `get_players()` function.

``` r
players <- get_players(18)
```

|  player\_id| player\_name      |
|-----------:|:------------------|
|      202126| Harry Kane        |
|      211117| Dele Alli         |
|      200104| Heung Min Son     |
|      190460| Christian Eriksen |
|      162240| Moussa Dembélé    |
|      202335| Eric Dier         |

### Getting scores

Of course, what we're really after are the SoFIFA scores. So we can now use the IDs we got in the first step.

Let's start with an individual player. The `get_player_scores()` function let's us collect scores from one or many players, using their `player_id`. Here, we're looking for the scores from Harry Kane.

``` r
player_scores <- get_player_scores(202126)
```

|  Overall Rating|  Potential|  Crossing|  Finishing|  Heading Accuracy|  Short Passing|  Volleys|  Dribbling|  Curve|  FK Accuracy|  Long Passing|  Ball Control|  Acceleration|  Sprint Speed|  Agility|  Reactions|  Balance|  Shot Power|  Jumping|  Stamina|  Strength|  Long Shots|  Aggression|  Interceptions|  Positioning|  Vision|  Penalties|  Composure|  Marking|  Standing Tackle|  Sliding Tackle|  GK Diving|  GK Handling|  GK Kicking|  GK Positioning|  GK Reflexes|  player\_id|
|---------------:|----------:|---------:|----------:|-----------------:|--------------:|--------:|----------:|------:|------------:|-------------:|-------------:|-------------:|-------------:|--------:|----------:|--------:|-----------:|--------:|--------:|---------:|-----------:|-----------:|--------------:|------------:|-------:|----------:|----------:|--------:|----------------:|---------------:|----------:|------------:|-----------:|---------------:|------------:|-----------:|
|              88|         91|        75|         92|                83|             79|       77|         80|     75|           68|            80|            84|            72|            75|       73|         90|       62|          87|       70|       88|        87|          85|          76|             35|           92|      80|         86|         89|       41|               36|              38|          8|           10|          11|              14|           11|      202126|

Next, we want to see scores from all players of Tottenham Hotspur. We can use the `get_team_scores()` function with the `team_id`.

``` r
team_scores <- get_team_scores(18, max_results = 5)
```

|  player\_id| player\_name      |  Overall Rating|  Potential|  Crossing|  Finishing|  Heading Accuracy|  Short Passing|  Volleys|  Dribbling|  Curve|  FK Accuracy|  Long Passing|  Ball Control|  Acceleration|  Sprint Speed|  Agility|  Reactions|  Balance|  Shot Power|  Jumping|  Stamina|  Strength|  Long Shots|  Aggression|  Interceptions|  Positioning|  Vision|  Penalties|  Composure|  Marking|  Standing Tackle|  Sliding Tackle|  GK Diving|  GK Handling|  GK Kicking|  GK Positioning|  GK Reflexes|
|-----------:|:------------------|---------------:|----------:|---------:|----------:|-----------------:|--------------:|--------:|----------:|------:|------------:|-------------:|-------------:|-------------:|-------------:|--------:|----------:|--------:|-----------:|--------:|--------:|---------:|-----------:|-----------:|--------------:|------------:|-------:|----------:|----------:|--------:|----------------:|---------------:|----------:|------------:|-----------:|---------------:|------------:|
|      202126| Harry Kane        |              88|         91|        75|         92|                83|             79|       77|         80|     75|           68|            80|            84|            72|            75|       73|         90|       62|          87|       70|       88|        87|          85|          76|             35|           92|      80|         86|         89|       41|               36|              38|          8|           10|          11|              14|           11|
|      211117| Dele Alli         |              84|         90|        68|         83|                77|             84|       76|         83|     71|           53|            76|            85|            77|            76|       74|         85|       62|          77|       69|       89|        71|          80|          84|             67|           86|      84|         68|         86|       60|               63|              57|          7|            6|           9|              11|            8|
|      200104| Heung Min Son     |              84|         87|        78|         85|                65|             79|       75|         87|     81|           70|            64|            85|            88|            87|       83|         84|       78|          85|       65|       85|        64|          87|          60|             39|           85|      79|         71|         80|       27|               34|              33|         11|           13|          13|               6|           10|
|      190460| Christian Eriksen |              88|         91|        87|         81|                52|             90|       74|         84|     86|           86|            86|            89|            77|            74|       80|         86|       82|          84|       55|       91|        57|          87|          46|             56|           83|      90|         67|         87|       39|               57|              22|          9|           14|           7|               7|            6|
|      162240| Moussa Dembélé    |              84|         84|        65|         66|                70|             86|       73|         89|     65|           55|            80|            89|            75|            77|       82|         84|       76|          85|       77|       76|        91|          71|          79|             82|           70|      80|         67|         90|       71|               83|              70|         16|           14|          11|              16|           14|

Finally, we can also collect scores for all players in the Premier League. We user the `get_league_scores()` function with `league_id`.

``` r
league_scores <- get_league_scores(13, max_results = 5)
```

Installation
------------

Install from GitHub

``` r
# install.packages("devtools")
devtools::install_github("valentinumbach/SoFIFA")
```
