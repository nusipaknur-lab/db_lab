--  Nussip Aknur
--  id: 25B031433
DROP TABLE employees;
DROP TABLE departments;
DROP TABLE projects;
CREATE TABLE employees (
                           emp_id INT PRIMARY KEY,
                           emp_name VARCHAR(50),
                           dept_id INT,
                           salary DECIMAL(10, 2)
);
CREATE TABLE departments (
                             dept_id INT PRIMARY KEY,
                             dept_name VARCHAR(50),
                             location VARCHAR(50)
);
CREATE TABLE projects (
                          project_id INT PRIMARY KEY,
                          project_name VARCHAR(50),
                          dept_id INT,
                          budget DECIMAL(10, 2)
);
INSERT INTO employees (emp_id, emp_name, dept_id, salary)
VALUES
(1, 'John Smith', 101, 50000),
(2, 'Jane Doe', 102, 60000),
(3, 'Mike Johnson', 101, 55000),
(4, 'Sarah Williams', 103, 65000),
(5, 'Tom Brown', NULL, 45000);
INSERT INTO departments (dept_id, dept_name, location) VALUES
                                                           (101, 'IT', 'Building A'),
                                                           (102, 'HR', 'Building B'),
                                                           (103, 'Finance', 'Building C'),
                                                           (104, 'Marketing', 'Building D');
INSERT INTO projects (project_id, project_name, dept_id,
                      budget) VALUES
                                  (1, 'Website Redesign', 101, 100000),
                                  (2, 'Employee Training', 102, 50000),
                                  (3, 'Budget Analysis', 103, 75000),
                                  (4, 'Cloud Migration', 101, 150000),
                                  (5, 'AI Research', NULL, 200000);
-- task 2.1
CREATE VIEW employee_details AS
SELECT emp_name, salary, dept_name, location
FROM employees
INNER JOIN departments
ON employees.dept_id = departments.dept_id;
-- 4 rows because Tom Brown doesnt appear, his dept_id is NULL

-- task 2.2
CREATE VIEW dept_statistics AS
SELECT
dept_name,
COUNT(emp_id) AS employee_count,
AVG(salary) AS average_salary,
MAX(salary) AS maximum_salary,
MIN(salary) AS minimum_salary
FROM departments
LEFT JOIN employees
ON departments.dept_id = employees.dept_id
GROUP BY departments.dept_id, departments.dept_name;

SELECT *
FROM dept_statistics
ORDER BY employee_count DESC;

-- task 2.3
CREATE VIEW project_overview AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    d.location,
    COUNT(e.emp_id) AS team_size
FROM projects p
         LEFT JOIN departments d
                   ON p.dept_id = d.dept_id
         LEFT JOIN employees e
                   ON d.dept_id = e.dept_id
GROUP BY
    p.project_id,
    p.project_name,
    p.budget,
    d.dept_name,
    d.location;
SELECT * FROM project_overview;

-- 2.4
CREATE VIEW high_earners AS
SELECT
    e.emp_name,
    e.salary,
    d.dept_name
FROM employees e
         LEFT JOIN departments d
                   ON e.dept_id = d.dept_id
WHERE e.salary > 55000;

SELECT * FROM high_earners;

-- 3.1
CREATE OR REPLACE VIEW employee_details AS
SELECT
    e.emp_name,
    e.salary,
    d.dept_name,
    d.location,
    CASE
        WHEN e.salary > 60000 THEN 'High'
        WHEN e.salary > 50000 THEN 'Medium'
        ELSE 'Standard'
        END AS salary_grade
FROM employees e
         INNER JOIN departments d
                    ON e.dept_id = d.dept_id;

-- 3.2
    ALTER VIEW high_earners
    RENAME TO top_performers;

SELECT * FROM top_performers;

-- 3.3
CREATE VIEW temp_view AS
SELECT *
FROM employees
WHERE salary < 50000;

DROP VIEW temp_view;

-- 4.1
CREATE VIEW employee_salaries AS
SELECT
    emp_id,
    emp_name,
    dept_id,
    salary
FROM employees;

-- 4.2
UPDATE employee_salaries
SET salary = 52000
WHERE emp_name = 'John Smith';

SELECT *
FROM employees
WHERE emp_name = 'John Smith';

-- 4.3
INSERT INTO employee_salaries
(emp_id, emp_name, dept_id, salary)
VALUES
    (6, 'Alice Johnson', 102, 58000);

SELECT * FROM employees;

-- 4.4
DROP VIEW IF EXISTS it_employees;

