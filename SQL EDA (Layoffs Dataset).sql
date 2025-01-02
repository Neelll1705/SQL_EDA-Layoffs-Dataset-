-- Exploratory Data Analysis (EDA)
-- This script explores the dataset to uncover trends, patterns, and insights, such as outliers and distributions.

-- 1. Initial Exploration: View the data
SELECT * 
FROM world_layoffs.layoffs_staging2;

-- 2. Easier Queries
-- Find the maximum number of layoffs in a single event
SELECT MAX(total_laid_off) AS max_layoffs
FROM world_layoffs.layoffs_staging2;

-- Check the range of layoff percentages
SELECT MAX(percentage_laid_off) AS max_percentage, MIN(percentage_laid_off) AS min_percentage
FROM world_layoffs.layoffs_staging2
WHERE percentage_laid_off IS NOT NULL;

-- Identify companies that laid off 100% of their workforce
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE percentage_laid_off = 1;
-- Insight: These are mostly startups that went out of business.

-- Examine 100%-layoff companies by funds raised
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;
-- Insight: High-profile companies like BritishVolt and Quibi appear here.

-- 3. Slightly Complex Queries: Using Aggregations and Group By
-- Top 5 companies with the largest single-day layoffs
SELECT company, total_laid_off
FROM world_layoffs.layoffs_staging2
ORDER BY total_laid_off DESC
LIMIT 5;

-- Companies with the most total layoffs across all events
SELECT company, SUM(total_laid_off) AS total_layoffs
FROM world_layoffs.layoffs_staging2
GROUP BY company
ORDER BY total_layoffs DESC
LIMIT 10;

-- Top 10 locations by total layoffs
SELECT location, SUM(total_laid_off) AS total_layoffs
FROM world_layoffs.layoffs_staging2
GROUP BY location
ORDER BY total_layoffs DESC
LIMIT 10;

-- Total layoffs by country
SELECT country, SUM(total_laid_off) AS total_layoffs
FROM world_layoffs.layoffs_staging2
GROUP BY country
ORDER BY total_layoffs DESC;

-- Total layoffs per year
SELECT YEAR(date) AS year, SUM(total_laid_off) AS total_layoffs
FROM world_layoffs.layoffs_staging2
GROUP BY YEAR(date)
ORDER BY year ASC;

-- Total layoffs by industry
SELECT industry, SUM(total_laid_off) AS total_layoffs
FROM world_layoffs.layoffs_staging2
GROUP BY industry
ORDER BY total_layoffs DESC;

-- Total layoffs by company stage
SELECT stage, SUM(total_laid_off) AS total_layoffs
FROM world_layoffs.layoffs_staging2
GROUP BY stage
ORDER BY total_layoffs DESC;

-- 4. Advanced Queries: Using CTEs and Window Functions
-- Top 3 companies with the most layoffs per year
WITH Company_Year AS 
(
  SELECT company, YEAR(date) AS year, SUM(total_laid_off) AS total_layoffs
  FROM world_layoffs.layoffs_staging2
  GROUP BY company, YEAR(date)
),
Company_Year_Rank AS 
(
  SELECT company, year, total_layoffs, 
         DENSE_RANK() OVER (PARTITION BY year ORDER BY total_layoffs DESC) AS rank
  FROM Company_Year
)
SELECT company, year, total_layoffs, rank
FROM Company_Year_Rank
WHERE rank <= 3
ORDER BY year ASC, total_layoffs DESC;

-- Rolling total of layoffs per month
WITH DATE_CTE AS 
(
  SELECT SUBSTRING(date, 1, 7) AS month, SUM(total_laid_off) AS monthly_layoffs
  FROM world_layoffs.layoffs_staging2
  GROUP BY month
  ORDER BY month ASC
)
SELECT month, 
       SUM(monthly_layoffs) OVER (ORDER BY month ASC) AS rolling_total_layoffs
FROM DATE_CTE
ORDER BY month ASC;
