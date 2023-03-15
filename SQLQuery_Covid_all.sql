Select *
From PortfolioProject..coviddeaths
Where continent is not null
order by 3,4

--Select *
--From PortfolioProject..covidvaccinations
--order by 3,4

--COVIDDEATHS
--Select Data to be used for coviddeaths
Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..coviddeaths
Where continent is not null
order by 1,2

--First we need to change the column data type from nvarchar in columns where is suppose to be numeric.
ALTER TABLE [coviddeaths] ALTER COLUMN[population] [numeric]
ALTER TABLE [coviddeaths] ALTER COLUMN[total_cases] [numeric]
ALTER TABLE [coviddeaths] ALTER COLUMN[new_cases] [numeric]
ALTER TABLE [coviddeaths] ALTER COLUMN[new_cases_smoothed] [numeric]
ALTER TABLE [coviddeaths] ALTER COLUMN[total_deaths] [numeric]
ALTER TABLE [coviddeaths] ALTER COLUMN[new_deaths] [numeric]
ALTER TABLE [coviddeaths] ALTER COLUMN[new_deaths_smoothed] [numeric]
ALTER TABLE [coviddeaths] ALTER COLUMN[total_cases_per_million] [numeric]
ALTER TABLE [coviddeaths] ALTER COLUMN[new_cases_per_million] [numeric]
ALTER TABLE [coviddeaths] ALTER COLUMN[new_deaths_per_million] [numeric]
ALTER TABLE [coviddeaths] ALTER COLUMN[new_deaths_smoothed_per_million] [numeric]
ALTER TABLE [coviddeaths] ALTER COLUMN[reproduction_rate] [numeric]
ALTER TABLE [coviddeaths] ALTER COLUMN[icu_patients] [numeric]
ALTER TABLE [coviddeaths] ALTER COLUMN[icu_patients_per_million] [numeric]
ALTER TABLE [coviddeaths] ALTER COLUMN[hosp_patients] [numeric]
ALTER TABLE [coviddeaths] ALTER COLUMN[hosp_patients_per_million] [numeric]
ALTER TABLE [coviddeaths] ALTER COLUMN[weekly_icu_admissions] [numeric]
ALTER TABLE [coviddeaths] ALTER COLUMN[weekly_icu_admissions_per_million] [numeric]
ALTER TABLE [coviddeaths] ALTER COLUMN[weekly_hosp_admissions] [numeric]
ALTER TABLE [coviddeaths] ALTER COLUMN[weekly_hosp_admissions_per_million] [numeric]


--Looking at total_cases vs total_deaths (Calculating the percentage of death)

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From PortfolioProject..coviddeaths
Where continent is not null
order by 1,2

--To calculate the total_cases vs total_deaths in Malaysia.
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_percentage
From PortfolioProject..coviddeaths
WHERE location='Malaysia'
order by 1,2

--To calculate the total_cases vs population in Malaysia.
Select location, date, population, total_cases, total_deaths, (total_cases/population)*100 as MYR_infectionrate
From PortfolioProject..coviddeaths
WHERE location='Malaysia'
order by 1,2

--Looking at countries with highest infection rate and highest infection rate compared to population.
--Order by location, population.
Select location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as HighestInfectionRate
From PortfolioProject..coviddeaths
Where continent is not null
Group by location, population
order by 1,2

--Looking at countries with highest infection rate and highest infection rate compared to population.
--Order by highest infection rate.
Select location, population, MAX(total_cases) as HighestInfectionCount,  MAX((total_cases/population))*100 as HighestInfectionRate
From PortfolioProject..coviddeaths
Where continent is not null
Group by location, population
Order by HighestInfectionRate DESC

--Showing countries with highest death count per population.
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..coviddeaths
Where continent is not null
Group by location
Order by TotalDeathCount DESC

-- This code will return location which is not considered as a country
-- Entries like world, high income, low income, upper middle income, europe, asia, north america, south america, lower middle income.
-- We will add where clause statement "continent is not null" to display locations which are indicated by countries only to earlier queries for consistency.
Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..coviddeaths
Where continent is not null
Group by location
Order by TotalDeathCount DESC

