USE Displaceddata

--see how many rows and columns are available in my upload data set to ensure it is complete
SELECT COUNT(*) as NUMBER_OF_ROWS
FROM Displaced; 

SELECT * FROM Refugeedata..Refugee;  

--verify which age range is covered by this data set and how many years
SELECT 
    MIN("Year") AS FirstYear,
    MAX("Year") AS LastYear, 
    MAX("Year") - MIN("Year") + 1 AS NumberOfYears
FROM Displaced;

--characteristics of different columns in data set
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Displaced';

--check whether exist null values in data (can change chosen column to verify each one of interest)
SELECT *
FROM Displaced
WHERE Country_of_origin IS NULL;

--percentage of frequency of country of origins in the data for displaced persons
SELECT
    Country_of_origin,
    COUNT(*) AS Frequency,
    CAST(ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Displaced)), 2) AS decimal(10, 2)) AS "Percentage"
FROM
    Displaced
GROUP BY
    Country_of_origin
ORDER BY
    Frequency DESC;

--percentage of frequency of country of asylum in the data for displaced persons
SELECT
    Country_of_asylum,
    COUNT(*) AS Frequency,
    CAST(ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Displaced)), 3) AS decimal(10, 3)) AS "Percentage"
FROM
    Displaced
GROUP BY
    Country_of_asylum
ORDER BY
    Frequency DESC;

--most likely country of asylum for countries of origin and percentage of displaced in data who go to that country
WITH RankedCountries AS (
    SELECT
        Country_of_origin,
        Country_of_asylum,
        RANK() OVER (PARTITION BY Country_of_origin ORDER BY COUNT(*) DESC) AS RankWithinOrigin,
        CAST(ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Displaced)), 4) AS decimal(10, 4)) AS Percentage
    FROM
        Displaced
    GROUP BY
        Country_of_origin, Country_of_asylum
)
SELECT
    Country_of_origin,
    Country_of_asylum,
    Percentage
FROM RankedCountries
WHERE RankWithinOrigin = 1
ORDER BY
    "Percentage" DESC;

--where do Mexico displaced persons tend to seek asylum
SELECT
    Country_of_asylum,
    COUNT(*) AS Frequency,
    CAST(ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Displaced)), 4) AS decimal(10, 4)) AS "Percentage"
FROM
    Displaced
WHERE Country_of_origin = 'Mexico'
GROUP BY
    Country_of_asylum
ORDER BY
    Frequency DESC;

--change name of United Kingdom of Great Britain entry to United Kingdom
UPDATE Displaced
SET Country_of_origin = 'United Kingdom'
WHERE Country_of_origin = 'United Kingdom of Great Britain and Northern Ireland';

UPDATE Displaced
SET Country_of_asylum = 'United Kingdom'
WHERE Country_of_asylum = 'United Kingdom of Great Britain and Northern Ireland';

SELECT * FROM Displaced;

--which countries tend to choose France, UK and Spain as country of asylum?
SELECT
    Country_of_origin,
    Country_of_asylum,
    COUNT(*) AS Frequency,
    CAST(ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Displaced)), 4) AS decimal(10, 4)) AS "Percentage"
FROM
    Displaced
WHERE
    Country_of_asylum IN ('United Kingdom', 'Spain', 'France') -- Use IN for multiple values
GROUP BY
    Country_of_origin, Country_of_asylum  -- Include Country_of_origin in GROUP BY
ORDER BY
    "Percentage" DESC;

--which countries tend to choose France, UK and Spain as country of asylum divided by individual country
--UK
SELECT
    Country_of_origin,
    Country_of_asylum,
    COUNT(*) AS Frequency,
    CAST(ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Displaced)), 4) AS decimal(10, 4)) AS "Percentage"
FROM
    Displaced
WHERE
    Country_of_asylum = 'United Kingdom' 
GROUP BY
    Country_of_origin, Country_of_asylum  -- Include Country_of_origin in GROUP BY
ORDER BY
    "Percentage" DESC;
--France
SELECT
    Country_of_origin,
    Country_of_asylum,
    COUNT(*) AS Frequency,
    CAST(ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Displaced)), 4) AS decimal(10, 4)) AS "Percentage"
FROM
    Displaced
WHERE
    Country_of_asylum = 'France' 
GROUP BY
    Country_of_origin, Country_of_asylum  -- Include Country_of_origin in GROUP BY
ORDER BY
    "Percentage" DESC;
--Spain
SELECT
    Country_of_origin,
    Country_of_asylum,
    COUNT(*) AS Frequency,
    CAST(ROUND((COUNT(*) * 100.0 / (SELECT COUNT(*) FROM Displaced)), 4) AS decimal(10, 4)) AS "Percentage"
FROM
    Displaced
WHERE
    Country_of_asylum = 'Spain' 
GROUP BY
    Country_of_origin, Country_of_asylum  -- Include Country_of_origin in GROUP BY
ORDER BY
    "Percentage" DESC;

--convert other_people_in_need_of_international_protection column from varchar to integer
--verify whether all values are numeric
SELECT Other_people_in_need_of_international_protection
FROM Displaced
WHERE Other_people_in_need_of_international_protection IS NULL;

