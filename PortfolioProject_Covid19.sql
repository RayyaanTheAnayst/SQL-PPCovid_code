
SELECT*
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4


SELECT*
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

-- Select DATA that we are going to be using

SELECT Location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2


-- CALL UP ALL DATA RELATED TO SOUTH AFRICA

SELECT Location, date, total_cases, new_cases, total_deaths, population, new_deaths
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%SOUTH AFRICA%' 
ORDER BY 1,2

-- PERCENTAGE change in NEW CASES labled PercIncOfNewCases

SELECT Location, date, total_cases, new_cases, total_deaths, population, new_deaths, (new_cases/total_cases)*100 AS PercIncOfNewCases
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%SOUTH AFRICA%' 
ORDER BY 1,2

-- INFECTION RATE OF COVID IN SOUTH AFRICA
-- PERCENTAGE change in NEW CASES labled PercIncOfNewCases
-- DEATH RATE IN SA


SELECT Location, date, population, total_cases, new_cases, new_deaths, total_deaths,
(total_cases/population)*100 AS Infection_Rate,
(new_cases/total_cases)*100 AS PercIncOfNewCases, 
(total_deaths/total_cases)*100 AS DeathRate
FROM PortfolioProject..CovidDeaths
WHERE location like '%South Africa%'
ORDER BY 1,2



--LOOKING AT TOTAL CASES VS TOTAL DEATHS & NAMING THAT TOTAL AS DeathPercentage
--- Shows the percentage chance of dying from COVID

SELECT Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%South Africa%'
ORDER BY 1,2

--LOOKING AT TOTAL CASES VS POPULATION
--- Shows percentage of population infected with COVID19

SELECT Location, date, population, total_cases, (total_cases/population)*100 AS Infection_Rate
FROM PortfolioProject..CovidDeaths
WHERE location like '%South Africa%'
ORDER BY 1,2


--LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION

SELECT Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS Infection_Rate
FROM PortfolioProject..CovidDeaths
--WHERE location like '%South Africa%'
GROUP BY Location, Population
ORDER BY Infection_Rate desc

--SHOW COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION
-- {total deaths was (nvarchae255) therefore had to cast as int}
-- {Continents showing us as locations bcoz of null values 'IS NOT NULL' WAS USED}

SELECT Location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%South Africa%'
WHERE continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount desc


--  SORT BY CONTINENT --
-- Showing continents with the highest DEATH COUNTS

 SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
--WHERE location like '%South Africa%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount desc


-- GLOBAL NUMBERS
-- Showing Total Cases and percentage tolal deaths Globaly perday

SELECT date, SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%South Africa%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


-- AS OF 15 JULY 2021 TOTAL DEATH PERCENTAGE GLOBALLY 

SELECT  SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
--WHERE location like '%South Africa%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2



-- TOTAL POPULATION VS VACCINATION
--JOIN PORTFOLIO..COVIDDEATHS TO PORTFOLIOPROJECT..COVIDVACCINATIONS ON LOCATION AND DATE

SELECT*
FROM PortfolioProject..CovidDeaths
JOIN PortfolioProject..CovidVaccinations
	ON PortfolioProject..CovidDeaths.location = PortfolioProject..CovidVaccinations.location
	AND PortfolioProject..CovidDeaths.date = PortfolioProject..CovidVaccinations.date

	--{renaming to dea and vac for simplicity}

	SELECT*
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date

	--LOOKING AT TOTAL POPULATION VS VACCINATIONS
