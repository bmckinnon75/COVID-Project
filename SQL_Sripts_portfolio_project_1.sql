SELECT location, date, total_cases, new_cases, total_deaths, population
FROM dbo.CovidDeaths$
ORDER BY 1,2;

--Looking at Total Cases vs Total Deaths

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases) *100 AS deathpercentage
FROM dbo.CovidDeaths$
WHERE location LIKE ('%states%')
ORDER BY 1,2;

--Looking at Total Cases vs Population
SELECT location, date, population, total_cases, (total_cases/population) *100 AS contractedpercentage
FROM dbo.CovidDeaths$
WHERE location LIKE ('%states%') AND continent IS NOT NULL
ORDER BY 1,2;


--Looking at Countries with highest infection rate compared to population
SELECT location, population, MAX(total_cases) AS highestInfectionCount, MAX((total_cases/population)) *100 AS PercentPopulationInfected
FROM dbo.CovidDeaths$
--WHERE location LIKE ('%states%')
WHERE continent IS NOT NULL
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC


--Showing Countries with the highest death count per population
SELECT location, MAX(CAST(total_deaths AS int)) AS TotalDeathCount --MAX((total_deaths/population)) *100 AS deathrate
FROM dbo.CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY location 
ORDER BY TotalDeathCount DESC;

--SELECT location, continent
--FROM dbo.CovidDeaths$
--WHERE location in ('Europe', 'Asia', 'North America', 'Africa', 'World', 'South America', 'Australia', 'Antarctica')
--ORDER BY continent DESC;

--Break down by continent
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount --MAX((total_deaths/population)) *100 AS deathrate
FROM dbo.CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent 
ORDER BY TotalDeathCount DESC;


--Showing Continents with highest death count per population
SELECT continent, MAX(CAST(total_deaths AS int)) AS TotalDeathCount --MAX((total_deaths/population)) *100 AS deathrate
FROM dbo.CovidDeaths$
WHERE continent IS NOT NULL
GROUP BY continent 
ORDER BY TotalDeathCount DESC;



--GLobal numbers

SELECT SUM(new_cases) AS total_cases, SUM(CAST(new_deaths AS int))AS total_deaths, (SUM(CAST(new_deaths AS int))/SUM(new_cases))* 100 AS globaldeathpercentage --total_deaths, (total_deaths/total_cases) *100 AS deathpercentage
FROM dbo.CovidDeaths$
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2;



--Looking at Total Population vs Vaccinations
Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations AS int)) OVER ( PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population) * 100
FROM dbo.CovidDeaths$ deaths
JOIN dbo.CovidVaccinations$ vacc
	ON deaths.location = vacc.location
	AND deaths.date = vacc.date
WHERE deaths.continent IS NOT NULL
ORDER BY 2,3;




--USE CTE

WITH popvsvac (continent, location, date, population, new_vaccinations,RollingPeopleVaccinated)
AS
(Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations AS int)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population) * 100
FROM dbo.CovidDeaths$ deaths
JOIN dbo.CovidVaccinations$ vacc
	ON deaths.location = vacc.location
	AND deaths.date = vacc.date
WHERE deaths.continent IS NOT NULL)
--ORDER BY 2,3);
SELECT *, (RollingPeopleVaccinated/population) * 100 AS rollingvaccpercentage
FROM popvsvac;
--ORDER BY rollingvaccpercentage DESC;





-- Temp Table


DROP TABLE IF EXISTS PercentPopulationVaccinated
CREATE TABLE PercentPopulationVaccinated

(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT INTO PercentPopulationVaccinated

Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations AS int)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population) * 100
FROM dbo.CovidDeaths$ deaths
JOIN dbo.CovidVaccinations$ vacc
	ON deaths.location = vacc.location
	AND deaths.date = vacc.date
--WHERE deaths.continent IS NOT NULL

SELECT *, (RollingPeopleVaccinated/population) * 100 AS rollingvaccpercentage
FROM PercentPopulationVaccinated;




--Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinatedVIEW AS
Select deaths.continent, deaths.location, deaths.date, deaths.population, vacc.new_vaccinations,
SUM(CAST(vacc.new_vaccinations AS int)) OVER (PARTITION BY deaths.location ORDER BY deaths.location, deaths.date) AS RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population) * 100
FROM dbo.CovidDeaths$ deaths
JOIN dbo.CovidVaccinations$ vacc
	ON deaths.location = vacc.location
	AND deaths.date = vacc.date
WHERE deaths.continent IS NOT NULL;
--ORDER BY 2,3


SELECT*
FROM dbo.PercentPopulationVaccinatedVIEW;


