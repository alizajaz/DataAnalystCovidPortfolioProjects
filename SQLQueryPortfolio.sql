SELECT *
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 3,4



--SELECT *
--FROM PortfolioProject..CovidVaccinations$
--ORDER BY 3,4

SELECT location,date, total_cases,new_cases,total_deaths,population
FROM PortfolioProject..CovidDeaths$
WHERE continent is not null
ORDER BY 1,2

--LOOKING AT TOTAL CASES VS TOTAL DEATHS
--Shows likelihood of dying if you contract covid in your country.
SELECT location,date, total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
Where location like'%states%'

ORDER BY 1,2


--Looking at Total Cases vs population
--show what population has get covid
SELECT location,date, total_cases,Population,(total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
Where location like'%states%'
ORDER BY 1,2

--Looking at Countries with Highest Infection Rate Compare to poulation
SELECT location,Population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population))*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths$
--Where location like'%states%'
GROUP BY location,Population
ORDER BY PercentPopulationInfected desc




--Showing countries with highest death count per population
SELECT location, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--Where location like'%states%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeathCount desc


--let's break down by continent

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--Where location like'%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc


--Showing continents with he highest death count.

SELECT continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths$
--Where location like'%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeathCount desc

--Global NUMBERS
SELECT SUM(new_cases) as total_cases,SUM(cast(new_deaths as int)) as total_deaths,SUM(cast(new_deaths as int)) /SUM(New_Cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths$
--Where location like'%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--Looking at Total population vs Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.Date)
AS RollingPeopleVaccinated

FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location=vac.location
and dea.date=vac.date
WHERE dea.continent is not null
ORDER by 1,2,3

--USE CTE
WITH PopvsVac(Continent,location,Date,Population, New_Vaccination,RollingPeopleVaccinated) AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CAST(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by dea.location, dea.Date)
AS RollingPeopleVaccinated

FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
ON dea.location=vac.location
and dea.date=vac.date
WHERE dea.continent is not null
--ORDER by 1,2,3
)
Select *,(RollingPeopleVaccinated/Population)*100
FROM PopvsVac


--Temp table
DROP table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations )) OVER (Partition by dea.location Order by dea.location, dea.Date)
AS RollingPeopleVaccinated

FROM PortfolioProject..CovidDeaths$ dea
JOIN PortfolioProject..CovidVaccinations$ vac
On dea.location=vac.location
and dea.date=vac.date;
--WHERE dea.continent is not null
--ORDER by 1,2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated
------ Using Temp Table to perform Calculation on Partition By in previous query


--DROP TABLE IF EXISTS #PercentPopulationVaccinated
--Create Table #PercentPopulationVaccinated
--(
--Continent nvarchar(255),
--Location nvarchar(255),
--Date datetime,
--Population numeric,
--New_vaccinations numeric,
--RollingPeopleVaccinated numeric
--);

--INSERT INTO #PercentPopulationVaccinated
--Select
--dea.continent, 
--dea.location, 
--dea.date, 
--dea.population, 
--vac.new_vaccinations,
--SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
----, (RollingPeopleVaccinated/population)*100
--FROM 
--PortfolioProject..CovidDeaths$ dea
--JOIN 
--PortfolioProject..CovidVaccinations$ vac
--ON
--	dea.location = vac.location
--	AND dea.date = vac.date
----where dea.continent is not null 
----order by 2,3

--SELECT *, (RollingPeopleVaccinated/Population)*100
--FROM #PercentPopulationVaccinated;














DROP TABLE IF EXISTS #PercentPopulationVaccinated;

-- Create the table with the correct column order
CREATE TABLE #PercentPopulationVaccinated
(
    Continent NVARCHAR(255),
    Location NVARCHAR(255),
    Date DATETIME,
    Population NUMERIC,
    New_vaccinations NUMERIC,
    RollingPeopleVaccinated NUMERIC
);

-- Insert data into the table
INSERT INTO #PercentPopulationVaccinated
SELECT
    dea.continent,
    dea.location,
    dea.date,
    dea.population,
    vac.new_vaccinations,
    SUM(CONVERT(INT, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.Date) AS RollingPeopleVaccinated
FROM
    PortfolioProject..CovidDeaths$ dea
JOIN
    PortfolioProject..CovidVaccinations$ vac
ON
    dea.location = vac.location
    AND dea.date = vac.date;

-- Select data from the table
SELECT *, (RollingPeopleVaccinated / Population) * 100
FROM #PercentPopulationVaccinated;
