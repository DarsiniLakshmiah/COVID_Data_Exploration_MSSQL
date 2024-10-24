# COVID-19 Data Exploration in SQL

## Overview
This project explores global COVID-19 data using SQL. The dataset includes information on COVID-19 cases, deaths, and vaccinations. The objective is to analyze infection rates, death rates, vaccination progress, and provide insights into how the pandemic affected different countries and continents.

## Datasets Used
- **COVID_Deaths**: Contains data on COVID-19 cases, deaths, and population for various countries and continents.
- **COVID_Vac**: Contains data on vaccinations administered across countries and continents.

## Key Analyses

### **Basic Data Exploration**
   Retrieve the basic information from the `COVID_Deaths` table for analysis:
   ```sql
   SELECT location, date, total_cases, new_cases, total_deaths, population
   FROM portfollio_project..COVID_Deaths
   ORDER BY location, date;
```
### COVID Death Rate Analysis
Analyze the likelihood of dying from COVID-19 by comparing total cases and total deaths for a specific country (India):

```sql
SELECT location, date, total_cases, total_deaths, (total_deaths / total_cases) * 100 AS death_percentage
FROM portfollio_project..COVID_Deaths
WHERE location LIKE '%india%'
ORDER BY location, date;
```
### Infection Rate vs. Population
Calculate the percentage of the population infected by COVID-19 for a given country:

```sql
SELECT location, date, total_cases, population, (total_cases / population) * 100 AS COVID_affected_percentage
FROM portfollio_project..COVID_Deaths
WHERE location LIKE '%india%'
ORDER BY location, date;
```
### Countries with the Highest Infection Rate
Identify the countries with the highest number of COVID-19 cases and the percentage of their population infected:

```sql
SELECT location, population, MAX(total_cases) AS Highest_infection_count, MAX((total_cases / population) * 100) AS percent_population_infected
FROM portfollio_project..COVID_Deaths
GROUP BY location, population
ORDER BY Highest_infection_count DESC;
```
### Continent-level Analysis
Analyze the total number of deaths for each continent:

```sql
SELECT continent, MAX(CAST(total_deaths AS bigint)) AS total_death_count
FROM portfollio_project..COVID_Deaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY total_death_count DESC;
```
### Global Death Percentage
Calculate the global death percentage from the available data:

```sql
SELECT SUM(new_cases) AS total_case, SUM(CAST(new_deaths AS int)) AS total_deaths, (SUM(CAST(new_deaths AS int)) / SUM(new_cases)) * 100 AS death_percentage_globally
FROM portfollio_project..COVID_Deaths;
```
### Joining COVID-19 Deaths and Vaccination Data
Merge the `COVID_Deaths` and `COVID_Vac` tables to analyze the relationship between deaths and vaccination efforts:

```sql
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM portfollio_project..COVID_Deaths dea
JOIN portfollio_project..covid_vac vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY location, date;
```
### Rolling Vaccination Count
Calculate the rolling sum of vaccinations administered over time using a window function:

```sql
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_count
FROM portfollio_project..COVID_Deaths dea
JOIN portfollio_project..covid_vac vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY location, date;
```
### Common Table Expression (CTE) to Calculate Vaccination Percentages
Use a CTE to calculate the percentage of the population vaccinated over time:

```sql
WITH PopVSvac (continent, location, date, population, new_vaccination, rolling_count) AS (
    SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
    SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_count
    FROM portfollio_project..COVID_Deaths dea
    JOIN portfollio_project..covid_vac vac ON dea.location = vac.location AND dea.date = vac.date
    WHERE dea.continent IS NOT NULL
)
SELECT *, (rolling_count / population) * 100 AS percent_vaccinated
FROM PopVSvac;
```
### Creating a Temporary Table
Create a temporary table to store the percentage of the population vaccinated for further analysis:

```sql
DROP TABLE IF EXISTS #percentpopulationvaccinated;
CREATE TABLE #percentpopulationvaccinated (
    continent NVARCHAR(300),
    location NVARCHAR(255),
    date DATETIME,
    population BIGINT,
    new_vaccinations BIGINT,
    rolling_count BIGINT
);

INSERT INTO #percentpopulationvaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_count
FROM portfollio_project..COVID_Deaths dea
JOIN portfollio_project..covid_vac vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
```
### Creating a View for Future Visualization
Create a view to analyze the percentage of population vaccinated:

```sql
CREATE VIEW POPULATION_VACCINATED AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CAST(vac.new_vaccinations AS bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS rolling_count
FROM portfollio_project..COVID_Deaths dea
JOIN portfollio_project..covid_vac vac ON dea.location = vac.location AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
```
## Technologies Used
- **SQL**: The primary tool used for querying, data manipulation, and transformation.
- **Microsoft SQL Server (MSSQL)**: The database management system used for running queries and storing data.

## Key Insights
- Infection rates and death percentages for countries and continents.
- Vaccination rates and their relationship to total COVID-19 cases.
- Rolling sum calculations to track vaccination progress over time.
- Data aggregation using window functions and CTEs.

## Conclusion
This project demonstrates the power of SQL for data exploration and analysis. By examining COVID-19 case data and vaccination trends, this analysis provides valuable insights into global and country-specific trends related to the pandemic.
