-- Create hr_analytics Database 
CREATE DATABASE hr_analytics; 
-- create employees table 
CREATE TABLE employees (
	Age INT,
	Attrition VARCHAR(10),
	Department VARCHAR(50),
	Gender VARCHAR(10),
	JobRole VARCHAR(50),
	MonthlyIncome INT,
	YearsAtCompany INT
);
-- check if any columns in employees table have null values 
SELECT 
	COUNT(*) FILTER (WHERE Age IS NULL) AS age_nulls, 
	COUNT(*) FILTER (WHERE Attrition IS NULL) AS attrition_nulls,
	COUNT(*) FILTER (WHERE Department IS NULL) AS dept_nulls,
	COUNT(*) FILTER (WHERE MonthlyIncome IS NULL) AS salary_nulls, 
	COUNT(*) FILTER (WHERE YearsAtCompany IS NULL) AS tenure_nulls 
FROM employees; 
-- attrition_rate 
SELECT 
	COUNT(CASE WHEN Attrition = 'Yes' THEN 1 END) * 100.0 / COUNT(*) AS attrition_rate 
FROM employees;
-- Which departments have highest attrition? 
SELECT 
	Department, 
	COUNT(*) AS total,
	COUNT(CASE WHEN Attrition = 'Yes' THEN 1 END) AS attrition_count 
FROM employees 
GROUP BY Department 
ORDER BY attrition_count DESC; 
-- Does salary impact attrition? 
WITH Quartiles AS (
	SELECT 
		PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY monthlyincome) AS Q1,
		PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY monthlyincome) AS median,
		PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY monthlyincome) AS Q3 
	FROM employees
	)
SELECT 
	CASE 
		WHEN e.monthlyincome < q.Q1 THEN 'Low Salary'
		WHEN e.monthlyincome BETWEEN q.Q1 AND q.median THEN 'Lower Mid Salary'
		WHEN e.monthlyincome BETWEEN q.median AND q.Q3 THEN 'Upper Mid Salary'
		ELSE 'High Salary' 
	END AS salary_range, 
	COUNT(*) AS total,
	COUNT(CASE WHEN e.attrition = 'Yes' THEN 1 END) AS attrition_count,
	ROUND(COUNT(CASE WHEN e.attrition = 'Yes' THEN 1 END) * 100.0/ COUNT(*), 2) AS attrition_rate 
FROM employees e 
CROSS JOIN Quartiles q 
GROUP BY salary_range 
ORDER BY attrition_rate DESC; 
-- Which age group leaves most? 
SELECT 
	CASE 
		WHEN age < 30 THEN 'Young' 
		WHEN age BETWEEN 30 AND 45 THEN 'Mid Age' 
		ELSE 'Senior' 
	END AS age_group, 
	COUNT(*) AS total, 
	COUNT(CASE WHEN attrition = 'Yes' THEN 1 END) AS attrition_count, 
	ROUND(COUNT(CASE WHEN attrition = 'Yes' THEN 1 END) * 100.0 / COUNT(*), 2) AS attrition_rate 
FROM employees 
GROUP BY age_group 
ORDER BY attrition_rate DESC; 
-- What is average tenure before leaving? 
SELECT 
	ROUND(AVG(YearsAtCompany)) AS average_tenure_before_leaving 
FROM employees 
WHERE Attrition = 'Yes';
-- attrition_by_department
CREATE VIEW attrition_by_department AS
SELECT 
	department,
	COUNT(*) AS total,
	COUNT(CASE WHEN attrition = 'Yes' THEN 1 END) AS attrition_count
FROM employees 
GROUP BY department;
-- attrition_by_age 
CREATE VIEW attrition_by_age AS 
SELECT 
	CASE 
		WHEN age < 30 THEN 'Young'
		WHEN age BETWEEN 30 AND 45 THEN 'Mid Age'
		ELSE 'Senior' 
	END AS age_group,
	COUNT(*) AS total,
	COUNT(CASE WHEN attrition = 'Yes' THEN 1 END) AS attrition_count,
	ROUND(COUNT(CASE WHEN attrition = 'Yes' THEN 1 END) * 100.0 / COUNT(*), 2) AS attrition_rate
FROM employees 
GROUP BY age_group 
ORDER BY attrition_rate DESC;
-- attrition_by_salary
CREATE VIEW attrition_by_salary AS 
WITH Quartiles AS (
	SELECT 
		PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY monthlyincome) AS Q1,
		PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY monthlyincome) AS median,
		PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY monthlyincome) AS Q3
	FROM employees 
	) 
SELECT 
	CASE 
		WHEN e.monthlyincome < q.Q1 THEN 'Low Salary'
		WHEN e.monthlyincome BETWEEN q.Q1 AND q.median THEN 'Lower Mid Salary'
		WHEN e.monthlyincome BETWEEN q.median AND q.Q3 THEN 'Upper Mid Salary'
		ELSE 'High Salary' 
	END AS salary_range,
	COUNT(*) AS total,
	COUNT(CASE WHEN e.attrition = 'Yes' THEN 1 END) AS attrition_count,
	ROUND(COUNT(CASE WHEN e.attrition = 'Yes' THEN 1 END) * 100.0/ COUNT(*), 2) AS attrition_rate 
FROM employees e 
CROSS JOIN Quartiles q 
GROUP BY salary_range 
ORDER BY attrition_rate DESC;