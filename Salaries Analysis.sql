use mannu;
/*1.You're a Compensation analyst employed by a multinational corporation. Your Assignment is to Pinpoint Countries who give work fully remotely, for the title
 'managers’ Paying salaries Exceeding $90,000 USD*/
 
select distinct company_location from salaries where job_title like '%Manager%' and remote_ratio = '100' and salary_in_usd >= '90000';

/*2.AS a remote work advocate Working for a progressive HR tech startup who place their freshers’ clients IN large tech firms. you're tasked WITH 
Identifying top 5 Country Having  greatest count of large(company size) number of companies.*/

select company_location, count(*) as 'count' from
(select * from salaries WHERE experience_level = 'EN' and company_size = 'L')t group by company_location order by count desc limit 5;

/*3. Picture yourself AS a data scientist Working for a workforce management platform. Your objective is to calculate the percentage of employees. 
Who enjoy fully remote roles WITH salaries Exceeding $100,000 USD, Shedding light ON the attractiveness of high-paying remote positions IN today's job market.*/

set @total_employees = (select count(*) from salaries);
set @employees = (select count(*) from salaries where salary_in_usd > 100000 and remote_ratio = 100);
set @percent  = round(((select @employees)/(select @total_employees))*100,2);
select @percent as 'Percentage';

/*4. Imagine you're a data analyst Working for a global recruitment agency. Your Task is to identify the Locations where entry-level average salaries exceed the 
average salary for that job title in market for entry level, helping your agency guide candidates towards lucrative countries.*/

select t.job_title, company_location, avgg_salary, avgg_salary_per_country from
(select job_title, avg(salary_in_usd) as 'avgg_salary' from 
(select * from salaries where experience_level = 'EN')t group by job_title)t 

inner join

(select company_location, job_title, avg(salary_in_usd) as 'avgg_salary_per_country' from 
(select * from salaries where experience_level = 'EN')t group by job_title, company_location)g on t.job_title = g.job_title 
where avgg_salary_per_country > avgg_salary;

/*5. You've been hired by a big HR Consultancy to look at how much people get paid IN different Countries. Your job is to Find out for each job title which
Country pays the maximum average salary. This helps you to place your candidates IN those countries.*/

select * from (
select *, dense_rank() over (partition by job_title order by average desc) as 'ranking' from (
select job_title, company_location, avg(salary_in_usd) as 'average' from salaries group by company_location, job_title)t)g where ranking =1;

/*6.  AS a data-driven Business consultant, you've been hired by a multinational corporation to analyze salary trends across different company Locations.
 Your goal is to Pinpoint Locations WHERE the average salary Has consistently Increased over the Past few years (Countries WHERE data is available for 3 years Only(this and pst two years) 
 providing Insights into Locations experiencing Sustained salary growth.*/

with  country as
( 
 select * from salaries where company_location in (
   select company_location from 
   (
       select company_location, count(distinct work_year) as 'year' from 
       (
           select * from salaries where work_year >= (year(current_date())-2))t group by company_location having year = 3
	)m
    )
)

SELECT 
    company_locatiON,
    MAX(CASE WHEN work_year = 2022 THEN  average END) AS AVG_salary_2022,
    MAX(CASE WHEN work_year = 2023 THEN average END) AS AVG_salary_2023,
    MAX(CASE WHEN work_year = 2024 THEN average END) AS AVG_salary_2024
FROM (
select company_location, work_year, avg(salary_in_usd) as 'average' from country group by company_location, work_year)g group by company_location
havINg AVG_salary_2024 > AVG_salary_2023 AND AVG_salary_2023 > AVG_salary_2022;

