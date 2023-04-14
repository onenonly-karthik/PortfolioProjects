select *
from Portfolio_project1..covid_deaths
order by 3,4

--select *
--from Portfolio_project1..covid_vaccinations
--order by 3,4


--selecting data that we are going to using

select Location,date,total_cases,new_cases,total_deaths,population
from Portfolio_project1..covid_deaths
order by 1,2

--looking at total cases vs total deaths
--shows likelihood of dying if you covid in your country

select Location,date,total_cases,total_deaths,(cast(total_deaths as float)/cast(total_cases as float))*100 as DeathPercentage
from Portfolio_project1..covid_deaths
where location='India'
order by 1,2

--looking at total cases vs population
--shows what population got covid

select Location,date,population,total_cases,(cast(total_deaths as float)/cast(population as float))*100 as DeathPercentage
from Portfolio_project1..covid_deaths
--where location='India'
order by 1,2

--looking at countries with highest infection rate

select Location,population,max(total_cases) as highestinfectioncount , max(cast(total_deaths as float)/cast(population as float))*100 as Percentpopulationinfected
from Portfolio_project1..covid_deaths
group by location,population
order by Percentpopulationinfected desc


--showing countries with highest death count per population

select Location, max(cast(total_deaths as int)) as totaldeathcount
from Portfolio_project1..covid_deaths
where continent is not null
group by location
order by totaldeathcount desc

--showing the continents with the highest death count

select continent, max(cast(total_deaths as int)) as totaldeathcount
from Portfolio_project1..covid_deaths
where continent is not null
group by  continent
order by totaldeathcount desc

--global numbers

select sum(new_cases) as total_cases,SUM(new_deaths) as total_deaths,Sum(new_deaths)/nullif(sum(new_cases),0)*100 as deathpercentage
from Portfolio_project1..covid_deaths
where continent is not null
--group by date
order by 1,2

--looking at total population vs vaccinations

select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
   ,SUM(convert(bigint , vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
from Portfolio_project1..covid_deaths as dea
join Portfolio_project1..covid_vaccinations as vac
    on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
order by 2,3



--use VTE

with popvsvac(continent,location,date,population,new_vaccinations,Rollingpeoplevaccinated)
as
(select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
   ,SUM(convert(bigint , vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
from Portfolio_project1..covid_deaths as dea
join Portfolio_project1..covid_vaccinations as vac
    on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
)
select *,(Rollingpeoplevaccinated/population)*100
from popvsvac
order by 2,3

--creating view to store data for later visualisation

create view percentpopulationvaccinated as
select dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
   ,SUM(convert(bigint , vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as Rollingpeoplevaccinated
from Portfolio_project1..covid_deaths as dea
join Portfolio_project1..covid_vaccinations as vac
    on dea.location=vac.location
	and dea.date=vac.date
where dea.continent is not null
--order by 2,3

select *
from percentpopulationvaccinated
