SELECT * 
FROM project..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY  3, 4

--SELECT * 
--FROM project..CovidVaccinations
--ORDER BY  3, 4


SELECT location, date, total_cases, new_cases, total_deaths, population
FROM project..CovidDeaths
ORDER BY 1,2


-- Total Cases Vs Total Deaths
--Shows likelihood of dying if you contract covid in your country
SELECT location, date, total_cases,  total_deaths, (total_deaths/ total_cases) * 100 AS DeathPercentage
FROM project..CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

-- Looking at total cases Vs population 
-- shows percentage of population contracted covid
SELECT location, date, population, total_cases, (total_cases/population) * 100 AS  Totalpercentage
FROM project..CovidDeaths
--WHERE Location LIKE '%states%'
ORDER BY 1,2


--Country with Highest Infection Rate compared to its population
SELECT location, population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)) * 100 AS  PercentagePopulationInfected
FROM project..CovidDeaths
--WHERE Location LIKE '%states%'
GROUP BY population, location
ORDER BY PercentagePopulationInfected DESC

-- Countries with the Highest Deaths counts per Population 

SELECT location , MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--Continent wise total deaths
--SELECT location , MAX(cast(total_deaths as int)) AS TotalDeathCount
--FROM project..CovidDeaths
--WHERE continent IS NULL
--GROUP BY location	
--ORDER BY TotalDeathCount DESC

-- Show Continents with highest deaths

SELECT continent , MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--GLOBAL Numbers
-- gives daily new cases added across the world
SELECT date, SUM(new_cases) AS TotalCases, SUM(CAST(new_deaths AS INT)) AS TotalDeaths , SUM (CAST(new_deaths AS INT))/ SUM(new_cases) * 100 AS DeathPrecentage
FROM project..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


-- Joining two tables based on dates and locations
-- Looking total population who are vaccinated
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccines.new_vaccinations, 
SUM(CAST(vaccines.new_vaccinations AS INT)) OVER (PARTITION BY vaccines.location ORDER BY vaccines.location, vaccines.date) AS RollingPeopleVaccinated,
--(RollingPeopleVaccinated/ population) * 100
FROM project..CovidDeaths deaths
JOIN project..CovidVaccinations vaccines
	ON deaths.location = vaccines.location AND deaths.date = vaccines.date
WHERE deaths.continent IS NOT NULL
ORDER BY 2,3

-- using CTE to calculate percentage of population vaccinated

WITH PopvsVac (continent, location, date, population,new_vaccinations, RollingPeopleVaccinated)
As
(
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccines.new_vaccinations, 
SUM(CAST(vaccines.new_vaccinations AS INT)) OVER (PARTITION BY vaccines.location ORDER BY vaccines.location, vaccines.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/ population) * 100
FROM project..CovidDeaths deaths
JOIN project..CovidVaccinations vaccines
	ON deaths.location = vaccines.location AND deaths.date = vaccines.date
WHERE deaths.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT * , (RollingPeopleVaccinated/ population) * 100
FROM PopvsVac


--WITH PopvsVac (continent, location, population,new_vaccinations, RollingPeopleVaccinated)
--As
--(
--SELECT deaths.continent, deaths.location,  deaths.population, vaccines.new_vaccinations, 
--SUM(CAST(vaccines.new_vaccinations AS INT)) OVER (PARTITION BY vaccines.location ORDER BY vaccines.location, vaccines.date) AS RollingPeopleVaccinated
----(RollingPeopleVaccinated/ population) * 100
--FROM project..CovidDeaths deaths
--JOIN project..CovidVaccinations vaccines
--	ON deaths.location = vaccines.location AND deaths.date = vaccines.date
--WHERE deaths.continent IS NOT NULL
----ORDER BY 2,3
--)
--SELECT * , (RollingPeopleVaccinated/ population) * 100
--FROM PopvsVac


--TEMP TABLE 
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
INSERT INTO #PercentPopulationVaccinated
SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccines.new_vaccinations, 
SUM(CAST(vaccines.new_vaccinations AS INT)) OVER (PARTITION BY vaccines.location ORDER BY vaccines.location, vaccines.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/ population) * 100
FROM project..CovidDeaths deaths
JOIN project..CovidVaccinations vaccines
	ON deaths.location = vaccines.location AND deaths.date = vaccines.date
WHERE deaths.continent IS NOT NULL
--ORDER BY 2,3

SELECT * , (RollingPeopleVaccinated/ population) * 100
FROM #PercentPopulationVaccinated


--VIEWS
-- creating views to store data for visualizations

CREATE VIEW PercentPopulationVaccinated1 AS 

SELECT deaths.continent, deaths.location, deaths.date, deaths.population, vaccines.new_vaccinations, 
SUM(CAST(vaccines.new_vaccinations AS INT)) OVER (PARTITION BY vaccines.location ORDER BY vaccines.location, vaccines.date) AS RollingPeopleVaccinated
--(RollingPeopleVaccinated/ population) * 100
FROM project..CovidDeaths deaths
JOIN project..CovidVaccinations vaccines
	ON deaths.location = vaccines.location AND deaths.date = vaccines.date
WHERE deaths.continent IS NOT NULL
--ORDER BY 2,3


SELECT * 
FROM PercentPopulationVaccinated1