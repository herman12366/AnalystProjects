 SELECT *
  FROM PortfolioProject..CovidDeaths
  Where continent is not null
  order by 3,4;

Select Location, date, total_cases, new_cases, total_deaths, population
	From PortfolioProject..CovidDeaths 
	Order by 1,2;

-- Looking at Total Cases vs Total Deaths 
-- Shows the likelihood of dying if you get COVID in your country 
Select Location, date, total_cases,total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
	From PortfolioProject..CovidDeaths
	Where location like '%states%'
	and continent is not null 
	order by 1,2

-- Total cases vs Population 
-- Shows the percentage of population got COVID 
Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
  From PortfolioProject..CovidDeaths
  Where Location = 'United States'
  order by 1,2;

--Countries with highest Infection Rate compared to Population 
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
	From PortfolioProject..CovidDeaths
	Group by Location, Population
	order by PercentPopulationInfected desc;

-- Countries with Highest Death Count per Population
Select Location, MAX(cast(Total_deaths as bigint)) as TotalDeathCount
  From PortfolioProject..CovidDeaths
  Where continent is not null 
  Group by Location
  order by TotalDeathCount desc;

-- Let's breake things down by Continent 
-- Continents with the highest death count 
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
	From PortfolioProject..CovidDeaths
	Where continent is not null 
	Group by continent
	order by TotalDeathCount desc; 

-- Global Numbers 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
	From PortfolioProject..CovidDeaths
	where continent is not null 
	order by 1,2;
	
-- Total Population vs Vaccinations
-- Shows Percentage of Population that has recieved at least one Covid Vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
	From PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null 
	order by 2,3;

-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingPeopleVaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
	From PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null 
)
Select *, (RollingPeopleVaccinated/Population)*100
	From PopvsVac

-- Temp Table 
DROP Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
	From PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
Select *, (RollingPeopleVaccinated/Population)*100
	From #PercentPopulationVaccinated;

-- Creating View to store data for later visualizations
Create View 
PercentPopulationVaccinated
AS
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
	, SUM(CAST(vac.new_vaccinations as bigint)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
	From PortfolioProject..CovidDeaths dea
	Join PortfolioProject..CovidVaccinations vac
		On dea.location = vac.location
		and dea.date = vac.date
	where dea.continent is not null;
