CREATE VIEW Average_Salaries AS 
SELECT
	j.jobname,
	CAST(AVG(s.salary) AS INT) AS AvgSalary,
	CASE
		WHEN AVG(s.salary) > (SELECT AVG(salary) FROM salaries) THEN 'Да'
		ELSE 'Нет'
	END AS "Больше Ли Средней ЗП"
FROM job AS j
JOIN employees AS e ON j.jobid=e.jobid
JOIN salaries AS s ON e.employee_id = s.employee_id
GROUP BY j.jobname;