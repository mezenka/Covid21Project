--SELECT * FROM dbo.CovidDeaths ORDER BY 3,4

/*
SELECT * 
FROM dbo.CovidVaccinations 
--WHERE location NOT LIKE 'Afghanistan' 
WHERE continent IS NOT NULL AND location NOT LIKE 'Afghanistan'
ORDER BY 3,4 
*/
/*
SELECT
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	population
FROM dbo.CovidDeaths 
ORDER BY location,date
*/
--Total Cases vs Total Deaths - likelihood of dying of covid
/*
SELECT
	location,
	date,
	total_cases,
	new_cases,
	total_deaths,
	(total_deaths/total_cases)*100 AS death_perc
FROM dbo.CovidDeaths 
WHERE location LIKE '%poland%'
ORDER BY location,date
*/
--Total Cases vs Population
/*
SELECT
	location,
	--date,
	--total_cases,
	--new_cases,
	--total_deaths,
	--population,
	MAX((total_deaths/population)*100) AS death_pop	--MAX((total_deaths/population)*100) AS death_pop_max
FROM dbo.CovidDeaths 
GROUP BY location
--HAVING date LIKE '2021-04-18%'
ORDER BY MAX((total_deaths/population)*100) DESC
*/
--Countries with the highest infection rate compared to population
/*
SELECT
	location,
	population,
	MAX(total_cases) AS highest_inf_count,
	MAX((total_cases/population)*100) AS perc_pop_inf
FROM dbo.CovidDeaths
GROUP BY location, population
ORDER BY perc_pop_inf DESC
*/
--Countries with the highest deaths count per population
/*
SELECT
	location,
	MAX(CAST(total_deaths AS INT)) AS tot_deaths_count
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY tot_deaths_count DESC
*/
--Total deaths count by continent
/*--this one actually works correctly!
SELECT
	location,
	MAX(CAST(total_deaths AS INT)) AS tot_deaths_count
FROM CovidDeaths
WHERE continent IS NULL AND location NOT LIKE 'European Union'
GROUP BY location
ORDER BY tot_deaths_count DESC
*/
/*--this does not work
SELECT
	continent,
	MAX(CAST(total_deaths AS INT)) AS tot_deaths_count
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY tot_deaths_count DESC
*/
--GLOBAL NUMBERS
/*
SELECT
	location,
	date,
	total_cases,
	total_deaths,
	(total_deaths/total_cases)*100 AS deaths_perc
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2
*/
/*--GLOBAL DAILY NUMBERS
SELECT
	date,
	SUM(new_cases) AS total_cases,
	SUM(CAST(new_deaths AS INT)) AS total_deaths,
	SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS deaths_perc
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2
*/
/*
--TOTAL GLOBAL NUMBER
SELECT
	--date,
	SUM(new_cases) AS total_cases,
	SUM(CAST(new_deaths AS INT)) AS total_deaths,
	SUM(CAST(new_deaths AS INT))/SUM(new_cases)*100 AS deaths_perc
FROM CovidDeaths
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2
*/
--Total Vaccinations vs Population
/*
SELECT 
	d.continent,
	d.location,
	d.date,
	d.population,
	v.new_vaccinations,
	SUM(CAST(v.new_vaccinations AS INT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS vacc_aggr

FROM CovidDeaths d
JOIN CovidVaccinations v
ON d.location = v.location AND d.date = v.date
WHERE d.continent IS NOT NULL
ORDER BY 2,3
*/
--creating CTE (Common Table Expression)
/*
WITH VaccPop
	(
	continent,
	location,
	date,
	population,
	new_vaccinations,
	vacc_aggr
	)
AS
	(
	SELECT 
	d.continent,
	d.location,
	d.date,
	d.population,
	v.new_vaccinations,
	SUM(CAST(v.new_vaccinations AS INT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS vacc_aggr
		FROM CovidDeaths d
		JOIN CovidVaccinations v
		ON d.location = v.location AND d.date = v.date
		WHERE d.continent IS NOT NULL
		--ORDER BY 2,3
	)

SELECT *,
	(vacc_aggr/population)*100 AS vacc_percent
FROM VaccPop
*/
--Creating Temporary Table
/*
--DROP TABLE IF EXISTS PopulationVaccinated
CREATE TABLE PopulationVaccinated
	(
	continent nvarchar(255),
	location nvarchar(255),
	date datetime,
	population numeric,
	new_vaccinations numeric,
	vacc_aggr numeric
	)
INSERT INTO PopulationVaccinated
	SELECT 
	d.continent,
	d.location,
	d.date,
	d.population,
	v.new_vaccinations,
	SUM(CAST(v.new_vaccinations AS INT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS vacc_aggr
		FROM CovidDeaths d
		JOIN CovidVaccinations v
		ON d.location = v.location AND d.date = v.date
		WHERE d.continent IS NOT NULL
	
SELECT *,
	(vacc_aggr/population)*100 AS vacc_percent
FROM PopulationVaccinated
*/
--Create View for data visualisation 1:11:04
/*
CREATE VIEW PopulationVaccinatedPcnt AS
	SELECT 
	d.continent,
	d.location,
	d.date,
	d.population,
	v.new_vaccinations,
	SUM(CAST(v.new_vaccinations AS INT)) OVER (PARTITION BY d.location ORDER BY d.location, d.date) AS vacc_aggr
		FROM CovidDeaths d
		JOIN CovidVaccinations v
		ON d.location = v.location AND d.date = v.date
		WHERE d.continent IS NOT NULL
*/

SELECT * FROM PopulationVaccinatedPcnt