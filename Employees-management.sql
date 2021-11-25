# a breakdown between the male and female employees working in the company each year, starting from 1990
SELECT 
    YEAR(de.from_date) AS cal_year,
    COUNT(e.gender) AS gender_total,
    gender
FROM
    t_employees e
        JOIN
    t_dept_emp de ON e.emp_no = de.emp_no
WHERE
    YEAR(de.from_date) <= YEAR(de.to_date)
        AND YEAR(de.from_date) >= 1990
GROUP BY e.gender , cal_year
ORDER BY cal_year;

#a comparison of the number of male managers to the number of female managers from different departments for each year, starting from 1990.
SELECT 
    d.dept_name,
    ee.gender,
    dm.emp_no,
    dm.from_date,
    dm.to_date,
    e.calendar_year,
    CASE
        WHEN
            YEAR(dm.to_date) >= e.calendar_year
                AND YEAR(dm.from_date) <= e.calendar_year
        THEN
            1
        ELSE 0
    END AS Current_manager
FROM
    (SELECT 
        YEAR(hire_date) AS calendar_year
    FROM
        t_employees
    GROUP BY calendar_year) e
        CROSS JOIN
    t_dept_manager dm
        JOIN
    t_departments d ON dm.dept_no = d.dept_no
        JOIN
    t_employees ee ON dm.emp_no = ee.emp_no
ORDER BY dm.emp_no , calendar_year;


# a comparison of the average salary of female versus male employees in the entire company until year 2002.
SELECT DISTINCT
    YEAR(s.from_date) AS calendar_year,
    ROUND(AVG(s.salary), 2) AS salary_average,
    e.gender,
    d.dept_name
FROM
    t_departments d
        JOIN
    t_dept_emp de ON d.dept_no = de.dept_no
        JOIN
    t_salaries s ON de.emp_no = s.emp_no
        JOIN
    t_employees e ON e.emp_no = s.emp_no
GROUP BY de.dept_no , e.gender , calendar_year
HAVING calendar_year BETWEEN 1990 AND 2002
ORDER BY calendar_year;

#the average male and female salary per department using a stored procedure.
Use employees_mod;
Drop procedure if exists dept_salary;

Delimiter $$

CREATE PROCEDURE  dept_salary(in p_min_salary float, in p_max_salary float )
BEGIN
	SELECT 
    d.dept_name,
    e.gender,
    ROUND(AVG(s.salary), 2) AS average_salary
FROM
    t_salaries s
        JOIN
    t_employees e ON e.emp_no = s.emp_no
        JOIN
    t_dept_emp de ON s.emp_no = de.emp_no
        JOIN
    t_departments d ON de.dept_no = d.dept_no
WHERE
    s.salary BETWEEN p_min_salary AND p_max_salary
GROUP BY d.dept_name , e.gender;
    
END $$

delimiter ;

call dept_salary(50000, 90000);

