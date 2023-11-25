select *from altadatacovid_19$
-- showing the selective one 
SELECT reported_date, country_region, active, deaths, 
    CASE 
        WHEN active = 0 THEN 0  -- Handling division by zero scenario
        ELSE (deaths * 100.0) / NULLIF(active, 0) -- Calculate percentage
    END AS percentage
FROM altadatacovid_19$;

-- use of like query 
SELECT reported_date, country_region, active, deaths, 
    CASE 
        WHEN active = 0 THEN 0  -- Handling division by zero scenario
        ELSE (deaths * 100.0) / NULLIF(active, 0) -- Calculate percentage
    END AS percentage
FROM altadatacovid_19$
where country_region like 'pak%';

-- percentage of population affected --
SELECT reported_date, country_region,
active,
population,
(active/population)*100 as percnt_population_affected 
from altadatacovid_19$
where country_region like 'pak%'

select country_region,[population],max(confirmed) as max_confirmed 
from altadatacovid_19$
group by country_region,population
order by 1


SELECT country_region, max(population) AS max_population,
MAX(confirmed) AS max_confirmed,
MAX((active/population)*1000) AS max_percentage
FROM altadatacovid_19$
GROUP BY country_region
order by max_percentage desc


-- count max death 
SELECT country_region, max(deaths) AS max_deaths
FROM altadatacovid_19$
GROUP BY country_region
order by max_deaths desc



SELECT reported_date , sum(confirmed) as total_caseper_date,sum(deaths) as total_death_per_day,
(sum(confirmed)/sum(deaths)) as death_percentage
FROM altadatacovid_19$
GROUP BY reported_date



SELECT  sum(confirmed) as total_caseper_date,sum(deaths) as total_death_per_day,
(sum(confirmed)/sum(deaths)) as death_percentage
FROM altadatacovid_19$

----IMPORTAND QUERY----
select reported_date,
country_region,population,
confirmed,active,deaths,
recovered as virus_after_active,
sum(deaths)over(partition by country_region order by country_region,reported_date )as rolling_man_death
from [dbo].[altadatacovid_19$]


----USE THE CTE -- importand --
WITH CTE1 AS (
    SELECT reported_date,
           country_region,
           population,
           confirmed,
           active,
           deaths,
           recovered AS virus_after_active,
           SUM(deaths) OVER (PARTITION BY country_region ORDER BY reported_date) AS rolling_man_death
    FROM [dbo].[altadatacovid_19$]
)
SELECT reported_date,
       country_region,
       population,
       confirmed,
       active,
       deaths,
       virus_after_active,
       rolling_man_death,
( rolling_man_death/population)*100  as death_percent from CTE1;

--- TEMP TABLE ----
create table #temp(
reported_date date ,
country_region varchar(255),
population numeric ,
confirmed int,
active int, 
death int ,
virus_after_active int ,
rolling_man_death int 

-- drop table if exist #temp 
insert into #temp
select reported_date,
country_region,population,
confirmed,active,deaths,
recovered as virus_after_active,
sum(deaths)over(partition by country_region order by country_region,reported_date )as rolling_man_death
from [dbo].[altadatacovid_19$]

select *,( rolling_man_death/population)*100  as death_percent from #temp
where country_region like 'pak%'

-- creating view for later use 
create view temp as 
SELECT  sum(confirmed) as total_caseper_date,sum(deaths) as total_death_per_day,
(sum(confirmed)/sum(deaths)) as death_percentage
FROM altadatacovid_19$
select *from temp