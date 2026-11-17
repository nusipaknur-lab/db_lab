--  Nusip Aknur
--  id: 25B031433
-- Create tables
DROP TABLE departments CASCADE;
DROP TABLE employees CASCADE;
DROP TABLE projects CASCADE;
CREATE TABLE departments (
                             dept_id INT PRIMARY KEY,
                             dept_name VARCHAR(50),
                             location VARCHAR(50)
);
CREATE TABLE employees (
                           emp_id INT PRIMARY KEY,
                           emp_name VARCHAR(100),
                           dept_id INT,
                           salary DECIMAL(10,2),
                           FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);
CREATE TABLE projects (
                          proj_id INT PRIMARY KEY,
                          proj_name VARCHAR(100),
                          budget DECIMAL(12,2),
                          dept_id INT,
                          FOREIGN KEY (dept_id) REFERENCES departments(dept_id)
);
-- Insert sample data
INSERT INTO departments VALUES
                            (101, 'IT', 'Building A'),
                            (102, 'HR', 'Building B'),
                            (103, 'Operations', 'Building C');
INSERT INTO employees VALUES
                          (1, 'John Smith', 101, 50000),
                          (2, 'Jane Doe', 101, 55000),
                          (3, 'Mike Johnson', 102, 48000),
                          (4, 'Sarah Williams', 102, 52000),
                          (5, 'Tom Brown', 103, 60000);
INSERT INTO projects VALUES
                         (201, 'Website Redesign', 75000, 101),
                         (202, 'Database Migration', 120000, 101),
                         (203, 'HR System Upgrade', 50000, 102);

CREATE INDEX emp_salary_idx ON employees(salary);

SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees';
-- There are two indexes on the employees table.
-- One index is created automatically for the primary key.
-- The second index is created on the salary column.

-- Exercise 2.2:
CREATE INDEX emp_dept_idx ON employees(dept_id);

SELECT * FROM employees WHERE dept_id = 101;
-- Indexes on foreign key columns make JOIN queries faster. They also help PostgreSQL find related rows quickly.

-- Exercise 2.3:
SELECT
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;
-- The employees table has indexes on emp_id, salary, and dept_id.
-- The emp_id index was created automatically because it is a primary key.
-- The salary and dept_id indexes were created manually.

-- Exercise 3.1:
CREATE INDEX emp_dept_salary_idx ON employees(dept_id, salary);

SELECT emp_name, salary
FROM employees
WHERE dept_id = 101 AND salary > 52000;
-- No, it is not very useful.
-- The index starts with dept_id. The query uses only salary. PostgreSQL may need to check many rows.

-- Exercise 3.2:
CREATE INDEX emp_salary_dept_idx ON employees(salary, dept_id);

-- Query 1: Filters by dept_id first
                 SELECT * FROM employees WHERE dept_id = 102 AND salary > 50000;
-- Query 2: Filters by salary first
SELECT * FROM employees WHERE salary > 50000 AND dept_id = 102;
-- Yes, column order is important.
-- PostgreSQL uses the first column of the index more easily. The best order depends on the query.

-- Exercise 4.1:
ALTER TABLE employees ADD COLUMN email VARCHAR(100);
UPDATE employees SET email = 'john.smith@company.com' WHERE emp_id = 1;
UPDATE employees SET email = 'jane.doe@company.com' WHERE emp_id = 2;
UPDATE employees SET email = 'mike.johnson@company.com' WHERE emp_id = 3;
UPDATE employees SET email = 'sarah.williams@company.com' WHERE emp_id = 4;
UPDATE employees SET email = 'tom.brown@company.com' WHERE emp_id = 5;

CREATE UNIQUE INDEX emp_email_unique_idx ON employees(email);

-- This should fail with a unique violation error
INSERT INTO employees (emp_id, emp_name, dept_id, salary, email)
VALUES (6, 'New Employee', 101, 55000, 'john.smith@company.com');

-- I received a unique violation error. The email already exists in the table. Duplicate email values are not allowed.

-- Exercise 4.2:
-- Add a phone column with UNIQUE constraint
ALTER TABLE employees ADD COLUMN phone VARCHAR(20) UNIQUE;

SELECT indexname, indexdef
FROM pg_indexes
WHERE tablename = 'employees' AND indexname LIKE '%phone%';

-- Yes, PostgreSQL created an index automatically. It is a unique B-tree index.

-- Exercise 5.1:
CREATE INDEX emp_salary_desc_idx ON employees(salary DESC);

SELECT emp_name, salary
FROM employees
ORDER BY salary DESC;

-- This index helps PostgreSQL sort data faster.
-- It stores salary values in descending order. It can reduce sorting work.

-- Exercise 5.2:
CREATE INDEX proj_budget_nulls_first_idx ON projects(budget NULLS FIRST);

SELECT proj_name, budget
FROM projects
ORDER BY budget NULLS FIRST;

-- Exercise 6.1:
CREATE INDEX emp_name_lower_idx ON employees(LOWER(emp_name));

