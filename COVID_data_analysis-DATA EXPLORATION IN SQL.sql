select * from portfollio_project..COVID_Deaths
order by 3,4
--select * from portfollio_project..covid_vac
--order by 3,4

--Selecting the data to be used.

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM portfollio_project..COVID_Deaths
ORDER BY 1,2

--Looking at the total_cases VS total_deaths
-- Likelihood of dying if we contract the covid in our country.
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as death_percentage
FROM portfollio_project..COVID_Deaths
WHERE location like '%india%'
ORDER BY 1,2

-- Looking at total_cases VS population
-- percentage of population got COVID.
SELECT location,date,total_cases,population,(total_cases/population)*100 as COVID_affected_percentage
FROM portfollio_project..COVID_Deaths
WHERE location like '%india%'
ORDER BY 1,2

-- Countries with highest infection rate 

SELECT location,population,MAX(total_cases) As Highest_infection_count,MAX((total_cases/population))*100 as percent_population_infected
FROM portfollio_project..COVID_Deaths
--WHERE location like '%india%'
GROUP BY location , population
--HAVING location = 'India'
ORDER BY Highest_infection_count DESC

-- Drilling down to the continent.

SELECT continent,MAX(cast(total_deaths as bigint)) AS total_death_count  
FROM portfollio_project..COVID_Deaths
--WHERE location like '%india%'
WHERE continent is not null
GROUP BY continent 
--HAVING location = 'India'
ORDER BY total_death_count DESC


-- Analysing globally
-- The total death percentage globally is around 2%.
SELECT SUM(new_cases) AS total_case,SUM(CAST(new_deaths as int)) AS total_deaths,SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS death_percentage_globally
FROM portfollio_project..COVID_Deaths
--WHERE location like '%india%'

SELECT * 
FROM portfollio_project..covid_vac
USE portfollio_project
ALTER TABLE covid_vac
DROP COLUMN F26

-- JOINING THE TABLES TOGETHER.

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
FROM portfollio_project..COVID_Deaths dea
JOIN portfollio_project..covid_vac vac
     ON dea.location=vac.location
	 and dea.date=vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2,3

--Rolling count of NEW VACCINATION

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rolling_count
FROM portfollio_project..COVID_Deaths dea
JOIN portfollio_project..covid_vac vac
     ON dea.location=vac.location
	 and dea.date=vac.date
WHERE dea.continent is NOT NULL
ORDER BY 2,3

--CTE (common table expression) to find the percentage of ppl vaccinated.

WITH PopVSvac (continent,location,date,population,new_vaccination,rolling_count)
AS
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rolling_count
FROM portfollio_project..COVID_Deaths dea
JOIN portfollio_project..covid_vac vac
     ON dea.location=vac.location
	 and dea.date=vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3
)
SELECT * ,( rolling_count/population)*100 as percent_vaccinated
FROM popvsvac
--WHERE location='india'

-- Creating a temp table 

DROP TABLE IF EXISTS #percentpopulationvaccinated
CREATE TABLE #percentpopulationvaccinated
(
continent nvarchar(300),
location nvarchar(255),
date datetime,
population bigint,
new_vaccinations bigint,
rolling_count bigint
)

INSERT INTO #percentpopulationvaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rolling_count
--( rolling_count/population)*100 as percent_vaccinated
FROM portfollio_project..COVID_Deaths dea
JOIN portfollio_project..covid_vac vac
     ON dea.location=vac.location
	 and dea.date=vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3
SELECT * ,( rolling_count/population)*100 as percent_vaccinated
FROM #percentpopulationvaccinated
--select * from #percentpopulationvaccinated

--Create a View for later visualizations.

CREATE VIEW POPULATION_VACCINATED AS
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location,dea.date) AS rolling_count
--( rolling_count/population)*100 as percent_vaccinated
FROM portfollio_project..COVID_Deaths dea
JOIN portfollio_project..covid_vac vac
     ON dea.location=vac.location
	 and dea.date=vac.date
WHERE dea.continent is NOT NULL
--ORDER BY 2,3

SELECT * 
FROM population_vaccinated