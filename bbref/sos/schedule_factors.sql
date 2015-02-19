begin;

drop table if exists bbref._schedule_factors;

create table bbref._schedule_factors (
	team_id			text,
	year			integer,
        offensive               float,
        defensive		float,
        strength                float,
        schedule_offensive      float,
        schedule_defensive      float,
        schedule_strength       float,
        schedule_offensive_all	float,
        schedule_defensive_all	float,
        primary key (team_id,year)
);

-- defensive
-- offensive
-- strength 
-- schedule_offensive
-- schedule_defensive
-- schedule_strength 

insert into bbref._schedule_factors
(team_id,year,offensive,defensive)
(
select o.level,o.year,o.exp_factor,d.exp_factor
from bbref._factors o
left outer join bbref._factors d
  on (d.level,d.year,d.parameter)=(o.level,o.year,'defense')
where o.parameter='offense'
);

update bbref._schedule_factors
set strength=offensive/defensive;

----

drop table if exists public.r;

create table public.r (
         team_id		text,
         opponent_id		text,
         year                   integer,
	 field_id		text,
         offensive              float,
         defensive		float,
         strength               float,
	 field			float
);

insert into public.r
(team_id,opponent_id,year,field_id)
(
select
r.team_id,
r.opponent_id,
r.year,
r.field
from bbref.results r
where r.year between 2002 and 2013
);

update public.r
set
offensive=o.offensive,
defensive=o.defensive,
strength=o.strength
from bbref._schedule_factors o
where (r.opponent_id,r.year)=(o.team_id,o.year);

-- field

update public.r
set field=f.exp_factor
from bbref._factors f
where (f.parameter,f.level)=('field',r.field_id);

create temporary table rs (
         team_id		text,
         year                   integer,
         offensive              float,
         defensive              float,
         strength               float,
         offensive_all		float,
         defensive_all		float
);

insert into rs
(team_id,year,
 offensive,defensive,strength,offensive_all,defensive_all)
(
select
team_id,
year,
exp(avg(log(offensive))),
exp(avg(log(defensive))),
exp(avg(log(strength))),
exp(avg(log(offensive/field))),
exp(avg(log(defensive*field)))
from r
group by team_id,year
);

update bbref._schedule_factors
set
  schedule_offensive=rs.offensive,
  schedule_defensive=rs.defensive,
  schedule_strength=rs.strength,
  schedule_offensive_all=rs.offensive_all,
  schedule_defensive_all=rs.defensive_all
from rs
where
  (_schedule_factors.team_id,_schedule_factors.year)=
  (rs.team_id,rs.year);

commit;