-- { CASTE/ CONVERT, PARTITIONED

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3


--USE CTE

WITH PopvsVac (Continent,Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
Select*, (RollingPeopleVaccinated/Population)*100 AS PercentagePopulation
From PopvsVac


-- CREATE TEMP TABLE 

DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar (255),
Date datetime,
Population numeric, New_Vaccinations numeric,
RollingPeopleVaccinated numeric, 
)


INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3

Select*, (RollingPeopleVaccinated/Population)*100 AS PercentagePopulation
From #PercentPopulationVaccinated


-- CREATE VIEW FOR LATER VISUALS

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(INT,vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
FROM PortfolioProject..CovidDeaths dea
JOIN PortfolioProject..CovidVaccinations vac
	ON dea.location = vac.location
	AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3


SELECT*
FROM PercentPopulationVaccinated



--CREATE VIEW OF SA DEATH INFO


CREATE VIEW SACovidDeathInfo AS 
SELECT Location, date, population, total_cases, new_cases, new_deaths, total_deaths,
(total_cases/population)*100 AS Infection_Rate,
(new_cases/total_cases)*100 AS PercIncOfNewCases, 
(total_deaths/total_cases)*100 AS DeathRate
FROM PortfolioProject..CovidDeaths
WHERE location like '%South Africa%'
--ORDER BY 1,2

SELECT*
FROM SACovidDeathInfo


-- VACCINATIONS

SELECT*
FROM PortfolioProject..CovidVaccinations

-- South Africa Vaccination Data


SELECT*
FROM PortfolioProject..CovidVaccinations
WHERE location LIKE '%SOUTH AFRICA%'


CREATE VIEW SouthAfricaVaccinations AS 
SELECT*
FROM PortfolioProject..CovidVaccinations
WHERE location LIKE '%SOUTH AFRICA%'

--% POPULATION VACCINATED IN South Africa OVER TIME

SELECT location, date, new_vaccinations, total_vaccinations, population, (total_vaccinations/population)*100 AS population_vaccinated
FROM SouthAfricaVaccinations 
WHERE total_vaccinations IS NOT NULL
ORDER BY date 



--- DATA FOR SOUTH AFRICA FOR VISUAL DISPLAY--
--1.  TOTAL CASES, TOTAL DEATHS and COVID DEATH PERCENTAGE 

SELECT Location, date, total_cases, new_cases, total_deaths, population, new_deaths
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%SOUTH AFRICA%' 
ORDER BY 1,2

--- TOTAL CASES OF COVID TO DATE

SELECT location, date, total_cases, new_cases, total_deaths, population, new_deaths
FROM PortfolioProject..CovidDeaths
WHERE location LIKE '%SOUTH AFRICA%' --AND date LIKE '%2021-07-15%'
ORDER BY date DESC


SELECT date, location,population, total_tests, total_vaccinations,	new_vaccinations
FROM PortfolioProject..CovidVaccinations
WHERE location LIKE 'SOUTH AFRICA'
ORDER BY date DESC



--- VIEWS for Tableau 

--1 Global Death percentage

SELECT location, total_cases  AS, SUM(CAST(new_deaths AS int)) AS TOTAL_DEATHS
FROM PortfolioProject..CovidDeaths
GROUP BY new_deaths, location



CREATE VIEW GlobalDeathPercentage AS
SELECT date, location, SUM(new_cases) AS Total_Cases, SUM(CAST(new_deaths AS INT)) AS Total_deaths, SUM(CAST(new_deaths AS int))/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%South Africa%'
--WHERE continent IS NOT NULL
==GROUP BY date, location
ORDER BY 1,2


-- 2 Total cases per African Country

CREATE VIEW Total_caese_per_African_country AS
SELECT iso_code, population, max(total_cases) AS TotalCases
FROM PortfolioProject..CovidDeaths
WHERE continent LIKE '%AFRICA%'
GROUP BY population, iso_code


-- 3 Location Africa infections VS population
CREATE VIEW tab_AfricanInfectionRate AS
SELECT location, iso_code, population, max(total_cases) AS Total_Cases, (max(total_cases)/population)*100 AS InfectionRate
FROM PortfolioProject..CovidDeaths
WHERE continent LIKE '%AFRICA%'
GROUP BY location, population, iso_code

-- 4 Location Africa Death VS Cases

CREATE VIEW tab_AfricanDeathRate AS

SELECT iso_code,location,	MAX(total_deaths) AS Total_Deaths, 
							MAX(total_cases) AS Total_cases,  
							MAX(total_deaths)/MAX(total_cases)*100 AS Death_Rate
FROM PortfolioProject..CovidDeaths
WHERE continent LIKE '%AFRICA%'
GROUP BY iso_code,location
ORDER BY Death_Rate DESC






--5 ** Vaccinations South Africa and Africa--

-- VACCINATIONS TIME SERIES GRAPH

CREATE VIEW tab_AfricanVaccines AS

SELECT date, iso_code, location, population, total_vaccinations
FROM PortfolioProject..CovidVaccinations
WHERE location like '%south africa%'  or location like '%namibia%' or location like '%zambia%' or location like '%nigeria%' 
   or location like '%moroc%' or location like '%Egypt%' or location like '%somalia%' or location like '%zembabwe%' 
	and  total_vaccinations IS NOT NULL
GROUP BY iso_code, location, date, population, total_vaccinations
--ORDER BY location asc


SELECT*
FROM dbo.tab_AfricanDeathRate

SELECT*
FROM dbo.tab_AfricanInfectionRate

SELECT*
FROM dbo.tab_AfricanVaccines

SELECT*
FROM dbo.tab_Total_caese_per_African_country

SELECT*
FROM dbo.GlobalDeathPercentage




Queries used for Tableau Project
*/



-- 1. 

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
--Where location like '%states%'
where continent is not null 
--Group By date
order by 1,2

-- Just a double check based off the data provided
-- numbers are extremely close so we will keep them - The Second includes "International"  Location


--Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
--From PortfolioProject..CovidDeaths
----Where location like '%states%'
--where location = 'World'
----Group By date
--order by 1,2


-- 2. 

-- We take these out as they are not inluded in the above queries and want to stay consistent
-- European Union is part of Europe

Select location, SUM(cast(new_deaths as int)) as TotalDeathCount
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Where continent is null 
and location not in ('World', 'European Union', 'International')
Group by location
order by TotalDeathCount desc


-- 3.

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population
order by PercentPopulationInfected desc


-- 4.


Select Location, Population,date, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From PortfolioProject..CovidDeaths
--Where location like '%states%'
Group by Location, Population, date
order by PercentPopulationInfected desc

-- 5. SOUTHAFRICA, USA, UK, BRAZIL, INDIA TIMELINE OF NEW CASES

SELECT location, date, new_cases
FROM PortfolioProject..CovidDeaths
Where location like '%south africa%' or location like '%states%' or location like '%united kingdom%' 
   or location like '%austrailia%' or location like '%india%' or location like '%brazil%'