SELECT *
FROM layoffs;

-- For to clean data there are four steps: 

-- Remove the duplicates

CREATE TABLE layoffs_staging
LIKE layoffs;

SELECT *
FROM layoffs_staging;

INSERT INTO layoffs_staging
SELECT *
FROM layoffs;

SELECT *
FROM layoffs_staging;

WITH duplicate_cte AS
(
	SELECT *, 
	ROW_NUMBER() 
    OVER 
    (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions)
    AS row_num
	FROM layoffs_staging
)
SELECT *
-- DELETE
FROM duplicate_cte
-- WHERE company = 'Casper';
WHERE row_num > 1;


-- WE WILL NOW CREATE ANOTHER TABLE BY PUTTTING CTE TABLE CONTENT THERE AND WILL DELETE THERE AS WE CAN'T DIRECTLY DELETE DATA IN CTE TABLES

CREATE TABLE `layoffs_staging_2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL, 
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT *
FROM layoffs_staging_2;

INSERT INTO layoffs_staging_2
SELECT *, 
	ROW_NUMBER() 
    OVER 
    (PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions)
    AS row_num
FROM layoffs_staging;

DELETE
FROM layoffs_staging_2
WHERE row_num > 1;

SELECT *
FROM layoffs_staging_2;

-- Standardise the data like spelling error

SELECT company,  trim(company)
FROM layoffs_staging_2;

UPDATE layoffs_staging_2
SET company = trim(company);

SELECT DISTINCT industry
FROM layoffs_staging_2
ORDER BY 1;

UPDATE layoffs_staging_2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT DISTINCT country, trim(TRAILING '.' FROM country)
FROM layoffs_staging_2
ORDER BY 1;

UPDATE layoffs_staging_2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

SELECT `date`,
STR_TO_DATE(`date`, '%m/%d/%Y')
FROM layoffs_staging_2;

UPDATE layoffs_staging_2
SET `date` = STR_TO_DATE(`date`, '%m/%d/%Y');

SELECT *
FROM layoffs_staging_2;  

ALTER TABLE layoffs_staging_2
MODIFY COLUMN `date` DATE;


-- Null or void value fix it

SELECT *
FROM layoffs_staging_2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;  

SELECT *
FROM layoffs_staging_2
WHERE industry is null or industry = ''; 

SELECT *
FROM layoffs_staging_2
WHERE company LIKE 'Bally%'; 

UPDATE layoffs_staging_2
SET industry = null
WHERE industry like '';

SELECT *
FROM layoffs_staging_2
WHERE company = 'Airbnb'; 

SELECT t1.industry, t2.industry
FROM layoffs_staging_2 t1
JOIN layoffs_staging_2 t2
	ON t1.company = t2.company
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

UPDATE layoffs_staging_2 t1
JOIN layoffs_staging_2 t2
	ON t1.company = t2.company
SET t1.industry = t2.industry    
WHERE t1.industry IS NULL AND t2.industry IS NOT NULL;

-- remove any columns or row that's unnecessary

SELECT *
FROM layoffs_staging_2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

DELETE
FROM layoffs_staging_2
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging_2	
DROP COLUMN row_num;

SELECT *
FROM layoffs_staging_2;