CREATE VIEW it_employees AS
SELECT
    emp_id,
    emp_name,
    dept_id,
    salary
FROM employees
WHERE dept_id = 101
        WITH LOCAL CHECK OPTION;

INSERT INTO it_employees
(emp_id, emp_name, dept_id, salary)
VALUES
    (7, 'Bob Wilson', 103, 60000);

-- 5.1
CREATE MATERIALIZED VIEW dept_summary_mv AS
WITH employee_stats AS (
    SELECT
        dept_id,
        COUNT(*) AS total_employees,
        SUM(salary) AS total_salaries
    FROM employees
    GROUP BY dept_id
),
     project_stats AS (
         SELECT
             dept_id,
             COUNT(*) AS total_projects,
             SUM(budget) AS total_project_budget
         FROM projects
         GROUP BY dept_id
     )
SELECT
    d.dept_id,
    d.dept_name,
    COALESCE(e.total_employees, 0) AS total_employees,
    COALESCE(e.total_salaries, 0) AS total_salaries,
    COALESCE(p.total_projects, 0) AS total_projects,
    COALESCE(p.total_project_budget, 0) AS total_project_budget
FROM departments d
         LEFT JOIN employee_stats e
                   ON d.dept_id = e.dept_id
         LEFT JOIN project_stats p
                   ON d.dept_id = p.dept_id
WITH DATA;

SELECT *
FROM dept_summary_mv
ORDER BY total_employees DESC;

-- 5.2
INSERT INTO employees
(emp_id, emp_name, dept_id, salary)
VALUES
    (8, 'Charlie Brown', 101, 54000);

-- Before
SELECT * FROM dept_summary_mv;

-- Refresh
REFRESH MATERIALIZED VIEW dept_summary_mv;

-- After
SELECT * FROM dept_summary_mv;

-- 5.3
CREATE UNIQUE INDEX dept_summary_idx
    ON dept_summary_mv (dept_id);

REFRESH MATERIALIZED VIEW CONCURRENTLY dept_summary_mv;

-- 5.4
CREATE MATERIALIZED VIEW project_stats_mv AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    COUNT(e.emp_id) AS assigned_employees
FROM projects p
         LEFT JOIN departments d
                   ON p.dept_id = d.dept_id
         LEFT JOIN employees e
                   ON d.dept_id = e.dept_id
GROUP BY
    p.project_id,
    p.project_name,
    p.budget,
    d.dept_name
WITH NO DATA;

-- Try to query
SELECT * FROM project_stats_mv;

-- Fix
REFRESH MATERIALIZED VIEW project_stats_mv;

SELECT * FROM project_stats_mv;

-- 6.1
CREATE ROLE analyst;

CREATE ROLE data_viewer
    WITH LOGIN PASSWORD 'viewer123';

CREATE USER report_user
    WITH PASSWORD 'report456';

SELECT rolname
FROM pg_roles
WHERE rolname NOT LIKE 'pg_%';

-- 6.2
CREATE ROLE db_creator
    WITH CREATEDB LOGIN PASSWORD 'creator789';

CREATE ROLE user_manager
    WITH CREATEROLE LOGIN PASSWORD 'manager101';

CREATE ROLE admin_user
    WITH SUPERUSER LOGIN PASSWORD 'admin999';

-- 6.3
GRANT SELECT
    ON employees, departments, projects
    TO analyst;

GRANT ALL PRIVILEGES
    ON employee_details
    TO data_viewer;

GRANT SELECT, INSERT
    ON employees
    TO report_user;

-- 6.4
-- Group roles
CREATE ROLE hr_team;
CREATE ROLE finance_team;
CREATE ROLE it_team;

-- Individual users
CREATE USER hr_user1 WITH PASSWORD 'hr001';
CREATE USER hr_user2 WITH PASSWORD 'hr002';
CREATE USER finance_user1 WITH PASSWORD 'fin001';

-- Assign members
GRANT hr_team TO hr_user1;
GRANT hr_team TO hr_user2;
GRANT finance_team TO finance_user1;

-- Grant privileges
GRANT SELECT, UPDATE
    ON employees
    TO hr_team;

GRANT SELECT
    ON dept_statistics
    TO finance_team;

-- 6.5
REVOKE UPDATE
    ON employees
    FROM hr_team;

REVOKE hr_team
    FROM hr_user2;

REVOKE ALL PRIVILEGES
    ON employee_details
    FROM data_viewer;

-- 6.6
ALTER ROLE analyst
    WITH LOGIN PASSWORD 'analyst123';

