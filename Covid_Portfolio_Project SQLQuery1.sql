--Select *
--From Dataportfolio..CovidDeaths$
--order by 3,4

--Select *
--From Dataportfolio..CovidVaccines$
--order by 3,4


-- Selecting The Data that I will be using 

Select location, date, total_cases, new_cases, total_deaths, population
From Dataportfolio..CovidDeaths$
order by 1,2


-- Altering data types 
Alter Table [dbo].[CovidDeaths$]
Alter Column total_cases numeric(18,0)

Alter Table [dbo].[CovidDeaths$]
Alter Column total_deaths numeric(18,0)

-- looking at Total Cases vs Total Deaths.
Select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From Dataportfolio..CovidDeaths$
order by 1,2

--Filering by countries 
Select location, date, total_cases, total_deaths,(total_deaths/total_cases)*100 as DeathPercentage
From Dataportfolio..CovidDeaths$
Where location = 'Dominican Republic'
order by 1,2

-- looking at the total cases vs population
-- What % of the population has gotten covid 
Select location, date, total_cases, population, (total_cases/population)*100 As PercentofInfectedPopulation
From Dataportfolio..CovidDeaths$
Where location = 'Dominican Republic' and continent is not null
order by 1,2

-- countries with highest infection rate compared to population
Select location, population, MAX(total_cases) as HighestInfectionCount, max(total_cases/population)*100 as PercentofInfectedPopulation
From Dataportfolio..CovidDeaths$
--Where location = 'Dominican Republic'
Group by location, population
order by PercentofInfectedPopulation desc


-- Countries with highest Death count per population

-- countries with highest Death count
Select location, MAX(total_deaths) as TotalDeathcount 
From Dataportfolio..CovidDeaths$
-- if you have to cast to change data type ex: MAX(cast(total_deaths as int(datatype you want)
where continent is not null
Group by location
order by TotalDeathcount  desc

-- Continent with the Highest Death count.

Select continent, MAX(total_deaths) as TotalDeathcount 
From Dataportfolio..CovidDeaths$
where continent is not null
Group by continent
order by TotalDeathcount  desc

-- By location
Select location, MAX(total_deaths) as TotalDeathcount 
From Dataportfolio..CovidDeaths$
where continent is null
Group by location
order by TotalDeathcount  desc


--  Global Numbers
-- By date 
SET ARITHABORT OFF 
SET ANSI_WARNINGS OFF
Select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Dataportfolio..CovidDeaths$
Where continent is not null
group by date
order by 1,2

-- Whole world 
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
From Dataportfolio..CovidDeaths$
Where continent is not null
order by 1,2

-- Looking at total population vs Vaccination
-- Table JOINS

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
from Dataportfolio..CovidDeaths$ dea
 join Dataportfolio..CovidVaccines$ vac
   on dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
order by 2,3

-- Incresion vaccination numbers
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as Rolling_Vaccination_numbers,
from Dataportfolio..CovidDeaths$ dea
 join Dataportfolio..CovidVaccines$ vac
   on dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
order by 2,3

--CTE

With PopvsVac (continent, location, date, population,new_vaccinations, Rolling_Vaccination_numbers)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as int)) OVER (partition by dea.location order by dea.location, dea.date) as Rolling_Vaccination_numbers
from Dataportfolio..CovidDeaths$ dea
 join Dataportfolio..CovidVaccines$ vac
   on dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
)
select *, (Rolling_Vaccination_numbers/Population)*100
from PopvsVac


-- Temp Tables
Drop Table if exists #PercentPOPVAC
Create Table #PercentPOPVAC
(
continent nvarchar(255),
Location nvarchar(255),
Date datetime, population numeric,
new_vaccinations numeric,
Rolling_Vaccination_numbers numeric
)




Insert into #PercentPOPVAC
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea.date) as Rolling_Vaccination_numbers
from Dataportfolio..CovidDeaths$ dea
 join Dataportfolio..CovidVaccines$ vac
   on dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
select *, (Rolling_Vaccination_numbers/Population)*100
from #PercentPOPVAC


--- Create view data for vizualizations 
Create view PercentPOPVAC as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) OVER (partition by dea.location order by dea.location, dea.date) as Rolling_Vaccination_numbers
from Dataportfolio..CovidDeaths$ dea
 join Dataportfolio..CovidVaccines$ vac
   on dea.location = vac.location
   and dea.date = vac.date
Where dea.continent is not null
