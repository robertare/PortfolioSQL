SELECT * FROM Covidproject..Deaths

SELECT location, date, total_cases, new_cases, total_deaths, population 
FROM Covidproject..Deaths
ORDER BY 1,2;

--Looking at total cases vs total deaths 
-- how many people who had covid died?
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)
FROM Covidproject..Deaths
ORDER BY 1,2;

SELECT
  location,
  date,
  total_cases,
  total_deaths,
  CASE 
    WHEN total_cases = 0 THEN 0 -- Handle divide by zero
    ELSE (total_deaths / total_cases)*100
  END AS death_percentage
FROM
  Covidproject..Deaths
 WHERE location = 'United Kingdom'
ORDER BY
  1, 2;

  --Looking at population vs total cases
  --which percentage of the population have gotten covid
  SELECT
  location,
  date,
  population,
  total_cases,
  CASE 
    WHEN total_cases = 0 THEN 0 -- Handle divide by zero
    ELSE (total_cases/population)*100
  END AS covid_rate
FROM
  Covidproject..Deaths
  WHERE location = 'France'
ORDER BY
  1, 2;


  --Which countries available in data set
  SELECT DISTINCT location
FROM Covidproject..Deaths


--Looking at countries with highest infection rate compared to population
  SELECT
  location,
  population,
  MAX(total_cases) as HighestInfectionCount,
  MAX((total_cases/population))*100 AS PercentPopInfected
FROM
  Covidproject..Deaths
GROUP BY location, population
ORDER BY 4 DESC;

--Showing countries with highest death count per population

SELECT
  location,
  MAX(total_deaths) as TotalDeathCount
FROM
  Covidproject..Deaths
  WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount DESC;

--lets break things down by continent
SELECT
  continent,
  MAX(total_deaths) as TotalDeathCount
FROM
  Covidproject..Deaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;

SELECT
  location,
  MAX(total_deaths) as TotalDeathCount
FROM
  Covidproject..Deaths
WHERE continent is null
GROUP BY location
ORDER BY TotalDeathCount DESC;

--showing continents with highest death count per population
SELECT
  continent,
  MAX(total_deaths) as TotalDeathCount,
  MAX((total_deaths/population))*100 AS PercentDeathCount
FROM
  Covidproject..Deaths
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount DESC;

--global numbers
SELECT
 date, SUM(new_cases), SUM(new_deaths) --(total_deaths/total_cases)*100 as DeathPercentage
FROM Covidproject..Deaths
WHERE continent is not null
GROUP BY date
ORDER BY 1,2

SELECT
  date,
  SUM(new_cases) as TotalCases,
  SUM(new_deaths) as TotalDeaths,
  CASE WHEN SUM(new_cases) <> 0 THEN SUM(new_deaths) / SUM(new_cases) * 100 ELSE 0 END as DeathPercentage
FROM
  Covidproject..Deaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1, 2;

--without countries, more generally
  SELECT
  SUM(new_cases) as TotalCases,
  SUM(new_deaths) as TotalDeaths,
  CASE WHEN SUM(new_cases) <> 0 THEN SUM(new_deaths) / SUM(new_cases) * 100 ELSE 0 END as DeathPercentage
FROM
  Covidproject..Deaths
WHERE continent IS NOT NULL
ORDER BY 1, 2;


--join two tables together
SELECT*
FROM Covidproject..Deaths dea
JOIN Covidproject..Vaccines vac
ON dea.location = vac.location
AND dea.date = vac.date

--total population vs vaccination ie how many people from population vaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
FROM Covidproject..Deaths dea
JOIN Covidproject..Vaccines vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--add a column to add up the new vaccinations
--SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY 
--dea.location, dea.date) as RollingPeopleVaccinated,
--(RollingPeopleVaccinated/Population)*100
--FROM Covidproject..Deaths dea
--JOIN Covidproject..Vaccines vac
--ON dea.location = vac.location
--AND dea.date = vac.date
--WHERE dea.continent is not null
--ORDER BY 2,3
--above doesnt work beause cant use made up column i.e. rollingpeoplevaccinated


--Cant use newly created column to create population percentage column
-- USE CTE
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY 
dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
FROM Covidproject..Deaths dea
JOIN Covidproject..Vaccines vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac
Order by 7

--temp table
--to delete table and edit it DROP TABLE if exists #PercentPopulationVaccinated

Create Table #PercentPopulationVaccinated
(
Continent nvarchar(50),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY 
dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
FROM Covidproject..Deaths dea
JOIN Covidproject..Vaccines vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null

Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--creating view to store data for later visualisation
USE Covidproject
GO
Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition by dea.location ORDER BY 
dea.location, dea.date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/Population)*100
FROM Covidproject..Deaths dea
JOIN Covidproject..Vaccines vac
ON dea.location = vac.location
AND dea.date = vac.date
WHERE dea.continent is not null

-- to drop the above View : DROP VIEW PercentPopulationVaccinated;




--GO OVER VIEW FUNCTION and find the above one
---Video 2 
---store in Github, save as Sql file