ALTER ROLE user_manager
    WITH SUPERUSER;

ALTER ROLE analyst
    WITH PASSWORD NULL;

ALTER ROLE data_viewer
    WITH CONNECTION LIMIT 5;

-- 7.1
CREATE ROLE read_only;

GRANT SELECT
    ON ALL TABLES IN SCHEMA public
    TO read_only;

CREATE ROLE junior_analyst
    WITH LOGIN PASSWORD 'junior123';

CREATE ROLE senior_analyst
    WITH LOGIN PASSWORD 'senior123';

GRANT read_only TO junior_analyst;
GRANT read_only TO senior_analyst;

GRANT INSERT, UPDATE
    ON employees
    TO senior_analyst;

-- 7.2
CREATE ROLE project_manager
    WITH LOGIN PASSWORD 'pm123';

GRANT CREATE
    ON SCHEMA public
    TO project_manager;

ALTER VIEW dept_statistics
    OWNER TO project_manager;

ALTER TABLE projects
    OWNER TO project_manager;

SELECT tablename, tableowner
FROM pg_tables
WHERE schemaname = 'public';

-- 7.3
CREATE ROLE temp_owner WITH LOGIN;

CREATE TABLE temp_table (
                            id INT
);

ALTER TABLE temp_table
    OWNER TO temp_owner;

REASSIGN OWNED BY temp_owner TO postgres;

DROP OWNED BY temp_owner;

DROP ROLE temp_owner;

-- 7.4
CREATE VIEW hr_employee_view AS
SELECT *
FROM employees
WHERE dept_id = 102;

GRANT SELECT
    ON hr_employee_view
    TO hr_team;


CREATE VIEW finance_employee_view AS
SELECT
    emp_id,
    emp_name,
    salary
FROM employees;

GRANT SELECT
    ON finance_employee_view
    TO finance_team;

-- 8.1
CREATE VIEW dept_dashboard AS
WITH employee_stats AS (
    SELECT
        dept_id,
        COUNT(*) AS employee_count,
        AVG(salary) AS average_salary
    FROM employees
    GROUP BY dept_id
),
     project_stats AS (
         SELECT
             dept_id,
             COUNT(*) AS active_projects,
             SUM(budget) AS total_project_budget
         FROM projects
         GROUP BY dept_id
     )
SELECT
    d.dept_name,
    d.location,
    COALESCE(e.employee_count, 0) AS employee_count,
    ROUND(COALESCE(e.average_salary, 0), 2) AS average_salary,
    COALESCE(p.active_projects, 0) AS active_projects,
    COALESCE(p.total_project_budget, 0) AS total_project_budget,
    ROUND(
            COALESCE(
                    p.total_project_budget / NULLIF(e.employee_count, 0),
                    0
            ),
            2
    ) AS budget_per_employee
FROM departments d
         LEFT JOIN employee_stats e
                   ON d.dept_id = e.dept_id
         LEFT JOIN project_stats p
                   ON d.dept_id = p.dept_id;

-- 8.2
ALTER TABLE projects
    ADD COLUMN created_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

CREATE VIEW high_budget_projects AS
SELECT
    p.project_name,
    p.budget,
    d.dept_name,
    p.created_date,
    CASE
        WHEN p.budget > 150000 THEN 'Critical Review Required'
        WHEN p.budget > 100000 THEN 'Management Approval Needed'
        ELSE 'Standard Process'
        END AS approval_status
FROM projects p
         LEFT JOIN departments d
                   ON p.dept_id = d.dept_id
WHERE p.budget > 75000;

-- 8.3
-- Level 1
CREATE ROLE viewer_role;

GRANT SELECT
    ON ALL TABLES IN SCHEMA public
    TO viewer_role;


-- Level 2
CREATE ROLE entry_role;

GRANT viewer_role TO entry_role;

GRANT INSERT
    ON employees, projects
    TO entry_role;


-- Level 3
CREATE ROLE analyst_role;

GRANT entry_role TO analyst_role;

GRANT UPDATE
    ON employees, projects
    TO analyst_role;


-- Level 4
CREATE ROLE manager_role;

GRANT analyst_role TO manager_role;

GRANT DELETE
    ON employees, projects
    TO manager_role;


-- Create Users
CREATE USER alice WITH PASSWORD 'alice123';
CREATE USER bob WITH PASSWORD 'bob123';
CREATE USER charlie WITH PASSWORD 'charlie123';


-- Assign Users
GRANT viewer_role TO alice;
GRANT analyst_role TO bob;
GRANT manager_role TO charlie;