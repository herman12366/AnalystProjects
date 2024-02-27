# COVID-19 Analysis using SQL 
##### Author: Herman Singh 

### Scenario 
In response to the global COVID-19 pandemic, I embarked on a comprehensive data analysis project to assess the varying impacts of the virus across different regions. The dataset encompasses COVID-19 statistics, including cases, deaths, population figures, and vaccination data. The analysis aims to uncover patterns, trends, and key insights that can inform strategic decisions and public health interventions.

### Ask 
To seek a detailed report that delves into the nuances of the COVID-19 data analysis. The report should cover key aspects such as:
1. Total Cases vs Total Deaths
2. Total Cases vs Population:
3. Countries with Highest Infection Rate:
4. Countries with the Highest Death Count per Population:
5. Continental Analysis - Highest Death Count:
6. Global Overview:
7. Population vs Vaccinations:
8. Temporal Analysis of Vaccinations:

### Process 
The analysis began by retrieving COVID-19 data from the 'CovidDeaths' table, filtering out records where the continent is not specified. This initial exploration helped in understanding the structure and content of the dataset. 
```
SELECT *
  FROM PortfolioProject..CovidDeaths
  Where continent is not null
  order by 3,4;
Select Location, date, total_cases, new_cases, total_deaths, population
	From PortfolioProject..CovidDeaths 
	Order by 1,2;
```
Then start analysis of total cases vs total deaths was conducted, focusing on locations containing 'states' in their name. This provided insights into the likelihood of mortality if infected in specific regions.
```
-- Looking at Total Cases vs Total Deaths 
-- Shows the likelihood of dying if you get COVID in your country 
Select Location, date, total_cases,total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
	From PortfolioProject..CovidDeaths
	Where location like '%states%'
	and continent is not null 
	order by 1,2
```
Examining the relationship between total cases and population in the United States allowed for an understanding of the percentage of the population infected over time.
```
-- Total cases vs Population 
-- Shows the percentage of population got COVID 
Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
  From PortfolioProject..CovidDeaths
  Where Location = 'United States'
  order by 1,2;
```
Identification and ranking of countries with the highest infection rates relative to their population were performed, providing insights into the global impact of the virus.
```
--Countries with highest Infection Rate compared to Population 
Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
	From PortfolioProject..CovidDeaths
	Group by Location, Population
	order by PercentPopulationInfected desc;
```
The focus shifted to countries with the highest death count per capita, offering valuable information for assessing the severity of the pandemic in different regions.
```
Select Location, MAX(cast(Total_deaths as bigint)) as TotalDeathCount
  From PortfolioProject..CovidDeaths
  Where continent is not null 
  Group by Location
  order by TotalDeathCount desc;
```
Breaking down the data by continent allowed for an examination of continents with the highest death counts, aiding in understanding the regional impact of COVID-19.
```
-- Let's breake things down by Continent 
-- Continents with the highest death count 
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
	From PortfolioProject..CovidDeaths
	Where continent is not null 
	Group by continent
	order by TotalDeathCount desc;
```
A global overview of key statistics, including total cases, total deaths, and death percentage, was generated to provide a comprehensive perspective on the overall impact of the pandemic.
```
-- Global Numbers 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
	From PortfolioProject..CovidDeaths
	where continent is not null 
	order by 1,2;
```
Population vs vaccinations analysis was initiated to explore the percentage of the population that has received at least one COVID-19 vaccine dose.
```
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
```
A Common Table Expression (CTE) was utilized to perform temporal analysis of vaccinations, offering insights into the rolling count of people vaccinated over time.
```
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
```
Temporary tables and views were created to store data for later visualizations, enhancing the interpretability and presentation of key insights.
```
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
```
### Analyze 
![COVIDdeathcount](https://github.com/herman12366/AnalystProjects/assets/20954773/c189387d-b585-45aa-8cfd-9bcff640f1af)
From the first query that was excuted we can see that the highest death rate was 8.696% in May of 2020 in the United States. As the time increases we can see a steady decline in the death percentage due to COVID. 

![Percentinfected](https://github.com/herman12366/AnalystProjects/assets/20954773/78b0bb91-0df8-42cd-a017-d76000388971)
The data collected from the percent infected tells a different story compared to the death percentage. For the death percentage, the data looked more like a bell curve. Originally, the death percentage started increasing and after reaching it's peak it started declining. However, with this data we can see that the percentage of infected people have increased ever since and has not slowed down. 

![Percentinfectedworld](https://github.com/herman12366/AnalystProjects/assets/20954773/bf21deaf-4da6-4f69-ba74-1a30e522b6ad)
Just like the last query that was executed this one shows the highest infection percentage based on countries. We can see major countries having a high infection rate like France compared to other nations. 

![deathcountworld](https://github.com/herman12366/AnalystProjects/assets/20954773/0f6cb87b-7873-46b4-b7c7-ad576f5df410)
This query resulted in showing use the highest death percentage based on countries. Again we can see major countries being listed on this list. United States being the highest followed by countries like India, Germany, France, and many more. 

https://public.tableau.com/views/CovidDashboard_16976059943100/Dashboard1?:language=en-US&:sid=&:display_count=n&:origin=viz_share_link
The dashboard created displays the data that was collected throughout the queries with a forecast projection for major counties. 

### Conclusion 
In the pursuit of unraveling COVID-19 trends, the data analysis journey has revealed crucial insights that transcend mere statistics. Through an array of SQL queries, we scrutinized infection and mortality rates, vaccine distribution dynamics, and regional disparities. We can use the data collected to better prepare for the future and use forecasting tools to predict the percentage infected. Based on the data, it is likely that the percentage of infected will keep on growing. However, if the right steps are taken we can continue to decrease the death percentage stat over time. 
