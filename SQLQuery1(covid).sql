select* 
from project..covid_death$
where continent is not null
order by 3,4

--select* 
--from project..covid_vaccination$
--order by 3,4

--select data that we are going to be using

select location,date,total_cases,new_cases,total_deaths,population
from project..covid_death$
where continent is not null
order by 1,2

--looking at total cases vs total deaths
select location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
from project..covid_death$
where location like '%states%'
where continent is not null
order by 1,2

--looking at total cases vs population
--show what percent of population got covid

select location,date,population,total_cases,(total_cases/population)*100 as InfectedPercentage
from project..covid_death$
--where location like '%states%'
where continent is not null
order by 1,2

--looking at countries with highest infection rate compared to population

select location,population,max(total_cases) as HighestInfectionCount,max((total_cases/population))*100 as InfectedPercentage
from project..covid_death$
--where location like '%states%'
where continent is not null
group by location,population
order by 4 desc

--showing countries with highest death count per population

select location,max(cast(total_deaths as int)) as TotalDeathCount
from project..covid_death$
--where location like '%states%'
where continent is not null
group by location
order by 2 desc

--LETS BREAK THINGS DOWN BY CONTINENT
--showing continent with highest death count per population

select continent,max(cast(total_deaths as int)) as TotalDeathCount
from project..covid_death$
--where location like '%states%'
where continent is not null
group by continent
order by 2 desc

--GLOBAL NUMBERS

select SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(CAST(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from project..covid_death$
--where location like '%states%'
where continent is not null
--group by date
order by 1,2

--looking at total population vs vaccination

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as float)) OVER(Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100
from project..covid_death$ dea
join project..covid_vaccination$ vac
on dea.location=vac.location 
and dea.date=vac.date
where dea.continent is not null
order by 2,3

--USE CTE
with popvsvac (continent,location,date,population,new_vaccination,RollingPeopleVaccinated)
as(
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as float)) OVER(Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100
from project..covid_death$ dea
join project..covid_vaccination$ vac
on dea.location=vac.location 
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
select *,(RollingPeopleVaccinated/population)*100
from popvsvac
 
 --temp table
 drop table if exists #PercentPopulationVaccinated
 create table #PercentPopulationVaccinated
 (
 continent varchar(255),
 location nvarchar(255),
 date datetime,
 population numeric,
 new_vaccinations numeric,
 RollingPeopleVaccinated numeric
 )
 Insert into  #PercentPopulationVaccinated
 select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as float)) OVER(Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100
from project..covid_death$ dea
join project..covid_vaccination$ vac
on dea.location=vac.location 
and dea.date=vac.date
--where dea.continent is not null
--order by 2,3

select *,(RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--creating view to store data for later visualizations

Create view PercentPopulationVaccinated as 
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(cast(vac.new_vaccinations as float)) OVER(Partition by dea.location order by dea.location,dea.date)
as RollingPeopleVaccinated 
--(RollingPeopleVaccinated/population)*100
from project..covid_death$ dea
join project..covid_vaccination$ vac
on dea.location=vac.location 
and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select*
from PercentPopulationVaccinated 