-- This query can use the expression index
SELECT * FROM employees WHERE LOWER(emp_name) = 'john smith';

-- Without this index, PostgreSQL would check the rows one by one.
-- It would use the LOWER function for each name. This can be slower.

-- Exercise 6.2: Index on Calculated Values
ALTER TABLE employees ADD COLUMN hire_date DATE;
UPDATE employees SET hire_date = '2020-01-15' WHERE emp_id = 1;
UPDATE employees SET hire_date = '2019-06-20' WHERE emp_id = 2;
UPDATE employees SET hire_date = '2021-03-10' WHERE emp_id = 3;
UPDATE employees SET hire_date = '2020-11-05' WHERE emp_id = 4;
UPDATE employees SET hire_date = '2018-08-25' WHERE emp_id = 5;
-- Create index on the year extracted from hire_date
CREATE INDEX emp_hire_year_idx ON employees(EXTRACT(YEAR FROM hire_date));

SELECT emp_name, hire_date
FROM employees
WHERE EXTRACT(YEAR FROM hire_date) = 2020;

-- Exercise 7.1: Rename an Index
ALTER INDEX emp_salary_idx RENAME TO employees_salary_index;

SELECT indexname FROM pg_indexes WHERE tablename = 'employees';
-- Exercise 7.2:
DROP INDEX emp_salary_dept_idx;
-- Indexes use disk space.
-- They can also make INSERT, UPDATE, and DELETE operations slower. We can drop indexes that we do not need.

-- Exercise 7.3: Reindex
REINDEX INDEX employees_salary_index;
-- REINDEX is useful when an index becomes large or damaged. It rebuilds the index and can improve its performance.

--Exercise 8.1:
SELECT e.emp_name, e.salary, d.dept_name
FROM employees e
         JOIN departments d ON e.dept_id = d.dept_id
WHERE e.salary > 50000
ORDER BY e.salary DESC;

-- Index for the WHERE clause
CREATE INDEX emp_salary_filter_idx ON employees(salary) WHERE salary > 50000;
-- Index for the JOIN
-- (already created: emp_dept_idx)
-- Index for ORDER BY
-- (already created: emp_salary_desc_idx)
-- Exercise 8.2:
CREATE INDEX proj_high_budget_idx ON projects(budget)
    WHERE budget > 80000;

SELECT proj_name, budget
FROM projects
WHERE budget > 80000;
-- A partial index stores only some rows. It uses less disk space. It can make specific queries faster.

-- Exercise 8.3:
EXPLAIN SELECT * FROM employees WHERE salary > 52000;
-- It can show an Index Scan or a Seq Scan.
-- Index Scan means PostgreSQL uses an index. Seq Scan means PostgreSQL checks the table rows one by one.

-- Exercise 9.1:
CREATE INDEX dept_name_hash_idx ON departments USING HASH (dept_name);

SELECT * FROM departments WHERE dept_name = 'IT';
-- We can use a HASH index for equality searches. It is useful when we search for exact values with the equals sign.

-- Exercise 9.2:
-- B-tree index
CREATE INDEX proj_name_btree_idx ON projects(proj_name);
-- Hash index
CREATE INDEX proj_name_hash_idx ON projects USING HASH (proj_name);

-- Equality search (both can be used)
SELECT * FROM projects WHERE proj_name = 'Website Redesign';
-- Range search (only B-tree can be used)
SELECT * FROM projects WHERE proj_name > 'Database';

-- Exercise 10.1:
SELECT
schemaname,
tablename,
indexname,
pg_size_pretty(pg_relation_size(indexname::regclass)) as index_size
FROM pg_indexes
WHERE schemaname = 'public'
ORDER BY tablename, indexname;
-- The largest index is the one with the biggest size in the result. It may be larger because it stores more data.

-- Exercise 10.2:
-- Drop the duplicate expression indexes
DROP INDEX IF EXISTS proj_name_hash_idx;
-- Keep only necessary indexes
-- Exercise 10.3:
CREATE VIEW index_documentation AS
SELECT
tablename,
indexname,
indexdef,
'Improves salary-based queries' as purpose
FROM pg_indexes
WHERE schemaname = 'public'
AND indexname LIKE '%salary%';
SELECT * FROM index_documentation;

-- Summary Questions
-- 1. What is the default index type in PostgreSQL? The default index type in PostgreSQL is B-tree.
-- 2. Name three scenarios where you should create an index.
-- 1. On columns used in WHERE clauses.
-- 2. On columns used in JOIN conditions.
-- 3. On columns used in ORDER BY.
-- 3. Name two scenarios where you should NOT create an index.
-- 1. On columns that are rarely used in queries.
-- 2. On tables with very few rows.
-- 4. What happens to indexes when you INSERT, UPDATE, or DELETE data? Indexes are updated automatically. These operations can become slower because PostgreSQL must update the indexes too.
-- 5. How can you check if a query is using an index? We can use the EXPLAIN command. It shows if PostgreSQL uses Index Scan or Seq Scan.