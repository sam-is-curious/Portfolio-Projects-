Select*
From dbo.CovidDeaths
order by 3,4
--Select*
--From dbo.CovidVaccinations
--order by 3,4

- Select Data that I will be using

Select location,date,total_cases, new_cases, total_deaths, population
From dbo.CovidDeaths
order by 1,2

-- Looking at total cases vs total deaths
-- Shows the likelihood of dying if you contract covid in your country

Select location,date,total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From dbo.CovidDeaths
Where location like '%states%'
order by 1,2

-- Looking at the total cases vs the population
-- Shows what percentage of population contracted covid

Select location, date, population, total_cases, (total_cases/population)*100 as PercentPopulationInfected
From dbo.CovidDeaths
Where location like '%states%'
order by 1,2


-- Looking at countries with highest infection rate compared to population

Select location, population, MAX(total_cases) as HighestInfectionCount, Max((total_cases/population))*100 as PercentPopulationInfected
From dbo.CovidDeaths
-- Where location like '%states%'
Group by location, population
order by PercentPopulationInfected desc

-- Showing Countries with the highest death count per population

Select location, MAX(cast(total_deaths as int)) as TotalDeathCount
From dbo.CovidDeaths
-- Where location like '%states%'
Where continent is not null
Group by location
order by TotalDeathCount desc

--LETS BREAK THINGS DOWN BY CONTINENT

-- Showing the continents with the highest death count
Select continent, MAX(cast(total_deaths as int)) as TotalDeathCount
From dbo.CovidDeaths
-- Where location like '%states%'
Where continent is not null
Group by continent
order by TotalDeathCount desc


-- Global Numbers

Select date,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From dbo.CovidDeaths
-- Where location like '%states%'
where continent is not null
group by date
order by 1,2

Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From dbo.CovidDeaths
-- Where location like '%states%'
where continent is not null
--group by date
order by 1,2

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
From CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location)
From CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3

Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location)
From CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
order by 2,3


--- Use CTE
With PopvsVac (Continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
Select *,(RollingPeopleVaccinated/population)*100
From PopvsVac

--Temp Table
Drop Table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated 
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location, dea.Date) as RollingPeopleVacecinated
--,(RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3)
Select *,(RollingPeopleVaccinated/population)*100
From #PercentPopulationVaccinated

-- Creating View to store date for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population,vac.new_vaccinations
, SUM(cast(vac.new_vaccinations as int)) OVER (partition by dea.location, dea.Date) as RollingPeopleVaccinated
--,(RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	on dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--order by 2,3

