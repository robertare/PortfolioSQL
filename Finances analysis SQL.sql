SELECT * FROM Bank..Statement;

---DATA CLEANING and WRANGLING----

---Standardize date of operation

ALTER TABLE Bank..Statement
Add "Date" Date;

Update Bank..Statement
SET "Date" = CONVERT(Date,"Date operation")

ALTER TABLE Bank..Statement
DROP COLUMN "Date operation";

SELECT * FROM Bank..Statement;

--Change name of columns
EXEC sp_rename 'Bank..Statement."Libelle court"', 'Category', 'COLUMN';

EXEC sp_rename 'Bank..Statement."Type operation"', 'Type', 'COLUMN';

EXEC sp_rename 'Bank..Statement."Libelle operation"', 'Description', 'COLUMN';
EXEC sp_rename 'Bank..Statement."Montant operation en euro"', 'AmountEUR', 'COLUMN';

--what date periods are available in data set
SELECT MIN("OperationDate") AS StartDate, MAX("OperationDate") AS EndDate
FROM Bank..Statement;

--convert date column back to date from varchar

ALTER TABLE Bank..Statement
ADD "DateTime" date; 

Update Bank..Statement
SET "DateTime" = CONVERT(Date,"Date");

ALTER TABLE Bank..Statement
DROP COLUMN "Date";

--Extract month from date column as a seperate column as well as year
ALTER TABLE Bank..Statement
ADD month_name VARCHAR(20);
UPDATE Bank..Statement
SET month_name = FORMAT(OperationDate, 'MMMM');

ALTER TABLE Bank..Statement
ADD "year" int;
UPDATE Bank..Statement
SET "year" = YEAR(OperationDate);

--remove August 2023 as not a complete month of data
DELETE FROM Bank..Statement
WHERE YEAR(OperationDate) = 2023 AND MONTH(OperationDate) = 8;

---DATA EXPLORATION--
SELECT * FROM Bank..Statement;

--which categories are available?
SELECT DISTINCT Category
FROM Bank..Statement;

--show what months under which year
SELECT DISTINCT month_name, "year"
FROM Bank..Statement
ORDER BY 2,1;

--which month had the highest payment with card? 
SELECT month_name, "year",
SUM(AmountEUR) as TotalAmount
FROM Bank..Statement
WHERE Category = 'PAIEMENT CB'
GROUP BY month_name , "year"
ORDER BY TotalAmount ASC;

--highest spending amount by card in January
SELECT "Description", AmountEUR, month_name, "year"
FROM Bank..Statement
WHERE Category = 'PAIEMENT CB' AND month_name = 'January'
ORDER BY AmountEUR ASC;

--highest direct debit payment for all the months
SELECT "Description", AmountEUR, month_name, "year"
FROM Bank..Statement
WHERE Category = 'PRELEVEMENT'
ORDER BY AmountEUR ASC;

--highest transfer payment for all the months
SELECT "Description", AmountEUR, month_name, "year"
FROM Bank..Statement
WHERE Category = 'VIREMENT'
ORDER BY AmountEUR ASC;

--what month and year had the highest spending in Lidl
SELECT "Description", month_name, "year", SUM(AmountEUR) as TotalAmount
FROM Bank..Statement
WHERE "Description" like '%LIDL%'
GROUP BY "Description", month_name, "year"
ORDER BY TotalAmount ASC;

--total spending in Lidl for the time period available in data set
SELECT SUM(AmountEUR) as TotalAmount
FROM Bank..Statement
WHERE "Description" LIKE '%LIDL%';

--which months did I spend most amount
SELECT month_name, "year",
SUM(AmountEUR) as TotalAmount
FROM Bank..Statement
WHERE Category = 'PAIEMENT CB'
GROUP BY month_name , "year"
ORDER BY TotalAmount ASC;

SELECT * FROM Bank..Statement

ALTER TABLE Bank..Statement
DROP COLUMN "DateTime";

ALTER TABLE Bank..Statement
DROP COLUMN "Date";

