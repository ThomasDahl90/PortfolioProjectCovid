--Select *
--From PortfoliaProject..['CovidDeaths']
--order by 3,4

--Select *
--FROM PortfoliaProject..CovidVaccinations
--ORDER BY 3,4

Select location, date, total_cases, new_cases, total_deaths, population
FROM PortfoliaProject..['CovidDeaths']
order by 1,2

-- looking at total cases vs total deaths
-- Shows likelyhood of dying if cathing covid
Select location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfoliaProject..['CovidDeaths']
Where location like '%Norway%'
Order by 1,2



Select location, date, total_cases, new_cases, total_deaths, (CONVERT(float,total_deaths)/NULLIF(convert(float,total_cases),0))*100 as DeathPercentage
FROM PortfoliaProject..['CovidDeaths']
order by 1,2

--SELECT *
--FROM PortfoliaProject..['CovidDeaths']

--Alter table PortfoliaProject..['CovidDeaths']
--Alter column new_cases float

-- Total cases vs population
-- Shows what percentage got covid in Norway
Select location, date, total_cases,population, (total_cases/population)*100 as PercetageInfected
FROM PortfoliaProject..['CovidDeaths']
Where location like '%Norway%'
Order by 1,2

-- looking at countries with highest infection rate compared to population	
Select location, population, MAX(total_cases), MAX((total_cases/population))*100 as PercetageInfected
FROM PortfoliaProject..['CovidDeaths']
Group by location, population
Order by 4 desc

-- Showing Countries with highest death count per population
Select location, population, total_deaths, MAX((total_deaths/population))*100 as DeathOverPopulation 
FROM PortfoliaProject..['CovidDeaths']
Group by location, population, total_deaths
Order by 4 desc

-- Showing Countries with highest total death
Select location, MAX(total_deaths) as TotalDeath
FROM PortfoliaProject..['CovidDeaths']
Where continent is not null
Group by location
Order by TotalDeath desc

-- Changing reproduction_rate from Nvarchar to Float
Alter table PortfoliaProject..['CovidDeaths']
Alter column reproduction_rate float


-- Removing groupings Continents from Countries
Select *
FROM PortfoliaProject..['CovidDeaths']
Where continent is not null
order by 3,4

-- BREAKING IT DOWN BY CONTINENT -- -- Showing continents with the highest death count per population
Select continent, MAX(total_deaths)*100 as TotalDeathCount
FROM PortfoliaProject..['CovidDeaths']
WHERE continent is not null
Group by continent
Order by TotalDeathCount desc


-- GLOBAL NUMBERS
Select SUM(new_cases) as totalcases, SUM(new_deaths) as totaldeaths, SUM(new_deaths)/ SUM(new_cases)*100 as DeathPercentage--total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfoliaProject..['CovidDeaths']
--Where location like '%Norway%'
Where continent is not null
Order by 1,2

-- Changing Error message when dividing by 0
SET Arithabort off
SET ansi_warnings off


-- Looking at Total Population vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RunningTotal
From PortfoliaProject..['CovidDeaths'] dea
Join PortfoliaProject..CovidVaccinations  vac
	on dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
Order by 1,2,3


-- USE CTE

With PopvsVac (Continent, location, date, Population, New_vaccinations, Runningtotal)
as 
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RunningTotal
From PortfoliaProject..['CovidDeaths'] dea
Join PortfoliaProject..CovidVaccinations  vac
	on dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null
--Order by 1,2,3
)

SELECT *, (Runningtotal/Population)*100 as RunningPercentage
From PopvsVac


-- TEMP TABLE
DROP Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric, 
RunningTotalVaccinated numeric
)


Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RunningTotal
From PortfoliaProject..['CovidDeaths'] dea
Join PortfoliaProject..CovidVaccinations  vac
	on dea.location = vac.location
	and dea.date = vac.date
	Where dea.continent is not null


-- Creating view to store data for later visualizations

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(Convert(int,vac.new_vaccinations)) OVER (Partition by dea.location order by dea.location, dea.date) as RunningTotal
From PortfoliaProject..['CovidDeaths'] dea
Join PortfoliaProject..CovidVaccinations  vac
	on dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null


Select *
From PercentPopulationVaccinated

