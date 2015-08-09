#!/bin/bash

createdb basketball

# PostgreSQL fuzzy string mathcing extension

psql basketball -c "create extension fuzzystrmatch;"

# Basketball Reference data

psql basketball -f create_schema_bbref.sql

# NBA draft picks

cp bbref/draft_picks.csv /tmp/bbref_draft_picks.csv
psql basketball -f load_bbref_draft_picks.sql
rm /tmp/bbref_draft_picks.csv

# NBA basic statistics

cp bbref/basic.csv /tmp/bbref_basic.csv
psql basketball -f load_bbref_basic.sql
rm /tmp/bbref_basic.csv

# NBA schools and players

psql basketball -f create_bbref_schools.sql
psql basketball -f create_bbref_players.sql

# NBA games

cp bbref/games.csv /tmp/bbref_games.csv
psql basketball -f load_bbref_games.sql
rm /tmp/bbref_games.csv

# NBA playoffs

cp bbref/playoffs.csv /tmp/bbref_playoffs.csv
psql basketball -f load_bbref_playoffs.sql
rm /tmp/bbref_playoffs.csv

# NBA teams

psql basketball -f create_bbref_teams.sql

# NCAA schema

psql basketball -f create_schema_ncaa.sql

# NCAA game results

tail -q -n+2 ncaa/ncaa_games_*.csv > /tmp/ncaa_games.csv
rpl -q '""' '' /tmp/ncaa_games.csv
psql basketball -f load_ncaa_games.sql
rm /tmp/ncaa_games.csv

# NCAA players statistics

cat ncaa/ncaa_players_*.csv > /tmp/ncaa_statistics.csv
rpl ",-," ",," /tmp/ncaa_statistics.csv
rpl ",-," ",," /tmp/ncaa_statistics.csv
rpl ".," "," /tmp/ncaa_statistics.csv
rpl ".0," "," /tmp/ncaa_statistics.csv
rpl ".00," "," /tmp/ncaa_statistics.csv
rpl ".000," "," /tmp/ncaa_statistics.csv
rpl -e ",-\n" ",\n" /tmp/ncaa_statistics.csv
psql basketball -f load_ncaa_statistics.sql
rm /tmp/ncaa_statistics.csv

# NCAA players

psql basketball -f create_ncaa_players.sql

# NCAA schools

cp ncaa/schools.csv /tmp/ncaa_schools.csv
psql basketball -f load_ncaa_schools.sql
rm /tmp/ncaa_schools.csv

# NCAA school divisions

cp ncaa/ncaa_divisions.csv /tmp/ncaa_divisions.csv
psql basketball -f load_ncaa_divisions.sql
rm /tmp/ncaa_divisions.csv

# NCAA school colors

cp ncaa/ncaa_colors.csv /tmp/ncaa_colors.csv
psql basketball -f load_ncaa_colors.sql
rm /tmp/ncaa_colors.csv

# Aliases

psql basketball -f create_schema_alias.sql

# Match schools using Levenshtein distance (exact match for now)

psql basketball -f create_alias_schools.sql

# Matching players on school and last name

psql basketball -f create_alias_players.sql

# Basic feature detection for NCAA characteristics impacting NBA playing time 1 year out

R --vanilla < feature_selection.R

exit 1
