begin;

create temporary table r (
       team_id	 integer,
       div	 	 integer,
       year	 	 integer,
       str	 	 numeric(4,3),
       ofs	 	 numeric(4,3),
       dfs	 	 numeric(4,3),
       sos	 	 numeric(4,3)
);

insert into r
(team_id,div,year,str,ofs,dfs,sos)
(
select
t.team_id,
t.div_id as div,
sf.year,
(sf.strength*o.exp_factor/d.exp_factor)::numeric(4,3) as str,
(offensive*o.exp_factor)::numeric(4,3) as ofs,
(defensive*d.exp_factor)::numeric(4,3) as dfs,
schedule_strength::numeric(4,3) as sos
from euroleague._schedule_factors sf
left outer join euroleague.schools_divisions t
  on (t.team_id,t.year)=(sf.team_id,sf.year)
left outer join euroleague._factors o
  on (o.parameter,o.level)=('o_div',length(t.division)::text)
left outer join euroleague._factors d
  on (d.parameter,d.level)=('d_div',length(t.division)::text)
where sf.year in (2015)
and t.team_id is not null
order by str desc);

select
year,
exp(avg(log(str)))::numeric(4,3) as str,
exp(avg(log(ofs)))::numeric(4,3) as ofs,
exp(-avg(log(dfs)))::numeric(4,3) as dfs,
exp(avg(log(sos)))::numeric(4,3) as sos,
count(*) as n
from r
group by year
order by year asc;

select
year,
div,
exp(avg(log(str)))::numeric(4,3) as str,
exp(avg(log(ofs)))::numeric(4,3) as ofs,
exp(-avg(log(dfs)))::numeric(4,3) as dfs,
exp(avg(log(sos)))::numeric(4,3) as sos,
--avg(str)::numeric(4,3) as str,
--avg(ofs)::numeric(4,3) as ofs,
--(1/avg(dfs))::numeric(4,3) as dfs,
--avg(sos)::numeric(4,3) as sos,
count(*) as n
from r
where div is not null
group by year,div
order by year asc,str desc;

select * from r
where div is null
and year=2015;

commit;
