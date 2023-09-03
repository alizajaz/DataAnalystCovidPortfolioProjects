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
