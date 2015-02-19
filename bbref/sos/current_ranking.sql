begin;

create temporary table r (
       rk	 serial,
       team 	 text,
       team_id	 text,
       year	 integer,
       str	 numeric(4,3),
       ofs	 numeric(4,3),
       dfs	 numeric(4,3),
       sos	 numeric(4,3)
);

insert into r
(team,team_id,year,str,ofs,dfs,sos)
(
select
coalesce(s.team_name,sf.team_id::text),
sf.team_id,
sf.year,
sf.strength::numeric(4,3) as str,
offensive::numeric(4,3) as ofs,
defensive::numeric(4,3) as dfs,
schedule_strength::numeric(4,3) as sos
from bbref._schedule_factors sf
join bbref.teams s
  on (s.team_id)=(sf.team_id)
where sf.year in (2013)
order by str desc);

select
rk,team,str,ofs,dfs,sos
from r
order by rk asc;

commit;
