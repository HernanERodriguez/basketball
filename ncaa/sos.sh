#!/bin/bash

psql basketball -f sos/standardized_results.sql

psql basketball -c "vacuum full verbose analyze ncaa.results;"

psql basketball -c "drop table ncaa._basic_factors;"
psql basketball -c "drop table ncaa._parameter_levels;"

psql basketball -c "vacuum analyze ncaa.results;"

R --vanilla < sos/lmer.R

psql basketball -c "vacuum full verbose analyze ncaa._parameter_levels;"
psql basketball -c "vacuum full verbose analyze ncaa._basic_factors;"

psql basketball -f sos/normalize_factors.sql
psql basketball -c "vacuum full verbose analyze ncaa._factors;"

psql basketball -f sos/schedule_factors.sql
psql basketball -c "vacuum full verbose analyze ncaa._schedule_factors;"

psql basketball -f sos/connectivity.sql > sos/connectivity.txt
psql basketball -f sos/current_ranking.sql > sos/current_ranking.txt
psql basketball -f sos/division_ranking.sql > sos/division_ranking.txt

psql basketball -f sos/test_predictions.sql > sos/test_predictions.txt

psql basketball -f sos/predict_daily.sql > sos/predict_daily.txt