SELECT *
FROM Displaced
WHERE ISNUMERIC(Other_people_in_need_of_international_protection) = 0;
--as no results appear, means can be turned into numeric
ALTER TABLE Displaced
ALTER COLUMN Other_people_in_need_of_international_protection INTEGER; -- Change the data type to INTEGER

SELECT * FROM Displaced;

--which year had the most cases of asylum seekers recorded in the world i.e. displaced people before they obtain official status
SELECT "Year", SUM(Asylum_seekers) as TotalAS
FROM Displaced
GROUP BY "Year"
ORDER BY TotalAS DESC;

--which asylum seekers in 2022 asked for most asylum
SELECT Country_of_origin, SUM(Asylum_seekers) as TotalAS
FROM Displaced
WHERE "Year" = '2022'
GROUP BY Country_of_origin
ORDER BY TotalAS DESC;


--which year had the most cases of refugees recorded in the world i.e. displaced people before they obtain official status
SELECT TOP 1 "Year", SUM(Refugees_under_UNHCR_s_mandate) as TotalRefugees 
FROM Displaced
GROUP BY "Year"
ORDER BY TotalRefugees DESC;
  SELECT * FROM Displaced;

 --how many stateless people
 SELECT "Year", Stateless_persons, Country_of_asylum
 FROM Displaced
 WHERE Stateless_persons > 0
 ORDER BY "Year" DESC;

 --total amount per year
 SELECT "Year", SUM(Stateless_persons) as TotalStateless
 FROM Displaced
 GROUP BY "Year"
 ORDER BY TotalStateless DESC;

 --where did stateless people seek asylum in 2008, the year with the highest amount of stateless people
  SELECT Country_of_asylum, Stateless_persons
 FROM Displaced
 WHERE "Year" = '2008' AND Stateless_persons > 0
 ORDER BY Stateless_persons DESC;

 --in which countries do IDPs appear
   SELECT "Year", Country_of_origin, IDPs_of_concern_to_UNHCR
 FROM Displaced
 WHERE IDPs_of_concern_to_UNHCR > 0
 ORDER BY "YEAR" DESC;

 --total of IDPs per year, important note, hard to know whether each year, only new IDPs counted or is an acculation of previous year + new year IDPs
 SELECT "Year", SUM(IDPs_of_concern_to_UNHCR) as TotalIDPs
 FROM Displaced
 GROUP BY "Year"
 ORDER BY TotalIDPs DESC;

 --where were there most IDPs in 2022
 SELECT Country_of_origin, IDPs_of_concern_to_UNHCR
 FROM Displaced
 WHERE "Year" = 2022 AND IDPs_of_concern_to_UNHCR > 0
 ORDER BY IDPs_of_concern_to_UNHCR DESC;

  SELECT * FROM Displaced;

  --explore other_people in need of international protection column, seems to only relate to Venezuela displaced, who haven't applied for asylum
  SELECT "year", country_of_origin, country_of_asylum, other_people_in_need_of_international_protection
  FROM Displaced
  WHERE Other_people_in_need_of_international_protection > 0
  ORDER BY "YEAR", Country_of_asylum ASC

  SELECT *
  FROM Displaced
  WHERE Other_people_in_need_of_international_protection > 0


  --explore host community
  SELECT *
  FROM Displaced
  WHERE Host_Community > 0
  ORDER BY "Year" DESC

  --explore others of concern - russian federation
    SELECT *
  FROM Displaced
  WHERE Others_of_concern > 0 and Country_of_origin = 'Russian Federation'
  ORDER BY "Year" DESC

  --total nuber of people needing some sort of international protection
  Select Country_of_origin, sum(others_of_concern) as Total_In_Need
  FROM Displaced
  WHERE Country_of_origin = 'Russian Federation'
  GROUP BY Country_of_origin

  --year where most peopel concerned in russia
   Select "Year", Country_of_origin, sum(others_of_concern) as Total_In_Need
  FROM Displaced
  WHERE Country_of_origin = 'Russian Federation'
  GROUP BY Country_of_origin, "Year"
  ORDER BY "Year"

  --add new column to summarise all numbers from columns
ALTER TABLE Displaced
ADD Totals INT
SELECT * FROM Displaced;

UPDATE Displaced
SET Totals = Refugees_under_UNHCR_s_mandate + Asylum_seekers + IDPs_of_concern_to_UNHCR + Other_people_in_need_of_international_protection + Stateless_persons + Others_of_concern;

  --explore situation of ukraine 
   SELECT *
  FROM Displaced
  WHERE Country_of_origin = 'Ukraine'
  ORDER BY "Year" DESC

   SELECT "Year", SUM(Refugees_under_UNHCR_s_mandate) as TotalRs, SUM(Asylum_seekers) as TotalAS, SUM(IDPs_of_concern_to_UNHCR) as Total_IDPs,
   SUM(Other_people_in_need_of_international_protection) as OthersInNeed, SUM(Stateless_persons) as Stateless, sum(Others_of_concern) as Others, sum(Totals) as Totals
  FROM Displaced
  WHERE Country_of_origin = 'Ukraine'
  GROUP BY "Year"
  ORDER BY Totals DESC

  -- Algeria data exploration
     SELECT *
  FROM Displaced
  WHERE Country_of_asylum = 'Algeria'
  ORDER BY "Year" DESC
 
 SELECT DISTINCT Country_of_origin
FROM Displaced
WHERE Country_of_asylum = 'Algeria'
