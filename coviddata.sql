--SELECT location, date, total_cases, new_cases, total_deaths, population
--FROM PortfolioProject..coviddeath
--TOP 20
--ORDER BY 1,2;

--Total cases vs Total deaths 
SELECT location, date, total_cases, total_deaths, population, ((total_deaths/total_cases)*100) AS death_perct
FROM PortfolioProject..coviddeath
WHERE continent IS NOT NULL
AND location like '%states'
ORDER BY 1,2;

-- Total cases vs population
SELECT location, date, total_cases, total_deaths, population, ((total_cases/population)*100) AS infected_perc
FROM PortfolioProject..coviddeath
WHERE continent IS NOT NULL
WHERE location like '%states'
ORDER BY 1,2;

 --Countries with highest Infection raate compared to population
 SELECT location, MAX(total_cases) AS highest_infection_count, population, MAX(total_cases/population)*100 AS max_cases_infected
FROM PortfolioProject..coviddeath
--WHERE location like '%states'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY max_cases_infected DESC;

SELECT location, MAX(CAST(total_deaths AS INT)) AS highest_deaths_count
FROM PortfolioProject..coviddeath
--WHERE location like '%states'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY highest_deaths_count DESC;

-- Number deaths per population
SELECT location, MAX(total_deaths) AS highest_deaths_count, population, MAX(total_deaths/population)*100 AS max_cases_deaths
FROM PortfolioProject..coviddeath
--WHERE location like '%states'
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY max_cases_deaths DESC;

-- Group by continent
SELECT continent, MAX(CAST(total_deaths AS INT)) AS highest_deaths_count_continent
FROM PortfolioProject..coviddeath
--WHERE location like '%states'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY highest_deaths_count_continent DESC;

-- Showing contientns with the highest death count per population
SELECT continent, MAX(total_deaths) AS highest_deaths_count, population, MAX(total_deaths/population)*100 AS max_cases_deaths_continent
FROM PortfolioProject..coviddeath
--WHERE location like '%states'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY max_cases_deaths_continent DESC;

--Golabal Numbers

SELECT date, SUM(NEW_cases) AS total_cases_everyday, SUM(cast(new_deaths AS INT)) AS total_deaths_everyday, SUM(cast(new_deaths AS INT))/SUM(new_cases)*100 AS deaths_perc_by_date
FROM PortfolioProject..coviddeath
WHERE continent IS NOT NULL
--WHERE location like '%states'
GROUP BY date
ORDER BY 1,2; 

-- Join covid deaths and covid vaccinations together
--Total population vs vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER 
(PARTITION BY dea.location ORDER BY dea.date, dea.location) AS total_vaccinations_rolling, (total_vaccinations_rolling/population)*100 AS number_vac_per_population
FROM PortfolioProject..coviddeath AS dea
FULL OUTER JOIN PortfolioProject..covidvaccinations AS vac
	ON dea.date = vac.date
	AND dea.location = vac.location
WHERE dea.continent IS NOT NULL
ORDER BY 2,3;

--Use CTE
WITH popvsvac (continent, location, date, population, new_vaccination, total_vaccinations_rolling)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER 
(PARTITION BY dea.location ORDER BY dea.date, dea.location) AS total_vaccinations_rolling
FROM PortfolioProject..coviddeath AS dea
FULL OUTER JOIN PortfolioProject..covidvaccinations AS vac
	ON dea.date = vac.date
	AND dea.location = vac.location
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3;
)

SELECT*, (total_vaccinations_rolling/population)*100 AS number_vac_per_population
FROM popvsvac

--Temp table
DROP TABLE IF EXISTS #percentpopulationvacinated
CREATE TABLE #percentpopulationvacinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
total_vaccinations_rolling numeric, 
)
INSERT INTO #percentpopulationvacinated

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER 
(PARTITION BY dea.location ORDER BY dea.date, dea.location) AS total_vaccinations_rolling
FROM PortfolioProject..coviddeath AS dea
FULL OUTER JOIN PortfolioProject..covidvaccinations AS vac
	ON dea.date = vac.date
	AND dea.location = vac.location
--WHERE dea.continent IS NOT NULL
--ORDER BY 2,3;


SELECT*, (total_vaccinations_rolling/population)*100 AS number_vac_per_population
FROM #percentpopulationvacinated;

--create view to store data for later visualizations

CREATE VIEW percentpopulationvacinated AS

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(BIGINT, vac.new_vaccinations)) OVER 
(PARTITION BY dea.location ORDER BY dea.date, dea.location) AS total_vaccinations_rolling
FROM PortfolioProject..coviddeath AS dea
FULL OUTER JOIN PortfolioProject..covidvaccinations AS vac
	ON dea.date = vac.date
	AND dea.location = vac.location
WHERE dea.continent IS NOT NULL;
--ORDER BY 2,3;


SELECt *
FROM percentpopulationvacinated

