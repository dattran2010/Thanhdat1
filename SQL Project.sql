
Select *
from dbo.CovidDeath
order by continent asc

-- Select Data that I'm going to be using 

Select location, date, total_cases, new_cases, total_deaths, population
from dbo.CovidDeath
where continent is not null
order by 1,2

--convert into float datatype when ''Null" 

Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from dbo.CovidDeath
where continent is not null
order by 1,2

-- looking at total cases vs total Deaths and shows likelihood of dying if you contract the covid in your country
-- convert into float datatype when ''Null" 

Select location, date, total_cases,total_deaths, 
(CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0)) * 100 AS Deathpercentage
from dbo.CovidDeath
where location like '%vie%' and continent is not null
order by 1,2

-- looking total cases vs Population
-- shows what the percentage of population get Covid
Select location, date, total_cases, population, (total_cases/population)*100 as percentofpopulation
from dbo.CovidDeath
where location like '%Vie%' and continent is not null
order by percentofpopulation asc

-- looking at with country with highest infections rate compared to population
Select location,population, Max (total_cases) as MaxCases, max ((total_cases/population)*100) as percentofpopulation
from dbo.CovidDeath
where continent is not null
group by location,population
Order by percentofpopulation desc

-- Showing Countries with Highest Death Count per Population
Select location, Max(Cast(total_deaths as int)) as TotalDeathcount
from dbo.CovidDeath
where continent is not null
group by location,population
Order by TotalDeathcount desc

--Break things Down by location

Select location, Max(Cast(total_deaths as int)) as TotalDeathcount
from dbo.CovidDeath
where continent is null
group by location
Order by TotalDeathcount desc

-- Showing continent with the highest death count per population.
Select location, Max(total_deaths/population)*100 as Deathperpop
from dbo.CovidDeath
where continent is null and location not like '%income%'
group by location
Order by Deathperpop desc

-- Global number about total cases, total death and total deaths per total cases
Select sum(cast(total_cases as bigint)) as totalcases, sum(cast (total_deaths as bigint)) as totaldeaths, sum(cast (total_deaths as bigint))/sum(cast(total_cases as bigint)) as deathspercases
from dbo.CovidDeath
where continent is not null


Select *
from dbo.CovidVaccination

-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(bigint,vac.people_vaccinated)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From dbo.CovidDeath as dea
Join dbo.CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Using CTE to perform Calculation on Partition By in previous query

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, PeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, CONVERT(bigint,vac.people_vaccinated) as PeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From dbo.CovidDeath as dea
Join dbo.CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by vac.people_vaccinated
)
Select *, (PeopleVaccinated/Population)*100 as Percentage
From PopvsVac
where (PeopleVaccinated/Population)*100 is not null
order by (PeopleVaccinated/Population)*100 Desc



-- Using Temp Table to perform Calculation on Partition By in previous query

DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
PeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, CONVERT(bigint,vac.people_vaccinated) as PeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From dbo.CovidDeath as dea
Join dbo.CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (PeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
where (PeopleVaccinated/Population)*100 is not null
order by (PeopleVaccinated/Population)*100 desc




-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, CONVERT(bigint,vac.people_vaccinated) as PeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From dbo.CovidDeath dea
Join dbo.CovidVaccination vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 








