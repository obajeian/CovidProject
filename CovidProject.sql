--- Welcome to a small project on COVID-19 data as of the year 2021.
--- In this project I aim to look at 2 tables; CovidDeaths & CovidVaccinations
--- I will explore the data in these tables and extrapolate insights from them.

--- This is the table with the CovidDeaths data
Select*
From CovidProject..CovidDeaths
Where continent is not null
order by 3,4

-- Select the Data we are going to be using 
Select location, date, new_cases, total_deaths, population
From CovidProject..CovidDeaths
order by 1,2

--Exploring Total cases against Total deaths
-- Explores the likelyhood of dying if one gets infected with Covid in their country
Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as death_rate
From CovidProject..CovidDeaths
Where location like '%Kenya%'
order by 1,2

-- Looking at Total cases vs popuation
-- How many people in Kenya got Covid
Select location, date, population, total_cases, (total_deaths/population)*100 as infection_rate
From CovidProject..CovidDeaths
Where location like '%Kenya%'
order by 1,2

-- Countries with highest infection rates in comparison to their population
 Select location, population, MAX(total_cases) as highest_infection, MAX((total_cases/population))*100 as infection_rate
From CovidProject..CovidDeaths
Group by location, population
order by infection_rate desc

--To show countries with the highest death count per population
Select location, population, MAX(cast(total_deaths as int)) as max_deaths
From CovidProject..CovidDeaths
Where continent is not null
Group by location, population, total_deaths
Order by max_deaths desc

-- BREAK INTO CONTINENTS

-- Displays the highest deathcount by continents
Select location, MAX(cast(total_deaths as int)) as max_deaths
From CovidProject..CovidDeaths
Where continent is null
Group by location
Order by max_deaths desc


-- GLOBAL NUMBERS
-- This looks at the total cases and deaths daily in the world
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, (SUM(cast(new_deaths as int))/ SUM(new_cases))*100 as death_rate
From CovidProject..CovidDeaths
Where continent is not null
Group by date
order by 1,2



--- Now let us introduce the second table on CovidVaccinations

Select*
From CovidProject..CovidVaccinations

-- Join the 2 tables
Select *
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date

-- Looking at the Total population vs the Vaccinations
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by 
 dea.location, dea.date) as total_people_vaxxed
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
Order by 2,3

	-- using cte to get the population vs vaccination
With PopvsVac (continent, location, date, population,new_vaccinations, total_people_vaxxed)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by 
 dea.location, dea.date) as total_people_vaxxed
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3
)
Select*, (total_people_vaxxed/population)*100
From PopvsVac

	-- Similar but with a TEMP table
Drop Table if exists #percentpopvaxxed
Create Table #percentpopvaxxed
(
continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
total_people_vaxxed numeric
)

Insert into #percentpopvaxxed
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by 
 dea.location, dea.date) as total_people_vaxxed
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
--Order by 2,3


Select*, (total_people_vaxxed/population)*100
From #percentpopvaxxed



--- Creating a view to store data for visualizations
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
 SUM(cast(vac.new_vaccinations as int)) OVER (Partition by dea.location Order by 
 dea.location, dea.date) as total_people_vaxxed
From CovidProject..CovidDeaths dea
Join CovidProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
Where dea.continent is not null
