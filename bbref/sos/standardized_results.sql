begin;

drop table if exists bbref.results;

create table bbref.results (
	game_id		      integer,
	year		      integer,
	game_date	      date,
	team_name	      text,
	team_id		      text,
	opponent_name	      text,
	opponent_id	      text,
	location_id	      text,
	field		      text,
	team_score	      integer,
	opponent_score	      integer,
	game_length	      text,
	team_previous	      boolean default false,
	opponent_previous     boolean default false
);

insert into bbref.results
(game_id,year,
 game_date,
 team_name,team_id,
 opponent_name,opponent_id,
 location_id,field,
 team_score,opponent_score,game_length)
(
select
game_id,
year,
game_date::date,
trim(both from home_name),
home_id,
trim(both from visitor_name),
visitor_id,
home_id as location_id,
'offense_home' as field,
(case when status in ('OT','SO') then
      least(g.home_score,g.visitor_score)
else g.home_score
end) as team_score,
(case when status in ('OT','SO') then
      least(g.home_score,g.visitor_score)
else g.visitor_score
end) as opponent_score,
status as game_length
from bbref.games g
where
    g.home_score is not NULL
and g.visitor_score is not NULL
and g.home_score >= 0
and g.visitor_score >= 0
and g.home_id is not NULL
and g.visitor_id is not NULL
);

insert into bbref.results
(game_id,year,
 game_date,
 team_name,team_id,
 opponent_name,opponent_id,
 location_id,field,
 team_score,opponent_score,game_length)
(
select
game_id,
year,
game_date::date,
trim(both from visitor_name),
visitor_id,
trim(both from home_name),
home_id,
home_id as location_id,
'defense_home' as field,
(case when status in ('OT','SO') then
      least(g.home_score,g.visitor_score)
else g.visitor_score
end) as team_score,
(case when status in ('OT','SO') then
      least(g.home_score,g.visitor_score)
else g.home_score
end) as opponent_score,
status as game_length
from bbref.games g
where
    g.home_score is not NULL
and g.visitor_score is not NULL
and g.home_score >= 0
and g.visitor_score >= 0
and g.home_id is not NULL
and g.visitor_id is not NULL
);

update bbref.results
set team_previous=true
where (team_id,game_date) in
(select team_id,game_date+1 from bbref.results);

update bbref.results
set opponent_previous=true
where (opponent_id,game_date) in
(select team_id,game_date+1 from bbref.results);

commit;
