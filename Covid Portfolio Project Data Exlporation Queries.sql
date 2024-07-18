--Full Deaths Table
Select *
From ['Covid Deaths$']
Order by 3,4

--Full Vacc Table
select *
from ['Covid Vaccinations$']
order by 3,4


--Select Data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From ['Covid Deaths$']
Order by 1,2


--Looking at Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases), 0))*100 as DeathPercentage
From ['Covid Deaths$']
where location like '%states%'
	and total_deaths is not Null
Order by 1,2

----Failed first attempt at calculating Infection percentage of Pupulation
Select location, date, total_cases, population, (MAX(CONVERT(float, total_cases)), (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0))*100 as InfectionPercentage
From ['Covid Deaths$']
--where location like '%states%'
group by location, population
Order by 1,2


--Succesfull code for Infection percentage of Pupulation
SELECT 
    location, 
    date, 
    total_cases, 
    population, 
    MAX(CONVERT(float, total_cases)) as MaxTotalCases,
    (CONVERT(float, total_cases) / NULLIF(CONVERT(float, population), 0)) * 100 as InfectionPercentage
FROM ['Covid Deaths$']
-- WHERE location like '%states%'
GROUP BY location, date, total_cases, population
ORDER BY InfectionPercentage desc




--Showing Countries with Highest death Count per Population

Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
from ['Covid Deaths$']
where continent is not null
group by location 
order by TotalDeathCount desc


--Lets break it down by continent

Select continent, Max(cast(total_deaths as int)) as TotalDeathCount
from ['Covid Deaths$']
where continent is not null
group by continent
order by TotalDeathCount desc
----not fully accurate, as Oceania is not a continent


--More Accurate breakdown by continent that does not include income based results that are not geographic
Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
from ['Covid Deaths$']
where continent is null
		AND location not like '%income%'
group by location 
order by TotalDeathCount desc



----global numbers but with a divide by zero error
select date, sum(new_cases) as total_cases, Sum(Cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/sum(New_Cases)*100 as DeathPercentage
from ['Covid Deaths$']
where continent is not null
group by date
order by 1,2

--global numbers without divide by zero error
SELECT 
    date,
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS int)) AS total_deaths,
    CASE
        WHEN SUM(new_cases) = 0 THEN 0  -- Handle division by zero
        ELSE SUM(CAST(new_deaths AS int)) / NULLIF(SUM(new_cases), 0) * 100
    END AS DeathPercentage
FROM ['Covid Deaths$']
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date;



--Looking at Total Population vs Vaccinations
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
dea.date) as RollingNewVaccinations
from ['Covid Deaths$'] dea
join ['Covid Vaccinations$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
	AND vac.new_vaccinations IS NOT NULL
order by 2,3


--useing CTE

With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, RollingNewVaccinations)
as 
(select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
dea.date) as RollingNewVaccinations
from ['Covid Deaths$'] dea
join ['Covid Vaccinations$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
	AND vac.new_vaccinations IS NOT NULL
)

select *
from PopvsVac



--Create Temp table
Drop Table if exists #PercentPupulationVaccinated
Create Table #PercentPupulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date Datetime,
Population numeric,
New_vaccinations numeric,
RollingPoepleVaccinated numeric
)




--Create a VIEW to store data for later visuals!

Create view RollingNewVaccinations as
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(convert(bigint,vac.new_vaccinations)) over (Partition by dea.location order by dea.location,
dea.date) as RollingNewVaccinations
from ['Covid Deaths$'] dea
join ['Covid Vaccinations$'] vac
	on dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent IS NOT NULL
	AND vac.new_vaccinations IS NOT NULL
--order by 2,3



------queires used for porfolio project in tableau----------------------------------------------------------------------


SELECT 
    SUM(new_cases) AS total_cases,
    SUM(CAST(new_deaths AS int)) AS total_deaths,
    CASE
        WHEN SUM(new_cases) = 0 THEN 0  -- Handle division by zero
        ELSE SUM(CAST(new_deaths AS int)) / NULLIF(SUM(new_cases), 0) * 100
    END AS DeathPercentage
FROM ['Covid Deaths$']
WHERE continent IS NOT NULL
ORDER BY 1,2




Select Location, Max(cast(total_deaths as int)) as TotalDeathCount
from ['Covid Deaths$']
where continent is null
		AND location not like '%income%'
group by location 
order by TotalDeathCount desc



Select Location, Population,MAX(total_cases) as HightestInfectionCount, MAX((Total_cases/population))*100 as PercentPopulationInfected
From ['Covid Deaths$']
group by location,Population
order by PercentPopulationInfected Desc






Select Location, Population, date, MAX(total_cases) as HightestInfectionCount, MAX((Total_cases/population))*100 as PercentPopulationInfected
From ['Covid Deaths$']
group by location,Population, date
order by PercentPopulationInfected Desc
