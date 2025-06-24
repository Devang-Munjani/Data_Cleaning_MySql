SET SQL_SAFE_UPDATES = 0;


-- data cleaning
use world_layoffs;

select * from layoffs;

-- 1. remove deuplicates
-- 2. standardize the data
-- 3. null values or blank values
-- 4. remove any columns or rows


-- 1. removing duplicates

-- copy the table into the new table , we do not work with direct original raw data
create table layoffs_staging
like layoffs;    

select * from layoffs_staging;


--  insert data from original data base
insert layoffs_staging
select * from layoffs;


select * from layoffs_staging;

-- assigning a unique number to identify duplicates

select *,
row_number() over(partition by company, industry, total_laid_off, percentage_laid_off, 'date') as row_num
from layoffs_staging;

with duplicate_cte as
(
select *,
row_number() over(partition by company, location,industry ,total_laid_off, percentage_laid_off, 'date',stage,country,funds_raised_millions) as row_num
from layoffs_staging
)
select * from duplicate_cte 
where row_num >1;

select * from layoffs_staging
where company= "Casperx`";


with duplicate_cte as
(
select *,
row_number() over(partition by company, location,industry ,total_laid_off, percentage_laid_off, 'date',stage,country,funds_raised_millions) as row_num
from layoffs_staging
)
delete  from duplicate_cte 
where row_num >1;


-- create  second database to delete duplicate data
create table `layoff_staging2`(
		`company` text,
		`location` text,
        `industry` text,
        `total_laid_off` int default null,
        `percentage_laid_off` text,
        `date` text,
        `stage` text,
        `country` text,
        `funds_raised_millions` int default null,
        `row_num` int
)ENGINE = InnoDB default CHARSET = utf8mb4 collate= utf8mb4_0900_ai_ci;


select * from layoff_staging2;

-- insert into second databse

insert into layoff_staging2
select *,
row_number() over(partition by company, location,industry ,total_laid_off, percentage_laid_off, 'date',stage,country,funds_raised_millions) as row_num
from layoffs_staging;

select * from layoff_staging2
where row_num>1;

-- deleting duplicate
delete from layoff_staging2
where row_num>1;




-- 2. standardize the data

select company , trim(company)
from layoff_staging2;

update layoff_staging2
set company = trim(company);


select *
from layoff_staging2
where industry like 'Crypto%';

update layoff_staging2
set industry = 'Crypto'
where industry like 'Crypto%';

select distinct industry
from layoff_staging2 ;

select distinct location
from layoff_staging2 
order by 1;

select distinct country
from layoff_staging2 
order by 1;

select *
from layoff_staging2 
where country like 'United States%';

select distinct country, trim(trailing '.' from country)
from layoff_staging2 
order by 1;


update layoff_staging2
set country = trim(trailing '.' from country)
where country like 'United States%';

select `date`
from layoff_staging2 ;

update layoff_staging2
set `date` = str_to_date(`date`, '%m/%d/%Y');

alter table layoff_staging2
modify column `date` date;




-- 3. null values or blank values

select * from layoff_staging2
where total_laid_off is null
and percentage_laid_off is null;


update layoff_staging2
set industry = null
where industry = ''; 

select * 
from layoff_staging2 
where industry is null
or industry = '';


select * 
from layoff_staging2
where company like 'Bally%';


select t1.industry, t2.industry
from layoff_staging2 t1
join layoff_staging2 t2
		on t1.company=t2.company
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;

update  layoff_staging2 t1
join layoff_staging2 t2
		on t1.company=t2.company
set t1.industry = t2.industry
where t1.industry is null
and t2.industry is not null;

select * 
from layoff_staging2;





-- 4. remove any columns or rows


select * from layoff_staging2
where total_laid_off is null
and percentage_laid_off is null;

delete
from layoff_staging2
where total_laid_off is null
and percentage_laid_off is null;

select * 
from layoff_staging2;

alter table layoff_staging2
drop column row_num; 








