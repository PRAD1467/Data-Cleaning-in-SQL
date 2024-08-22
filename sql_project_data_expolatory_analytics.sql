-- EXPOLATORY DATA ANALYSIS

SELECT *
FROM layoffs_staging_2;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging_2;

SELECT *
FROM layoffs_staging_2
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- SELECT company, SUM(total_laid_off)
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging_2
-- GROUP BY company
GROUP BY industry
ORDER BY 2 DESC;

SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging_2;

SELECT country, SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY country
ORDER BY 2 DESC;

SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

SELECT stage, SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY stage
ORDER BY 2 DESC;

SELECT company, AVG(percentage_laid_off)
FROM layoffs_staging_2
GROUP BY company
ORDER BY 1 DESC;

-- Rolling up data to find out total how many employees has lost their jobs in this time period.

SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging_2
WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
GROUP BY `MONTH`
ORDER BY 1 ASC;

WITH ROLLING_SUM_CTE AS 
(
	SELECT SUBSTRING(`date`, 1, 7) AS `MONTH`, SUM(total_laid_off) AS total_off
	FROM layoffs_staging_2
	WHERE SUBSTRING(`date`, 1, 7) IS NOT NULL
	GROUP BY `MONTH`
	ORDER BY 1 ASC
)
SELECT `MONTH`, total_off, 
SUM(total_off) OVER(ORDER BY `MONTH`) AS rolling_total
FROM ROLLING_SUM_CTE
ORDER BY 1 ASC;

-- NOW WE ARE FINDING OUT EARLY EACH COMPANY HOW MUCH EMPLOYEES GOT FIRED AND WHO ARE THE MAXIMUM ONE

SELECT company, YEAR(`DATE`), SUM(total_laid_off)
FROM layoffs_staging_2
GROUP BY company, YEAR(`DATE`)
ORDER BY 3 DESC;

WITH COMPANY_YEAR (company, years, total_laid_off)AS
(
	SELECT company, YEAR(`DATE`), SUM(total_laid_off)
	FROM layoffs_staging_2
	GROUP BY company, YEAR(`DATE`)
), COMPANY_YEAR_RANK AS
(
SELECT *, 
DENSE_RANK() OVER(PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM COMPANY_YEAR
WHERE years IS NOT NULL
)
SELECT *
FROM COMPANY_YEAR_RANK
WHERE RANKING <= 5
;
