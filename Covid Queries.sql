--shows chance of dying if you contract covid in the US
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from CovidDeaths
where location like '%state%'
order by 1,2


-- total cases vs population, what percent got covid
select location, date, total_cases, population, (total_cases/population)*100 as PercentInfected
from CovidDeaths
where location like '%state%'
order by 1,2


-- counties with highest infection rate compared to population
select location, max(total_cases) as HighestInfectionCount, max((total_cases/population))*100 as PercentInfected
from CovidDeaths
group by location, population
order by PercentInfected desc


--show countries with highest death count per population
select location, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by location
order by TotalDeathCount desc


--show continent with highest death count per population
select continent, max(cast(total_deaths as int)) as TotalDeathCount
from CovidDeaths
where continent is not null
group by continent
order by TotalDeathCount desc


--Global Deaths
select sum(new_cases) as total_cases, 
	sum(cast(new_deaths as int)) as total_deaths,
	sum(cast(new_deaths as int))/ sum(new_cases)*100 as DeathPercentage  
from CovidDeaths
where continent is not null
order by 1,2


--VACCINATIONS
-- total pop vs vaccination 
select dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		sum(cast(vac.new_vaccinations as bigint)) over 
		(partition by dea.location order by dea.location) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 2,3


--CTE 
With PopvsVac(Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		sum(cast(vac.new_vaccinations as bigint)) over 
		(partition by dea.location order by dea.location) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac


--temp table
drop table if exists #PercentPopulationVaccinated
create table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingPeopleVaccinated numeric
)
insert into #PercentPopulationVaccinated
select dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		sum(cast(vac.new_vaccinations as bigint)) over 
		(partition by dea.location order by dea.location) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
--where dea.continent is not null

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated



--creating view to store data for later visualizations 
create view PercentPopulationVaccinated as
select dea.continent,
		dea.location,
		dea.date,
		dea.population,
		vac.new_vaccinations,
		sum(cast(vac.new_vaccinations as bigint)) over 
		(partition by dea.location order by dea.location) as RollingPeopleVaccinated
from CovidDeaths dea
join CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null