select * 
from PortfolioProject .. CovidDeaths$
where continent is not null
order by 3,4 

--select * 
--from PortfolioProject ..CovidVaccinations$
--order by 3,4 

-- selecting data we are going to use
select location , date, total_cases, new_cases ,total_deaths , population
from PortfolioProject .. CovidDeaths$
where continent is not null
order by 1,2

--total cases vs total death
--shows likelihood of dying if you contract covid in your country 
select location , date, total_cases ,total_deaths ,(total_deaths/total_cases)*100 as death_percentage
from PortfolioProject .. CovidDeaths$
where location like '%state%' and  continent is not null
order by 1,2

 --total cases vs population  & shows what prectage of population got covid 
 select location , date, total_cases ,population ,(total_cases/population)*100 as death_percentage
from PortfolioProject .. CovidDeaths$
--where location like '%state%'
order by 1,2

--countries with higher infection rate compared to population 
 select location , population, Max(total_cases) As HighestInfectionCount ,Max(total_cases/population)*100 as PercentPopulationInfected
from PortfolioProject .. CovidDeaths$
--where location like '%state%'
group by Location , population
order by PercentPopulationInfected desc

 --shows countries with highest death count per population 
  select location ,Max(cast(total_deaths as integer)) As TotalDeathCount
from PortfolioProject .. CovidDeaths$
--where location like '%state%'
where continent is not null
group by Location 
order by TotalDeathCount desc

--Breaking things down by continents 
--continents with highest death count per population
 select continent ,Max(cast(total_deaths as integer)) As TotalDeathCount
from PortfolioProject .. CovidDeaths$
--where location like '%state%'
where continent is not null
group by continent
order by TotalDeathCount desc

--Global Numbers
select  sum(new_cases) as total_case,sum(cast(new_cases as int)) as total_death ,sum(cast(new_deaths as int))/sum(new_cases)*100  as death_percentage
from PortfolioProject .. CovidDeaths$
where continent is not null
--group by date
order by 1,2

select * 
from  PortfolioProject .. CovidDeaths$ dea 
join PortfolioProject ..CovidVaccinations$ vac
	on dea.location = vac.location 
	and dea.date = vac.date

--total population vs vaccination
select dea.continent , dea.location, dea.date ,dea.population ,vac.new_vaccinations, 
sum(convert (int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from  PortfolioProject .. CovidDeaths$ dea 
join PortfolioProject ..CovidVaccinations$ vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

--use CTE
with popvsvac (continent ,location ,date ,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent , dea.location, dea.date ,dea.population ,vac.new_vaccinations, 
sum(convert (int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from  PortfolioProject .. CovidDeaths$ dea 
join PortfolioProject ..CovidVaccinations$ vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)

select * ,(RollingPeopleVaccinated/population)*100
from popvsvac

--temp table
drop table if exists #PercentPopulationVaccinated 

Create Table #PercentPopulationVaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent , dea.location, dea.date ,dea.population ,vac.new_vaccinations, 
sum(convert (int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from  PortfolioProject .. CovidDeaths$ dea 
join PortfolioProject ..CovidVaccinations$ vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3

select * ,(RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

--creating view to store data for later visulization
create view PercentPopulationVaccinated as
select dea.continent , dea.location, dea.date ,dea.population ,vac.new_vaccinations, 
sum(convert (int,vac.new_vaccinations)) over(partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
from  PortfolioProject .. CovidDeaths$ dea 
join PortfolioProject ..CovidVaccinations$ vac
	on dea.location = vac.location 
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
select * 
from PercentPopulationVaccinated