/* 7. Picture yourself AS a workforce strategist employed by a global HR tech startup. Your missiON is to determINe the percentage of  fully remote work for each 
 experience level IN 2021 and compare it WITH the correspONdINg figures for 2024, highlightINg any significant INcreASes or decreASes IN remote work adoptiON
 over the years.*/
 
 WITH t1 AS 
 (
		SELECT a.experience_level, total_remote ,total_2021, ROUND((((total_remote)/total_2021)*100),2) AS '2021 remote %' FROM
		( 
		   SELECT experience_level, COUNT(experience_level) AS total_remote FROM salaries WHERE work_year=2021 and remote_ratio = 100 GROUP BY experience_level
		)a
		INNER JOIN
		(
		  SELECT  experience_level, COUNT(experience_level) AS total_2021 FROM salaries WHERE work_year=2021 GROUP BY experience_level
		)b ON a.experience_level= b.experience_level
  ),
  t2 AS
     (
		SELECT a.experience_level, total_remote ,total_2024, ROUND((((total_remote)/total_2024)*100),2)AS '2024 remote %' FROM
		( 
		SELECT experience_level, COUNT(experience_level) AS total_remote FROM salaries WHERE work_year=2024 and remote_ratio = 100 GROUP BY experience_level
		)a
		INNER JOIN
		(
		SELECT  experience_level, COUNT(experience_level) AS total_2024 FROM salaries WHERE work_year=2024 GROUP BY experience_level
		)b ON a.experience_level= b.experience_level
  ) 
  
 SELECT * FROM t1 INNER JOIN t2 ON t1.experience_level = t2.experience_level;
 
 /* 8. AS a compensatiON specialist at a Fortune 500 company, you're tASked WITH analyzINg salary trends over time. Your objective is to calculate the average 
salary INcreASe percentage for each experience level and job title between the years 2023 and 2024, helpINg the company stay competitive IN the talent market.*/

with t as 
(
SELECT experience_level, job_title ,work_year, round(AVG(salary_in_usd),2) AS 'average'  FROM salaries WHERE work_year IN (2023,2024) 
GROUP BY experience_level, job_title, work_year order by experience_level, job_title, work_year
)

SELECT *,round((((AVG_salary_2024-AVG_salary_2023)/AVG_salary_2023)*100),2)  AS changes
FROM
(
 select experience_level, job_title,
 max(case when work_year = 2023 then average end) as AVG_salary_2023,
 max(case when work_year = 2024 then average end) as AVG_salary_2024
 from t GROUP BY experience_level, job_title 
 )m where round((((AVG_salary_2024-AVG_salary_2023)/AVG_salary_2023)*100),2) is not null;

/* 9. Find out the top 5 highest and lowest paying jobs*/

select job_title, avg(salary_in_usd) as Average_Salary from salaries group by job_title order by Average_Salary DESC limit 5;
select job_title, avg(salary_in_usd) as Average_Salary from salaries group by job_title order by Average_Salary asc limit 5;
 
 select job_title, avg(salary_in_usd) as Average_Salary from salaries group by job_title order by Average_Salary DESC limit 5;
 
 /* 10. You're a database administrator tasked with role-based access control for a company's employee database. Your goal is to implement a security measure where employees
 in different experience level (e.g.Entry Level, Senior level etc.) can only access details relevant to their respective experience_level, ensuring data 
 confidentiality and minimizing the risk of unauthorized access.*/

CREATE USER 'Entry_level'@'%' IDENTIFIED BY 'EN';
CREATE USER 'Junior_Mid_level'@'%' IDENTIFIED BY ' MI '; 
CREATE USER 'Intermediate_Senior_level'@'%' IDENTIFIED BY 'SE';
CREATE USER 'Expert_Executive-level '@'%' IDENTIFIED BY 'EX ';


CREATE VIEW entry_level AS
SELECT * FROM salaries where experience_level='EN';

CREATE VIEW Junior_Mid_level AS
SELECT * FROM salaries where experience_level='MI';

CREATE VIEW Intermediate_Senior_level AS
SELECT * FROM salaries where experience_level='SE';

CREATE VIEW Expert_Executive_level AS
SELECT * FROM salaries where experience_level='EX';

GRANT SELECT ON campusx.entry_level TO 'Entry_level'@'%';
GRANT SELECT ON campusx.entry_level TO 'Junior_Mid_level'@'%';
GRANT SELECT ON campusx.entry_level TO 'Intermediate_Senior_level'@'%';
GRANT SELECT ON campusx.entry_level TO 'Expert_Executive-level'@'%';
