

Select *
From PortfolioProjects..CovidDeaths$
Order by 3,4

Select *
From PortfolioProjects..CovidVaccinations$
Order by 3,4

Select iso_code, location, continent
From PortfolioProjects..CovidVaccinations$
Order by 1,2


--Select Data that we are going to be using

Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProjects..CovidDeaths$
Order by 1,2

--Looking at Total cases vs Total Daeths


Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProjects..CovidDeaths$
Where location like '%states%'
Order by 1,2

--Looking at Total cases vs population
--Shows what percentage of population got covid

Select Location, date, total_cases, population, (total_cases/population)*100 as PercentagePopulationInfected
From PortfolioProjects..CovidDeaths$
--Where location like '%states%'
Order by 1,2
--Looking at the highest infection rate compared to population

Select Location, population, Max(total_cases) as HighestInfectionCount,  Max(total_cases/population)*100 as 
PercentagePopulationInfected
From PortfolioProjects..CovidDeaths$
--Where location like '%states%'
Group by Location, population
Order by PercentagePopulationInfected desc

--Showing countries with Highst Deaths count pr population
Select Location, Max(Total_deaths) as TotalDeathCount
From PortfolioProjects..CovidDeaths$
--Where location like '%states%'
Group by Location
Order by TotalDeathCount desc

Select Location, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProjects..CovidDeaths$
--Where location like '%states%'
Group by Location
Order by TotalDeathCount desc

Select *
From PortfolioProjects..CovidDeaths$
Where continent is not null
Order by 3,4

--Breaking things down by continent
 
 Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProjects..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by continent
Order by TotalDeathCount desc

 Select location, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProjects..CovidDeaths$
--Where location like '%states%'
Where continent is null
Group by location
Order by TotalDeathCount desc

--Showing the continent with the highest death count per population


Select continent, Max(cast(Total_deaths as int)) as TotalDeathCount
From PortfolioProjects..CovidDeaths$
--Where location like '%states%'
Where continent is null
Group by continent
Order by TotalDeathCount desc

--Global Number
Select date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProjects..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Order by 1,2

--Aggregates Function

Select date, SUM(new_cases)-- total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From PortfolioProjects..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by date
Order by 1,2

Select date, SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(New_deaths as int))/SUM(New_cases)*100 
DeathPercentage
From PortfolioProjects..CovidDeaths$
--Where location like '%states%'
Where continent is not null
Group by date
Order by 1,2


Select SUM(new_cases) as Total_cases, SUM(cast(new_deaths as int)) as Total_deaths, SUM(cast(New_deaths as int))/SUM(New_cases)*100 
DeathPercentage
From PortfolioProjects..CovidDeaths$
--Where location like '%states%'
Where continent is not null
--Group by date
Order by 1,2

--Analysing CovidVaccinations

Select *
From PortfolioProjects..CovidVaccinations$

--Using Joins

Select *
From PortfolioProjects..CovidDeaths$ dea
Join PortfolioProjects..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date

--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProjects..CovidDeaths$ dea 
Join PortfolioProjects..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(Cast(vac.new_vaccinations as int)) over (partition by dea.location)
From PortfolioProjects..CovidDeaths$ dea 
Join PortfolioProjects..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3

--  OR
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(CONVERT( int,vac.new_vaccinations)) over (partition by dea.location)
From PortfolioProjects..CovidDeaths$ dea 
Join PortfolioProjects..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(CONVERT( int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
From PortfolioProjects..CovidDeaths$ dea 
Join PortfolioProjects..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
Order by 2,3

--Use CTE

With PopvsVac (continent, Location, Date, Population, New_vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(CONVERT( int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths$ dea 
Join PortfolioProjects..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
From PopvsVac

--Temp Table
Drop Table If exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(CONVERT( int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths$ dea 
Join PortfolioProjects..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null
--Order by 2,3
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated

--Creating View to store data for later visualization

Create view PercentpopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, Sum(CONVERT( int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date)
as RollingPeopleVaccinated
From PortfolioProjects..CovidDeaths$ dea 
Join PortfolioProjects..CovidVaccinations$ vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null
--Order by 2,3

Select *
From PercentpopulationVaccinated