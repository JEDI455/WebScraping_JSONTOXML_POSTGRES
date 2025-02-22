CREATE VIEW JobSummary AS
SELECT
    j.JobName AS Job,
    ARRAY_AGG(DISTINCT d.DepartmentName) AS Departments,
    (
        SELECT jsonb_agg(
            jsonb_build_object(
                'Отдел', d.departmentname,
	            'Имя', e.Name,
                'Фамилия', e.Surname
            )
        )
        FROM Employees e
        JOIN Salaries s ON e.Employee_ID = s.Employee_ID
        JOIN employment_history eh ON e.Employee_ID = eh.Employee_ID
	    JOIN Departments d ON e.DepartmentID = d.DepartmentID
        WHERE e.JobID = j.JobID AND eh.Promotion_Date >= '2021-01-01'

    ) AS Employees,
    ROUND(AVG(s.Salary), 2) AS AvgSalary
FROM
    Job j
JOIN
    Employees e ON j.JobID = e.JobID
JOIN
    Salaries s ON e.Employee_ID = s.Employee_ID
JOIN
    Departments d ON e.DepartmentID = d.DepartmentID
GROUP BY
    j.JobName, j.JobID;