--BREAKING DOWN DATA IN TERMS OF CONTINENT
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From PortfolioProject..coviddeaths
Where continent is not null
Group by continent
Order by TotalDeathCount DESC

--GLOBAL NUMBERS

-- We need to include a CASE statement for values where the value is NULL to avoid the following errors.
-- Msg 8134, Level 16, State 1, Line 110 Divide by zero error encountered.
Select date, SUM(new_cases) AS total_cases, SUM(new_deaths) AS total_deaths, 
	CASE WHEN SUM(new_cases)<>0 then (SUM(new_deaths)/(SUM(new_cases)*100))
	ELSE 0 END AS DeathPercentage
	From PortfolioProject..coviddeaths 
	Where continent is not null
	Group by date


-- We are going to join the covidvaccinations table

Select *
From PortfolioProject..coviddeaths dea --'dea' creates a alias for the joined table
Join PortfolioProject..covidvaccinations vac --'vac' creates a alias for the joined table
	On dea.location = vac.location
	and dea.date=vac.date

-- Looking at total population vs vaccinations

Select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
From PortfolioProject..coviddeaths dea --'dea' creates a alias for the joined table
Join PortfolioProject..covidvaccinations vac --'vac' creates a alias for the joined table
	On dea.location = vac.location
	and dea.date=vac.date
Where dea.continent is not null
order by 1,2,3

-- We want to total the new_vaccinations and partition it by location and order it by location and date.

Select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.Date) 
From PortfolioProject..coviddeaths dea --'dea' creates a alias for the joined table
Join PortfolioProject..covidvaccinations vac --'vac' creates a alias for the joined table
	On dea.location = vac.location
	and dea.date=vac.date
Where dea.continent is not null
order by 1,2,3

--running the above code returns error
--Msg 8115, Level 16, State 2, Line 130
--Arithmetic overflow error converting expression to data type int.
-- We will run the following CONVERT to int to BIGINT
-- We want to total the new_vaccinations and partition it by location and order it by location and date.

Select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.Date) as CumulativePeopleVaccinated
From PortfolioProject..coviddeaths dea --'dea' creates a alias for the joined table
Join PortfolioProject..covidvaccinations vac --'vac' creates a alias for the joined table
	On dea.location = vac.location
	and dea.date=vac.date
Where dea.continent is not null
order by 1,2,3


-- TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated

(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinationns numeric,
CumulativePeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.Date) as CumulativePeopleVaccinated
--(CumulativePeopleVaccinated/population)*100
From PortfolioProject..coviddeaths dea --'dea' creates a alias for the joined table
Join PortfolioProject..covidvaccinations vac --'vac' creates a alias for the joined table
	On dea.location = vac.location
	and dea.date=vac.date
Where dea.continent is not null
order by 1,2,3

-- To avoid errors Null value is eliminated by an aggregate or other SET operation. Run code below.
SET ANSI_WARNINGS OFF
GO

--Now that we have created a temp table #PercentPopulationVaccinated, we can calculate the percentage of population vaccinated.

Select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.Date) as CumulativePeopleVaccinated
--(CumulativePeopleVaccinated/population)*100
From PortfolioProject..coviddeaths dea --'dea' creates a alias for the joined table
Join PortfolioProject..covidvaccinations vac --'vac' creates a alias for the joined table
	On dea.location = vac.location
	and dea.date=vac.date
Where dea.continent is not null
order by 1,2,3

Select *, (CumulativePeopleVaccinated/population)*100 as PercentagePopulationVaccinated
FROM #PercentPopulationVaccinated


--Create View to store date to be used in Tableau (visualization)


Create View PercentPopulationVaccinated1 as
Select dea.continent, dea.location, dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(bigint,vac.new_vaccinations)) OVER (Partition by dea.location Order by dea.location,dea.Date) as CumulativePeopleVaccinated
--,(CumulativePeopleVaccinated/population)*100
From PortfolioProject..coviddeaths dea --'dea' creates a alias for the joined table
Join PortfolioProject..covidvaccinations vac --'vac' creates a alias for the joined table
	On dea.location = vac.location
	and dea.date=vac.date
Where dea.continent is not null
--order by 1,2,3

--To populate the view
Select *
From PercentPopulationVaccinated1