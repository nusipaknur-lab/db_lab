DROP TABLE IF EXISTS employees;
CREATE table employees (
    employee_id INTEGER,
    first_name TEXT,
    last_name TEXT,
    age INT CHECK (age BETWEEN 18 AND 65 ),
    salary NUMERIC CHECK (salary > 0)
);

CREATE TABLE products_catalog (
    product_id     INTEGER,
    product_name   TEXT,
    regular_price  NUMERIC,
    discount_price NUMERIC,
    CONSTRAINT valid_discount CHECK (
        regular_price > 0
            AND discount_price > 0
            AND discount_price < regular_price
    )
);

CREATE TABLE bookings (
    booking_id     INTEGER,
    check_in_date  DATE,
    check_out_date DATE,
    num_guests     INTEGER,
    CONSTRAINT check_guests CHECK ( num_guests BETWEEN 1 AND 10 ),
    CONSTRAINT check_date CHECK ( check_out_date > check_in_date )
);

DROP TABLE IF EXISTS employees CASCADE;
CREATE TABLE employees(
                          employee_id INTEGER,
                          first_name TEXT,
                          last_name TEXT,
                          age INT CHECK ( age BETWEEN 18  AND 65),
                          salary NUMERIC CHECK ( salary>0 )
);
DROP TABLE IF EXISTS products_catalog CASCADE;
CREATE TABLE products_catalog(
    product_id INTEGER,
    product_name TEXT,
    regular_price NUMERIC,
    discount_price NUMERIC,
    CONSTRAINT valid_discount CHECK (
        regular_price > 0
        AND discount_price > 0
        AND discount_price < regular_price
    )
);
DROP TABLE IF EXISTS bookings CASCADE;
CREATE TABLE bookings(
    booking_id INTEGER,
    check_in_date DATE,
    check_out_date DATE,
    num_guests INTEGER,
    CONSTRAINT check_guests CHECK (num_guests BETWEEN 1 AND 10),
    CONSTRAINT check_date CHECK(check_out_date>check_in_date)
);
INSERT INTO employees VALUES (1, 'Alice', 'Smith', 30, 55000.00);
INSERT INTO employees VALUES (2, 'Bob', 'Jones', 45, 75000.50);
INSERT INTO products_catalog VALUES (1, 'Laptop', 1200.00, 999.99);
INSERT INTO products_catalog VALUES (2, 'Headphones', 150.00, 120.00);
INSERT INTO bookings VALUES (1, '2026-07-01', '2026-07-07', 2);
INSERT INTO bookings VALUES (2, '2026-08-10', '2026-08-15', 4);


DROP TABLE IF EXISTS customers CASCADE;
CREATE TABLE customers(
                          customer_id INTEGER NOT NULL,
                          email TEXT NOT NULL,
                          phone TEXT,
                          registration_date DATE NOT NULL
);

DROP TABLE IF EXISTS inventory CASCADE;
CREATE TABLE inventory(
    item_id INTEGER NOT NULL,
    item_name TEXT NOT NULL,
    quantity INTEGER NOT NULL CHECK (quantity >= 0),
    unit_price NUMERIC NOT NULL CHECK (unit_price > 0),
    last_updated TIMESTAMP NOT NULL
);

INSERT INTO customers VALUES (1, 'alice@example.com', '555-0100', '2026-01-10');
INSERT INTO customers VALUES (2, 'bob@example.com', NULL, '2026-02-15');
INSERT INTO inventory VALUES (101, 'Mechanical Keyboard', 50, 89.99, CURRENT_TIMESTAMP);
INSERT INTO inventory VALUES (102, 'Gaming Mouse', 0, 49.99, CURRENT_TIMESTAMP);



DROP TABLE IF EXISTS users CASCADE;
CREATE TABLE users(
                      user_id INTEGER,
                      username TEXT CONSTRAINT unique_username UNIQUE,
                      email TEXT CONSTRAINT unique_email UNIQUE,
                      created_at TIMESTAMP
);

DROP TABLE IF EXISTS course_enrollments CASCADE;
CREATE TABLE course_enrollments(
                                   enrollment_id INTEGER,
                                   student_id INTEGER,
                                   course_code TEXT,
                                   semester TEXT,
                                   CONSTRAINT unique_student_course_semester UNIQUE (student_id, course_code, semester)
);

INSERT INTO users VALUES (1, 'johndoe', 'john@example.com', CURRENT_TIMESTAMP);



DROP TABLE IF EXISTS departments CASCADE;
CREATE TABLE departments(
                            dept_id INTEGER PRIMARY KEY,
                            dept_name TEXT NOT NULL,
                            location TEXT
);

INSERT INTO departments VALUES (1, 'HR', 'Building A');
INSERT INTO departments VALUES (2, 'Engineering', 'Building B');
INSERT INTO departments VALUES (3, 'Sales', 'Building C');

DROP TABLE IF EXISTS student_courses CASCADE;
CREATE TABLE student_courses(
                                student_id INTEGER,
                                course_id INTEGER,
                                enrollment_date DATE,
                                grade TEXT,
                                PRIMARY KEY (student_id, course_id)
);



DROP TABLE IF EXISTS employees_dept CASCADE;
CREATE TABLE employees_dept(
                               emp_id INTEGER PRIMARY KEY,
                               emp_name TEXT NOT NULL,
                               dept_id INTEGER REFERENCES departments(dept_id),
                               hire_date DATE
);

INSERT INTO employees_dept VALUES (1, 'Alice Smith', 1, '2025-01-15');
INSERT INTO employees_dept VALUES (2, 'Bob Jones', 2, '2025-03-20');

DROP TABLE IF EXISTS books CASCADE;
DROP TABLE IF EXISTS authors CASCADE;
DROP TABLE IF EXISTS publishers CASCADE;

