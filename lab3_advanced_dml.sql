CREATE DATABASE advanced_lab;
USE advanced_lab;
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS departments CASCADE;
DROP TABLE IF EXISTS projects CASCADE;
CREATE TABLE employees (
    emp_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    department VARCHAR(50),
    salary INT,
    hire_date DATE,
    status VARCHAR(20) DEFAULT 'Active'
);
CREATE TABLE departments (
    dept_id SERIAL PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL,
    budget INT,
    manager_id INT
);
CREATE TABLE projects (
    projects_id SERIAL PRIMARY KEY,
    project_name VARCHAR(100) NOT NULL,
    dept_id INT,
    start_date DATE,
    end_date DATE,
    budget INT
);

INSERT INTO employees (emp_id, first_name, last_name, department)
VALUES (1, 'Aknur', 'Nusip', 'IT');

INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES ('Aitolkyn', 'Kaldybek', 'HR', DEFAULT, '2026-09-30', DEFAULT);

INSERT INTO departments (dept_name, budget, manager_id)
VALUES
    ('HR', 50000, 101),
    ('IT', 120000, 102),
    ('Finance', 90000, 103);

INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES ('Timur', 'Zhanbekov', 'IT', 50000 * 1.1, CURRENT_DATE, 'Active');

CREATE TABLE temp_employees AS SELECT * FROM employees WHERE department = 'IT';

UPDATE employees SET salary = salary * 1.1 WHERE emp_id > 0;

UPDATE employees SET status = 'Senior' WHERE salary > 60000 AND hire_date < '2020-01-01';

UPDATE employees SET department = CASE
                     WHEN salary > 80000 THEN 'Management'
                     WHEN salary BETWEEN 50000 AND 80000 THEN 'Senior'
                     ELSE 'Junior'
    END WHERE emp_id > 0;

UPDATE employees SET department = DEFAULT WHERE status = 'Inactive';

UPDATE departments d
SET budget = (
    SELECT AVG(e.salary) * 1.2
    FROM employees e
    WHERE e.department = d.dept_name
)
WHERE EXISTS (
    SELECT 1 FROM employees e WHERE e.department = d.dept_name
);

UPDATE employees
SET salary = salary * 1.15,
    status = 'Promoted'
WHERE department = 'Sales';

DELETE FROM employees WHERE status = 'Terminated';

DELETE FROM employees
WHERE salary < 40000
  AND hire_date > '2023-01-01'
  AND department IS NULL;

DELETE FROM departments
WHERE dept_id NOT IN (
    SELECT DISTINCT dept_id
    FROM employees
    WHERE department IS NOT NULL
);

DELETE FROM projects WHERE end_date < '2023-01-01' RETURNING *;

INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES ('Zangar', 'Suleimenov', NULL, NULL, CURRENT_DATE, 'Active');

UPDATE employees SET department = 'Unassigned' WHERE department IS NULL;

DELETE FROM employees WHERE salary IS NULL OR department IS NULL;

INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES ('Madina', 'Omarova', 'Finance', 75000, CURRENT_DATE, 'Active')
RETURNING emp_id, (first_name || ' ' || last_name) AS full_name;

UPDATE employees SET salary = salary + 5000 WHERE department = 'IT' RETURNING emp_id, salary - 5000 AS old_salary, salary AS new_salary;

DELETE FROM employees WHERE hire_date < '2020-01-01' RETURNING *;

INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
SELECT 'Dias', 'Kuatov', 'Marketing', 60000, CURRENT_DATE, 'Active'
WHERE NOT EXISTS (
    SELECT 1 FROM employees
    WHERE first_name = 'Dias' AND last_name = 'Kuatov'
);

UPDATE employees e
SET salary = salary * CASE
                          WHEN (SELECT d.budget FROM departments d WHERE d.dept_name = e.department) > 100000 THEN 1.10
                          ELSE 1.05
    END
WHERE department IS NOT NULL;

INSERT INTO employees (first_name, last_name, department, salary, hire_date, status)
VALUES
    ('Ali', 'khan', 'Sales', 50000, CURRENT_DATE, 'Active'),
    ('Aigerim', 'Talgat', 'Sales', 52000, CURRENT_DATE, 'Active'),
    ('Nurlan', 'Sabyr', 'IT', 70000, CURRENT_DATE, 'Active'),
    ('Dinara', 'Kalybek', 'HR', 48000, CURRENT_DATE, 'Active'),
    ('Erlan', 'Musin', 'Finance', 65000, CURRENT_DATE, 'Active');

UPDATE employees SET salary = salary * 1.1 WHERE first_name IN ('Ali', 'Aigerim', 'Nurlan', 'Dinara', 'Erlan');

CREATE TABLE employee_archive AS SELECT * FROM employees WHERE 1 = 0;

INSERT INTO employee_archive SELECT * FROM employees WHERE status = 'Inactive';

DELETE FROM employees WHERE status = 'Inactive';

UPDATE projects p
SET end_date = end_date + INTERVAL '30 days'
WHERE p.budget > 50000
  AND (
          SELECT COUNT(*)
          FROM employees e
          WHERE e.department = (SELECT d.dept_name FROM departments d WHERE d.dept_id = p.dept_id)
      ) > 3;
