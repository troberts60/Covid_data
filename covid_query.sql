

Select *
From portfolio_project..covid_vax
Where continent is not null
order by 3,4

Select location, date, total_cases, new_cases, total_deaths, population
From portfolio_project..covid_deaths
order by 1,2

-- Total Cases vs Total Deaths

Select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From portfolio_project..covid_deaths
Where location = 'United States'
order by 1,2

-- Total Cases vs Population
Select location, date, total_cases, population, (total_cases/population)*100 as InfectedPercentage
From portfolio_project..covid_deaths
Where location = 'United States'
order by 1,2

-- Countries with highest infection rates compared to population
Select location, population, MAX(total_cases), MAX((total_cases/population))*100 as InfectedPercentage
From portfolio_project..covid_deaths
--Where location = 'United States'
GROUP BY Location, Population
order by InfectedPercentage desc

-- Highest Death Count per Population
Select location, MAX(cast(total_deaths as int)) as TotalDeaths, MAX((total_deaths/population))*100 as DeathPercentage
From portfolio_project..covid_deaths
Where continent is not null
GROUP BY Location
order by TotalDeaths desc

-- Highest Death Count by Continent
Select location, MAX(cast(total_deaths as int)) as TotalDeaths, MAX((total_deaths/population))*100 as DeathPercentage
From portfolio_project..covid_deaths
Where continent is null AND location not like '%income%'
		AND location != 'European Union' AND 
		location != 'International' AND location != 'World'
GROUP BY Location
order by TotalDeaths desc

-- Global cases and deaths per day
Select date, SUM(new_cases) as Cases, SUM(cast(new_deaths as int)) as Deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
From portfolio_project..covid_deaths
Where continent is not null
Group by date
order by date

-- Global cases and deaths total
Select SUM(new_cases) as Cases, SUM(cast(new_deaths as int)) as Deaths, SUM(cast(new_deaths as int))/SUM(new_cases) * 100 as DeathPercentage
From portfolio_project..covid_deaths
Where continent is not null

-- Covid vax table
Select deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations,
SUM(cast(vax.new_vaccinations as bigint)) OVER(PARTITION BY deaths.location order by deaths.date, deaths.location) as TotalVax
From portfolio_project..covid_deaths deaths
Join portfolio_project..covid_vax vax
ON vax.location = deaths.location and vax.date = deaths.date
Where deaths.continent is not null
order by 2,3

-- Population vaccianted per day
with RollingVax (continent, location, date, population, new_vaccinations, TotalVax) as
(
Select deaths.continent, deaths.location, deaths.date, deaths.population, vax.new_vaccinations,
SUM(cast(vax.new_vaccinations as bigint)) OVER(PARTITION BY deaths.location order by deaths.date, deaths.location) as TotalVax
From portfolio_project..covid_deaths deaths
Join portfolio_project..covid_vax vax
ON vax.location = deaths.location and vax.date = deaths.date
Where deaths.continent is not null
--order by 2,3
)
Select *, (TotalVax/population) *100 as PerctentageVax
From RollingVax
Where TotalVax > population
order by 2,3

-- Total Population vaccinated
with RollingVax (location, population, TotalVax) as
(
Select deaths.location, deaths.population,
SUM(cast(vax.new_vaccinations as bigint)) as TotalVax
From portfolio_project..covid_deaths deaths
Join portfolio_project..covid_vax vax
ON vax.location = deaths.location and vax.date = deaths.date
Where deaths.continent is not null
group by deaths.location, deaths.population
)
Select *, (TotalVax/population)*100 as PerctentageVax
From RollingVax

Select deaths.location, deaths.population, vax.total_vaccinations
From portfolio_project..covid_deaths deaths
Join portfolio_project..covid_vax vax
ON vax.location = deaths.location and vax.date = deaths.date
Where vax.total_vaccinations > deaths.population and deaths.continent is not null
order by 1

Select deaths.location, deaths.population, MAX(vax.people_fully_vaccinated) as Vaxed
From portfolio_project..covid_deaths deaths
Join portfolio_project..covid_vax vax
ON vax.location = deaths.location and vax.date = deaths.date
Where deaths.continent is not null and vax.people_fully_vaccinated > deaths.population
Group by deaths.location, deaths.population
order by 1
 