CREATE TABLE authors(
    author_id INTEGER PRIMARY KEY,
    author_name TEXT NOT NULL,
    country TEXT
);

CREATE TABLE publishers(
    publisher_id INTEGER PRIMARY KEY,
    publisher_name TEXT NOT NULL,
    city TEXT
);

CREATE TABLE books(
    book_id INTEGER PRIMARY KEY,
    title TEXT NOT NULL,
    author_id INTEGER REFERENCES authors(author_id),
    publisher_id INTEGER REFERENCES publishers(publisher_id),
    publication_year INTEGER,
    isbn TEXT UNIQUE
);

INSERT INTO authors VALUES (1, 'J.K. Rowling', 'UK');
INSERT INTO authors VALUES (2, 'George Orwell', 'UK');

INSERT INTO publishers VALUES (1, 'Bloomsbury', 'London');
INSERT INTO publishers VALUES (2, 'Secker & Warburg', 'London');

INSERT INTO books VALUES (1, 'Harry Potter', 1, 1, 1997, '9780747532743');
INSERT INTO books VALUES (2, '1984', 2, 2, 1949, '9780451524935');

DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products_fk CASCADE;
DROP TABLE IF EXISTS categories CASCADE;

CREATE TABLE categories(
    category_id INTEGER PRIMARY KEY,
    category_name TEXT NOT NULL
);

CREATE TABLE products_fk(
    product_id INTEGER PRIMARY KEY,
    product_name TEXT NOT NULL,
    category_id INTEGER REFERENCES categories(category_id) ON DELETE RESTRICT
);

CREATE TABLE orders(
    order_id INTEGER PRIMARY KEY,
    order_date DATE NOT NULL,
    status TEXT
);

CREATE TABLE order_items(
    item_id INTEGER PRIMARY KEY,
    order_id INTEGER REFERENCES orders(order_id) ON DELETE CASCADE,
    product_id INTEGER REFERENCES products_fk(product_id),
    quantity INTEGER CHECK (quantity > 0)
);

INSERT INTO categories VALUES (1, 'Electronics');
INSERT INTO products_fk VALUES (101, 'Smartphone', 1);

INSERT INTO orders VALUES (501, '2026-03-30', 'pending');
INSERT INTO order_items VALUES (1001, 501, 101, 2);

DELETE FROM orders WHERE order_id = 501;


DROP TABLE IF EXISTS order_details CASCADE;
DROP TABLE IF EXISTS orders_ec CASCADE;
DROP TABLE IF EXISTS products_ec CASCADE;
DROP TABLE IF EXISTS customers_ec CASCADE;

CREATE TABLE customers_ec (
    customer_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    phone TEXT,
    registration_date DATE NOT NULL
);

CREATE TABLE products_ec (
    product_id INTEGER PRIMARY KEY,
    name TEXT NOT NULL,
    description TEXT,
    price NUMERIC NOT NULL CHECK (price >= 0),
    stock_quantity INTEGER NOT NULL CHECK (stock_quantity >= 0)
);

CREATE TABLE orders_ec (
    order_id INTEGER PRIMARY KEY,
    customer_id INTEGER NOT NULL REFERENCES customers_ec(customer_id) ON DELETE CASCADE,
    order_date DATE NOT NULL,
    total_amount NUMERIC NOT NULL CHECK (total_amount >= 0),
    status TEXT NOT NULL CHECK (status IN ('pending', 'processing', 'shipped', 'delivered', 'cancelled'))
);

CREATE TABLE order_details (
     order_detail_id INTEGER PRIMARY KEY,
     order_id INTEGER NOT NULL REFERENCES orders_ec(order_id) ON DELETE CASCADE,
     product_id INTEGER NOT NULL REFERENCES products_ec(product_id),
     quantity INTEGER NOT NULL CHECK (quantity > 0),
     unit_price NUMERIC NOT NULL CHECK (unit_price >= 0)
);

INSERT INTO customers_ec VALUES
     (1, 'John Doe', 'john.doe@email.com', '555-1111', '2026-01-10'),
     (2, 'Jane Smith', 'jane.smith@email.com', '555-2222', '2026-01-15'),
     (3, 'Bob Johnson', 'bob.johnson@email.com', '555-3333', '2026-02-01'),
     (4, 'Alice Brown', 'alice.brown@email.com', '555-4444', '2026-02-10'),
     (5, 'Charlie Davis', 'charlie.davis@email.com', '555-5555', '2026-03-01');

INSERT INTO products_ec VALUES
     (1, 'Wireless Mouse', 'Ergonomic bluetooth mouse', 25.99, 150),
     (2, 'Mechanical Keyboard', 'RGB backlight keyboard', 79.99, 80),
     (3, '27-inch Monitor', '4K UHD IPS display', 329.99, 30),
     (4, 'USB-C Hub', 'Multi-port adapter', 45.50, 120),
     (5, 'HD Webcam', '1080p streaming camera', 59.99, 65);

INSERT INTO orders_ec VALUES
     (101, 1, '2026-03-10', 105.98, 'delivered'),
     (102, 2, '2026-03-12', 329.99, 'shipped'),
     (103, 3, '2026-03-15', 71.49, 'processing'),
     (104, 4, '2026-03-18', 79.99, 'pending'),
     (105, 5, '2026-03-20', 25.99, 'cancelled');

INSERT INTO order_details VALUES
      (1, 101, 1, 1, 25.99),
      (2, 101, 4, 1, 79.99),
      (3, 102, 3, 1, 329.99),
      (4, 103, 1, 1, 25.99),
      (5, 103, 4, 1, 45.50),
      (6, 104, 2, 1, 79.99),
      (7, 105, 1, 1, 25.99);