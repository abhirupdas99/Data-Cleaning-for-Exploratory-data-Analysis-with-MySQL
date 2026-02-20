-- Active: 1770864403634@@127.0.0.1@3306@layoffs
-- ============================================================
-- Project: World Layoffs Data Cleaning
-- Author: Abhirup Das
-- Tool: MySQL 8.0+
-- Description:
-- End-to-end data cleaning workflow including:
-- 1. Staging table creation
-- 2. Duplicate removal using window functions
-- 3. Data standardization
-- 4. Missing value handling
-- 5. Final dataset preparation for EDA
-- ============================================================


-- ============================================================
-- DATABASE SETUP
-- ============================================================
SELECT @@version;
CREATE DATABASE IF NOT EXISTS layoffs;
USE layoffs;

-- Create raw table structure

CREATE TABLE IF NOT EXISTS layoffs (
    company TEXT,
    location TEXT,
    industry TEXT,
    total_laid_off INT,
    percentage_laid_off TEXT,
    `date` TEXT,
    stage TEXT,
    country TEXT,
    funds_raised_millions INT
);

-- Check secure_file_priv setting for LOAD DATA INFILE
SHOW VARIABLES LIKE 'secure_file_priv';

-- Load raw data from CSV file into the 'layoffs' table
LOAD DATA INFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\layoffs.csv'
INTO TABLE layoffs
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, @funds)
SET funds_raised_millions = NULLIF(TRIM(REPLACE(REPLACE(@funds, '\r', ''), '\n', '')), 'NULL');

-- ============================================================
-- STEP 0: check if the data are loaded correctly into the raw table
-- ============================================================


SELECT * from layoffs;

-- ============================================================
-- STEP 1: Create Staging Table
-- ============================================================

CREATE TABLE IF NOT EXISTS layoffs_staged LIKE layoffs;

INSERT INTO layoffs_staged
SELECT *
FROM layoffs;

-- Check the staged data
SELECT * FROM layoffs_staged;


-- ============================================================
-- STEP 2: Remove Duplicates
-- Using ROW_NUMBER() to identify duplicate records
-- ============================================================

CREATE TABLE layoffs_staged_unique AS
SELECT *,
       ROW_NUMBER() OVER (
           PARTITION BY company,
                        location,
                        industry,
                        total_laid_off,
                        percentage_laid_off,
                        date,
                        stage,
                        country,
                        funds_raised_millions
           ORDER BY company
       ) AS row_num
FROM layoffs_staged;


-- Disable safe mode temporarily
SET SQL_SAFE_UPDATES = 0;

DELETE FROM layoffs_staged_unique
WHERE row_num > 1;

SET SQL_SAFE_UPDATES = 1;



-- ============================================================
-- STEP 3: Standardize Data
-- ============================================================

-- 3.1 Remove leading/trailing spaces
SET SQL_SAFE_UPDATES = 0;
UPDATE layoffs_staged_unique
SET company = TRIM(company);


UPDATE layoffs_staged_unique
SET location = TRIM(location);

UPDATE layoffs_staged_unique
SET industry = TRIM(industry);

UPDATE layoffs_staged_unique
SET country = TRIM(country);

SET SQL_SAFE_UPDATES = 1;


-- 3.2 Standardize Industry Values
SET SQL_SAFE_UPDATES = 0;
UPDATE layoffs_staged_unique
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';
SET SQL_SAFE_UPDATES = 1;

-- Convert 'unknown' to NULL for proper handling
SET SQL_SAFE_UPDATES = 0;
UPDATE layoffs_staged_unique
SET industry = NULL
WHERE industry = 'unknown';

SET SQL_SAFE_UPDATES = 1;


-- 3.3 Standardize Country Names
SET SQL_SAFE_UPDATES = 0;
UPDATE layoffs_staged_unique
SET country = 'United States'
WHERE country LIKE 'United States%';

SET SQL_SAFE_UPDATES = 1;


-- 3.4 Convert Date Column from TEXT to DATE
SET SQL_SAFE_UPDATES = 0;
UPDATE layoffs_staged_unique
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

SET SQL_SAFE_UPDATES = 1;


SET SQL_SAFE_UPDATES = 0;
ALTER TABLE layoffs_staged_unique
MODIFY COLUMN `date` DATE;

SET SQL_SAFE_UPDATES = 1;



-- ============================================================
-- STEP 4: Handle Missing Values
-- ============================================================

-- 4.1 Populate Missing Industry Values Using Self-Join

SET SQL_SAFE_UPDATES = 0;
UPDATE layoffs_staged_unique t1
JOIN layoffs_staged_unique t2
  ON t1.company = t2.company
  AND t1.industry IS NULL
  AND t2.industry IS NOT NULL
SET t1.industry = t2.industry;

SET SQL_SAFE_UPDATES = 1;


-- 4.2 Remove Records Where Both Layoff Metrics Are NULL

SET SQL_SAFE_UPDATES = 0;
DELETE FROM layoffs_staged_unique
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;

SET SQL_SAFE_UPDATES = 1;


-- 4.3 Standardize Stage Column
SET SQL_SAFE_UPDATES = 0;
UPDATE layoffs_staged_unique
SET stage = 'Unknown'
WHERE stage IS NULL OR stage = '';

SET SQL_SAFE_UPDATES = 1;



-- ============================================================
-- STEP 5: Final Cleanup
-- ============================================================

-- Remove helper column used for duplicate detection

SET SQL_SAFE_UPDATES = 0;
ALTER TABLE layoffs_staged_unique
DROP COLUMN row_num;

SET SQL_SAFE_UPDATES = 1;

-- Final check of the cleaned data
SELECT * FROM layoffs_staged_unique;

-- Check for any remaining duplicates
SELECT company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions,
       COUNT(*) AS duplicate_count
FROM layoffs_staged_unique
GROUP BY company, location, industry, total_laid_off, percentage_laid_off, date, stage, country, funds_raised_millions
HAVING duplicate_count > 1;

-- preparing the final cleaned dataset in csv format for EDA with header row
-- Export layoffs_cleaned.csv with header row and NULLs as empty cells
SELECT 
    'company', 'location', 'industry', 'total_laid_off', 'percentage_laid_off', 'date', 'stage', 'country', 'funds_raised_millions'
UNION ALL
SELECT 
    company,
    location,
    industry,
    total_laid_off,
    percentage_laid_off,
    DATE_FORMAT(`date`, '%Y-%m-%d') AS `date`,  -- ensures date is nicely formatted
    stage,
    country,
    IFNULL(funds_raised_millions, '') AS funds_raised_millions
FROM layoffs_staged_unique
INTO OUTFILE 'C:\\ProgramData\\MySQL\\MySQL Server 8.0\\Uploads\\layoffs_cleaned.csv'
FIELDS TERMINATED BY ','    
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

-- ============================================================
-- DATA CLEANING COMPLETE
-- The table 'layoffs_staged_unique' is now ready for EDA
-- ============================================================
