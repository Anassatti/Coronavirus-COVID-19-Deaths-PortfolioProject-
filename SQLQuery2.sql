/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [iso_code]
      ,[continent]
      ,[location]
      ,[population]
      ,[date]
      ,[population2]
      ,[total_cases]
      ,[new_cases]
      ,[new_cases_smoothed]
      ,[total_deaths]
      ,[new_deaths]
  FROM [PortfolioProject].[dbo].[CoronaDeath]

--Death percentage------------- 
  Select location, date, total_cases,total_deaths,  (total_deaths/total_cases)*100 as Deathpercentage FROM [PortfolioProject].[dbo].[CoronaDeath]
--Total cases vs population, show populatio percentage who contract Coviad
  Select location, date, population, total_cases, (total_cases/population)*100 as Percentage_ByCountry 
  FROM [PortfolioProject].[dbo].[CoronaDeath]
  Order by Percentage_ByCountry  desc 
--What is the country has heighest cases
  Select location,  population, MAX(total_cases) as Highest_Cases, MAX((total_cases/population))*100 as Total_cases_ByCountry 
  FROM [PortfolioProject].[dbo].[CoronaDeath]
  Group by location,population
  Order by Total_cases_ByCountry desc
--Show the countries which have the height death
  Select location,  population, MAX(total_deaths) as Highest_DeathCases, MAX((total_cases/population))*100 as Total_cases_ByCountry 
  FROM [PortfolioProject].[dbo].[CoronaDeath] 
  WHERE location NOT IN('World','Upper middle income','High income','Europe','North America','Asia','Lower middle income','South America','European Union','Africa')
  Group by location,  population
  Order by Highest_DeathCases desc;
--Show the death rate by continent
  Select location, MAX(total_deaths) as Highest_DeathCases
  FROM [PortfolioProject].[dbo].[CoronaDeath] Where continent is  NULL
  Group by location
  Order by Highest_DeathCases desc
-- Showing continent with the heighest death rate per population 
  Select continent, MAX(total_deaths) as Total_DeathCount
  FROM [PortfolioProject].[dbo].[CoronaDeath] Where continent is not NULL
  Group By continent
  Order by Total_DeathCount desc
--Global Numbers
  Select  SUM(new_cases) as GlobalTotal_Cases, SUM(new_deaths) as GlobalTotalDeath, SUM(new_deaths)/SUM(new_cases)*100 as GlobalDeathpercentage
  FROM [PortfolioProject].[dbo].[CoronaDeath]
  WHERE continent is not NUll
  Order by 1,2
---Vaccination vs Population
  Select dea.continent, dea.date,dea.location,dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition BY dea.location order by dea.location, dea.date) as TotalVaccination
  From [PortfolioProject].[dbo].[CoronaDeath] dea
  INNER JOIN [PortfolioProject].[dbo].[CovidVaccination] vac ON  dea.location=vac.location and dea.date=vac.date 
 and dea.continent=vac.continent
  Where dea.continent is NOT NULL
  Order by 1,2
--CTE(Common Table Expression)
  With PopvsVac(Continent, location, Date, Population,New_vaccinations,TotalVaccination)
  as(Select dea.continent, dea.date,dea.location,dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition BY dea.location order by dea.location, dea.date) as TotalVaccination
  From [PortfolioProject].[dbo].[CoronaDeath] dea
  INNER JOIN [PortfolioProject].[dbo].[CovidVaccination] vac ON  dea.location=vac.location and dea.date=vac.date 
  and dea.continent=vac.continent
  Where dea.continent is NOT NULL
-- order by 1,2
)
 Select *, (TotalVaccination/population)*100 from PopvsVac
--Create table
 Create Table VaccinationPopulationPercentage 
 (continent nvarchar(50),
  location nvarchar(50),
  date date,
  population float,
  new_vaccinations float,
  TotalVaccination float
)
Insert into  VaccinationPopulationPercentage

 Select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition BY dea.location order by dea.location, dea.date) as TotalVaccination
 From [PortfolioProject].[dbo].[CoronaDeath] dea
 INNER JOIN [PortfolioProject].[dbo].[CovidVaccination] vac ON  dea.location=vac.location and dea.date=vac.date 
 and dea.continent=vac.continent
 --where dea.continent is NOT NULL
 Select *, (TotalVaccination/population)*100 from VaccinationPopulationPercentage
 DROP TABLE VaccinationPopulationPercentage ;
--Create view for data visualization
 Create view PopulationVaccination as 
  Select dea.continent, dea.location,dea.date,dea.population, vac.new_vaccinations, SUM(vac.new_vaccinations) OVER (Partition BY dea.location order by dea.location, dea.date) as TotalVaccination
  from [PortfolioProject].[dbo].[CoronaDeath] dea
  INNER JOIN [PortfolioProject].[dbo].[CovidVaccination] vac ON  dea.location=vac.location and dea.date=vac.date 
  and dea.continent=vac.continent
 Where dea.continent is NOT NULL