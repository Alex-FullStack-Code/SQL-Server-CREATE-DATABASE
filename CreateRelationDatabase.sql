/* 
WHAT IS DB Schema in SQL Server?
https://www.sqlservertutorial.net/sql-server-basics/sql-server-create-schema/

- Schemas help in managing 
  database objects in a more 
  structured, secure, and organized way, 
  especially in larger databases with 
  many users and objects.

In SQL Server, a schema is a container or namespace 
that holds database objects such as 
tables, views, stored procedures, functions, and 
other database-related objects. 

A schema provides a way to group 
these objects logically within a database, 
helping to organize and manage them more effectively.

1. Namespace for Objects: 
A schema acts as a namespace to 
organize database objects and prevent naming conflicts. 
For example, two users can have tables with the same name 
as long as they belong to different schemas.


2. Ownership: 
Schemas are owned by database users or roles. 
Each schema can be assigned to a different database user, 
and this user has control over the objects within that schema.

3. Security: 
Schemas help in controlling access to database objects. 
Permissions can be granted at the schema level, 
providing a way to control access to multiple objects 
within the schema all at once.

4. Default Schema: 
Every database user has a default schema. 
If a user creates an object without 
explicitly specifying a schema, 
the object is created in 
the user's default schema.

5. Syntax for Objects: 
The full name of a database object includes 
the schema name followed by the object name, 
like schema_name.object_name. 
For example, 
dbo.Customers refers to the Customers table 
in the dbo schema.

CREATE SCHEMA Sales;
GO

CREATE TABLE Sales.Orders (
    OrderID INT PRIMARY KEY,
    OrderDate DATE,
    CustomerID INT
);
GO

Common Default Schema:
- dbo (Database Owner): 
   The default schema for many database users, 
   especially in older systems. 
   
   If no schema is specified, 
   objects are typically created in 
   the dbo schema. 
   
   SELECT 
    s.name AS schema_name, 
    u.name AS schema_owner
   FROM 
    sys.schemas s
   INNER JOIN 
    sys.sysusers u ON u.uid = s.principal_id
   ORDER BY 
    s.name;
	
*/

CREATE SCHEMA production;
GO

CREATE SCHEMA sales;
GO


-- create tables
CREATE TABLE production.categories (
	category_id INT IDENTITY (1, 1) PRIMARY KEY,
	category_name VARCHAR (255) NOT NULL
);

CREATE TABLE production.brands (
	brand_id INT IDENTITY (1, 1) PRIMARY KEY,
	brand_name VARCHAR (255) NOT NULL
);

CREATE TABLE production.products (
	product_id INT IDENTITY (1, 1) PRIMARY KEY,
	product_name VARCHAR (255) NOT NULL,
	brand_id INT NOT NULL,
	category_id INT NOT NULL,
	model_year SMALLINT NOT NULL,
	list_price DECIMAL (10, 2) NOT NULL,
	FOREIGN KEY (category_id) REFERENCES production.categories (category_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (brand_id) REFERENCES production.brands (brand_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE sales.customers (
	customer_id INT IDENTITY (1, 1) PRIMARY KEY,
	first_name VARCHAR (255) NOT NULL,
	last_name VARCHAR (255) NOT NULL,
	phone VARCHAR (25),
	email VARCHAR (255) NOT NULL,
	street VARCHAR (255),
	city VARCHAR (50),
	state VARCHAR (25),
	zip_code VARCHAR (5)
);

CREATE TABLE sales.stores (
	store_id INT IDENTITY (1, 1) PRIMARY KEY,
	store_name VARCHAR (255) NOT NULL,
	phone VARCHAR (25),
	email VARCHAR (255),
	street VARCHAR (255),
	city VARCHAR (255),
	state VARCHAR (10),
	zip_code VARCHAR (5)
);

CREATE TABLE sales.staffs (
	staff_id INT IDENTITY (1, 1) PRIMARY KEY,
	first_name VARCHAR (50) NOT NULL,
	last_name VARCHAR (50) NOT NULL,
	email VARCHAR (255) NOT NULL UNIQUE,
	phone VARCHAR (25),
	active tinyint NOT NULL,
	store_id INT NOT NULL,
	manager_id INT,
	FOREIGN KEY (store_id) REFERENCES sales.stores (store_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (manager_id) REFERENCES sales.staffs (staff_id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE sales.orders (
	order_id INT IDENTITY (1, 1) PRIMARY KEY,
	customer_id INT,
	order_status tinyint NOT NULL,
	-- Order status: 1 = Pending; 2 = Processing; 3 = Rejected; 4 = Completed
	order_date DATE NOT NULL,
	required_date DATE NOT NULL,
	shipped_date DATE,
	store_id INT NOT NULL,
	staff_id INT NOT NULL,
	FOREIGN KEY (customer_id) REFERENCES sales.customers (customer_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (store_id) REFERENCES sales.stores (store_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (staff_id) REFERENCES sales.staffs (staff_id) ON DELETE NO ACTION ON UPDATE NO ACTION
);

CREATE TABLE sales.order_items (
	order_id INT,
	item_id INT,
	product_id INT NOT NULL,
	quantity INT NOT NULL,
	list_price DECIMAL (10, 2) NOT NULL,
	discount DECIMAL (4, 2) NOT NULL DEFAULT 0,
	PRIMARY KEY (order_id, item_id),
	FOREIGN KEY (order_id) REFERENCES sales.orders (order_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (product_id) REFERENCES production.products (product_id) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE production.stocks (
	store_id INT,
	product_id INT,
	quantity INT,
	PRIMARY KEY (store_id, product_id),
	FOREIGN KEY (store_id) REFERENCES sales.stores (store_id) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (product_id) REFERENCES production.products (product_id) ON DELETE CASCADE ON UPDATE CASCADE
);

-- drop tables, only if it already exists
DROP TABLE IF EXISTS sales.order_items;

-- drop the schemas
DROP SCHEMA IF EXISTS sales;

-- Insert with no auto increment
use BikeStores;

SET IDENTITY_INSERT production.brands ON;  

INSERT INTO production.brands(brand_id,brand_name) VALUES(1,'Electra')
INSERT INTO production.brands(brand_id,brand_name) VALUES(2,'Haro')
INSERT INTO production.brands(brand_id,brand_name) VALUES(3,'Heller')

SET IDENTITY_INSERT production.brands OFF;  

/*
 SELECT INTO
 https://www.sqlservertutorial.net/sql-server-basics/sql-server-select-into/
 
 SELECT INTO: 
  creates a new table and 
  inserts rows from the query into it. */
  
SELECT 
	select_list
INTO 
	destination
FROM 
	source
[WHERE condition]

--Example:
CREATE SCHEMA marketing;
GO

SELECT 
    *
INTO 
    marketing.customers
FROM 
    sales.customers;
	
--Check to verify the copy:
SELECT * FROM marketing.customers;


-- Example 2:
SELECT    
    customer_id, 
    first_name, 
    last_name, 
    email
INTO 
    TestDb.dbo.customers
FROM    
    sales.customers
WHERE 
    state = 'CA';



-- PRIMARY KEY constraint
-- column or a group of columns that uniquely identifies each row in a table

--Composite Primary Key:
-- A Primary Key can also consist of 
-- multiple columns (a composite primary key). 
-- This ensures the combination of values in these columns is unique.

CREATE TABLE Orders (
    OrderID INT,
    ProductID INT,
    Quantity INT,
    PRIMARY KEY (OrderID, ProductID)
);
-- In this case, the combination of OrderID and ProductID 
-- uniquely identifies each record.
 
--IF the table don't have PK
ALTER TABLE TableName
ADD CONSTRAINT PK_ConstraintName PRIMARY KEY (ColumnName);

--Example 1:
CREATE TABLE table_name (
    pk_column data_type PRIMARY KEY,
    --...
);

CREATE TABLE table_name (
    pk_column_1 data_type,
    pk_column_2 data type,
    --...
    PRIMARY KEY (pk_column_1, pk_column_2)
);

-- find the name of the primary key constraint on a table:
SELECT name
FROM sys.key_constraints
WHERE type = 'PK' AND parent_object_id = OBJECT_ID('YourTableName');

ALTER TABLE YourTableName
DROP CONSTRAINT PK_YourConstraintName;

--Example 2:
ALTER TABLE Employees
ADD CONSTRAINT PK_Employees_ID PRIMARY KEY (EmployeeID);

ALTER TABLE Employees
DROP CONSTRAINT PK_Employees_ID;

-- FOREIGN KEY
CONSTRAINT fk_constraint_name 
FOREIGN KEY (column_1, column2,...)
REFERENCES parent_table_name(column1,column2,..)


CREATE TABLE procurement.vendors (
	vendor_id INT IDENTITY PRIMARY KEY,
	vendor_name VARCHAR(100) NOT NULL,
	group_id INT NOT NULL,
	CONSTRAINT fk_group 
	FOREIGN KEY (group_id) 
	REFERENCES procurement.vendor_groups(group_id)
);

FOREIGN KEY (foreign_key_columns)
REFERENCES parent_table(parent_key_columns)
ON UPDATE action 
ON DELETE action;

--ON DELETE NO ACTION: 
--raises an error and 
--rolls back the delete action on the row in the parent table.

--ON DELETE CASCADE: 
--deletes the rows in 
--the child table that is corresponding to 
--the row deleted from the parent table.

--ON DELETE SET NULL: 
--sets the rows in the child table to NULL 
--if the corresponding rows in the parent table are deleted. 
--To execute this action, the foreign key columns must be nullable.

--ON DELETE SET DEFAULT 
--sets the rows in the child table to 
--their default values if the corresponding rows 
--in the parent table are deleted. To execute this action, 
--the foreign key columns must have default definitions. 
--Note that a nullable column has a default value of NULL 
--if no default value specified.

--By default, SQL Server applies ON DELETE NO ACTION

--ON UPDATE NO ACTION: 
--raises an error and rolls back 
--the update action on the row in the parent table.

--ON UPDATE CASCADE: 
--updates the corresponding rows in the child table 
--when the rows in the parent table are updated.

--ON UPDATE SET NULL: 
--sets the rows in the child table to NULL 
--when the corresponding row in the parent table is updated. 
--Note that the foreign key columns must be nullable

--ON UPDATE SET DEFAULT: 
--sets the default values for the rows in the child table 
--that have the corresponding rows in the parent table updated.

--MORE SQL:

CREATE DATABASE database_name;

--DROP DATABASE 
--allows you to delete 1 or more databases 
DROP DATABASE  [ IF EXISTS ]
	database_name [,database_name2,...];

DROP DATABASE IF EXISTS TestDb;

--Schema
CREATE SCHEMA schema_name
    [AUTHORIZATION owner_name]

CREATE SCHEMA customer_services;

ALTER SCHEMA target_schema_name   
    TRANSFER [ entity_type :: ] securable_name;
	
DROP SCHEMA [IF EXISTS] schema_name;

--Add new
ALTER TABLE table_name
ADD column_name data_type;

ALTER TABLE Employees
ADD Department VARCHAR(50);

--Modefy date type
ALTER TABLE table_name
ALTER COLUMN column_name new_data_type;

ALTER TABLE Employees
ALTER COLUMN Salary DECIMAL(10, 2);

--Drop
ALTER TABLE table_name
DROP COLUMN column_name;

ALTER TABLE Employees
DROP COLUMN Department;

--Rename a Column (SQL Server 2016 and later)
-- possible only with: sp_rename system stored procedure
EXEC sp_rename 'table_name.old_column_name', 'new_column_name', 'COLUMN';

EXEC sp_rename 'Employees.Department', 'Dept', 'COLUMN';

-- Add a Primary Key Constraint
ALTER TABLE table_name
ADD CONSTRAINT constraint_name PRIMARY KEY (column_name);

ALTER TABLE table_name
ADD CONSTRAINT constraint_name PRIMARY KEY (column_name);

-- Drop a Primary Key Constraint
ALTER TABLE table_name
DROP CONSTRAINT constraint_name;

ALTER TABLE Employees
DROP CONSTRAINT PK_EmployeeID;

--Add a Foreign Key Constraint
ALTER TABLE table_name
ADD CONSTRAINT constraint_name 
FOREIGN KEY (column_name) 
REFERENCES other_table (other_column);

ALTER TABLE Orders
ADD CONSTRAINT FK_Orders_Employees 
FOREIGN KEY (EmployeeID) 
REFERENCES Employees(EmployeeID);

--Drop a Foreign Key Constraint
ALTER TABLE table_name
DROP CONSTRAINT constraint_name;

ALTER TABLE Orders
DROP CONSTRAINT FK_Orders_Employees;

--Rename a Table
EXEC sp_rename 'old_table_name', 'new_table_name';

EXEC sp_rename 'Employees', 'Staff';

/* OFFSET FETCH
https://www.sqlservertutorial.net/sql-server-basics/sql-server-offset-fetch/

OFFSET and FETCH clauses are options of the ORDER BY clause. 
They allow you to limit the number of rows returned by a query.

ORDER BY column_list [ASC |DESC]
OFFSET offset_row_count {ROW | ROWS}
FETCH {FIRST | NEXT} fetch_row_count {ROW | ROWS} ONLY

OFFSET 
 - specifies the number of rows to skip 
 before starting to return rows from the query.

FETCH 
 - specifies the number of rows to return 
 after the OFFSET clause has been processed. 
 
OFFSET is mandatory, 
 while the FETCH clause is optional.  */

SELECT
    product_name,
    list_price
FROM
    production.products
ORDER BY
    list_price,
    product_name 
OFFSET 10 ROWS;

--
SELECT
    product_name,
    list_price
FROM
    production.products
ORDER BY
    list_price,
    product_name 
OFFSET 10 ROWS 
FETCH NEXT 10 ROWS ONLY;

--
SELECT
    product_name,
    list_price
FROM
    production.products
ORDER BY
    list_price DESC,
    product_name 
OFFSET 0 ROWS 
FETCH FIRST 10 ROWS ONLY;

--
SELECT 
  DISTINCT column_name 
FROM 
  table_name;
  
-- 
SELECT DISTINCT
	column_name1,
	column_name2 ,
	...
FROM
	table_name; 
	
-- 
SELECT 
  DISTINCT city 
FROM 
  sales.customers 
ORDER BY 
  city;
  
--
SELECT 
  city, 
  state, 
  zip_code 
FROM 
  sales.customers 
GROUP BY 
  city, 
  state, 
  zip_code 
ORDER BY 
  city, 
  state, 
  zip_code

-- Where:
SELECT
    product_id,
    product_name,
    category_id,
    model_year,
    list_price
FROM
    production.products
WHERE
    category_id = 1 AND model_year = 2018
ORDER BY
    list_price DESC;
  
--
SELECT
    product_id,
    product_name,
    category_id,
    model_year,
    list_price
FROM
    production.products
WHERE
    list_price > 300 AND model_year = 2018
ORDER BY
    list_price DESC;


--
SELECT
    product_id,
    product_name,
    category_id,
    model_year,
    list_price
FROM
    production.products
WHERE
    list_price BETWEEN 1899.00 AND 1999.99
ORDER BY
    list_price DESC;


--	
SELECT
    product_id,
    product_name,
    category_id,
    model_year,
    list_price
FROM
    production.products
WHERE
    list_price IN (299.99, 369.99, 489.99)
ORDER BY
    list_price DESC;

-- whose name contains the string Cruiser
SELECT
    product_id,
    product_name,
    category_id,
    model_year,
    list_price
FROM
    production.products
WHERE
    product_name LIKE '%Cruiser%'
ORDER BY
    list_price;
	
-- SQL Server NULL
-- https://www.sqlservertutorial.net/sql-server-basics/sql-server-null/	

NULL = 0
NULL <> 0
NULL > 0
NULL = NULL

--
SELECT
    customer_id,
    first_name,
    last_name,
    phone
FROM
    sales.customers
WHERE
    phone = NULL
ORDER BY
    first_name,
    last_name;
  
--
SELECT
    customer_id,
    first_name,
    last_name,
    phone
FROM
    sales.customers
WHERE
    phone IS NULL
ORDER BY
    first_name,
    last_name;

-- Find All NULLs in Specific Columns
SELECT *
FROM YourTable
WHERE Column1 IS NULL
   OR Column2 IS NULL
   OR Column3 IS NULL;

--find All NULLs Across All Columns Dynamically
DECLARE @tableName NVARCHAR(128) = 'YourTable';  -- Replace with your table name
DECLARE @sql NVARCHAR(MAX) = '';

-- Create dynamic SQL to check for NULL values in each column
SELECT @sql = @sql + 
    ' OR [' + COLUMN_NAME + '] IS NULL ' 
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = @tableName;

-- Remove the leading " OR " and add the "WHERE" clause
SET @sql = 'SELECT * FROM ' + @tableName + ' WHERE 1=0' + SUBSTRING(@sql, 3, LEN(@sql));

-- Execute the dynamic SQL
EXEC sp_executesql @sql;

--IN Operator
--https://www.sqlservertutorial.net/sql-server-basics/sql-server-in/

column | expression IN ( v1, v2, v3, ...)

column IN (v1, v2, v3)

column = v1 OR column = v2 OR column = v3

--
SELECT
    product_name,
    list_price
FROM
    production.products
WHERE
    list_price IN (89.99, 109.99, 159.99)
ORDER BY
    list_price;
	
--
SELECT
    product_name,
    list_price
FROM
    production.products
WHERE
    list_price = 89.99 OR list_price = 109.99 OR list_price = 159.99
ORDER BY
    list_price;

--
column | expression NOT IN ( v1, v2, v3, ...)

column | expression IN (subquery)

--
SELECT
    product_id
FROM
    production.stocks
WHERE
    store_id = 1 AND quantity >= 30;

--
SELECT
    product_name,
    list_price
FROM
    production.products
WHERE
    product_id IN (
        SELECT
            product_id
        FROM
            production.stocks
        WHERE
            store_id = 1 AND quantity >= 30
    )
ORDER BY
    product_name;

-- Nested Queries
SELECT Name, Salary
FROM Employees
WHERE DepartmentId = (
		SELECT DepartmentId FROM Departments 
		WHERE Name = 'Sales'
	);

--
SELECT Name, Salary
FROM Employees E
WHERE Salary > (
		SELECT AVG(Salary) FROM Employees 
		WHERE DepartmentId = E.DepartmentId
	);

--
SELECT Name, (
		SELECT COUNT(*) FROM Orders 
		WHERE CustomerId = C.CustomerId
	) AS OrderCount
FROM Customers C;

--IN
SELECT Name
FROM Employees
WHERE DepartmentId IN (
		SELECT DepartmentId FROM Departments 
		WHERE Location = 'New York'
	);

--EXISTS
SELECT Name
FROM Employees E
WHERE EXISTS (
		SELECT 1 FROM Orders O 
		WHERE O.EmployeeId = E.EmployeeId
	);

--
SELECT D.DepartmentName, E.EmployeeCount
FROM Departments D
JOIN (
		SELECT DepartmentId, COUNT(*) AS EmployeeCount 
		FROM Employees 
		GROUP BY DepartmentId
	) E
ON D.DepartmentId = E.DepartmentId;

SELECT DepartmentId, COUNT(*) AS NumEmployees
FROM Employees
GROUP BY DepartmentId
HAVING COUNT(*) > (
	    SELECT AVG(EmployeeCount) FROM (
			SELECT DepartmentId, COUNT(*) AS EmployeeCount 
			FROM Employees GROUP BY DepartmentId
		) AS DeptCounts
	);

--Operators with Subqueries
-- WHERE
SELECT Name, Salary
FROM Employees
WHERE Salary > (SELECT MAX(Salary) FROM Employees WHERE DepartmentId = 3);

--Constraint Relations

CREATE TABLE Towns (
	TownID INT,
	TownName VARCHAR(30) NOT NULL,
	CONSTRAINT PK_Towns PRIMARY KEY(TownID)
)

CREATE TABLE Airports (
	AirportID INT,
	AirportName VARCHAR(50) NOT NULL,
	TownID INT NOT NULL,
	CONSTRAINT PK_Airports PRIMARY KEY(AirportID),
	CONSTRAINT FK_Airports_Towns FOREIGN KEY(TownID) REFERENCES Towns(TownID)
)

CREATE TABLE Airlines (
	AirlineID INT,
	AirlineName VARCHAR(30) NOT NULL,
	Nationality VARCHAR(30) NOT NULL,
	Rating INT DEFAULT(0),
	CONSTRAINT PK_Airlines PRIMARY KEY(AirlineID)
)

CREATE TABLE Customers (
	CustomerID INT,
	FirstName VARCHAR(20) NOT NULL,
	LastName VARCHAR(20) NOT NULL,
	DateOfBirth DATE NOT NULL,
	Gender VARCHAR(1) NOT NULL CHECK (Gender='M' OR Gender='F'),
	HomeTownID INT NOT NULL,
	CONSTRAINT PK_Customers PRIMARY KEY(CustomerID),
	CONSTRAINT FK_Customers_Towns FOREIGN KEY(HomeTownID) REFERENCES Towns(TownID)
)

CREATE TABLE Flights
(
	FlightID INT,
	DepartureTime DATETIME NOT NULL,
	ArrivalTime DATETIME NOT NULL,
	Status VARCHAR(9) NOT NULL CHECK (Status IN ('Departing', 'Delayed', 'Arrived', 'Cancelled')),
	OriginAirportID INT,
	DestinationAirportID INT,
	AirlineID INT,
	CONSTRAINT PK_Flights PRIMARY KEY  (FlightID),
	CONSTRAINT FK_Flights_Airports_Origin FOREIGN KEY (OriginAirportID) REFERENCES Airports (AirportID),
	CONSTRAINT FK_Flights_Airports_Destination FOREIGN KEY (DestinationAirportID) REFERENCES Airports (AirportID),
	CONSTRAINT FK_Flights_Airlines FOREIGN KEY (AirlineID) REFERENCES Airlines (AirlineID)
)

CREATE TABLE Tickets
(
	TicketID INT,
	Price DECIMAL(8,2) NOT NULL,
	Class VARCHAR(6) CHECK (Class IN('First', 'Second', 'Third')),
	Seat VARCHAR(5) NOT NULL,
	CustomerID INT,
	FlightID INT,
	CONSTRAINT PK_Tickets PRIMARY KEY (TicketID),
	CONSTRAINT FK_Tickets_Customers FOREIGN KEY (CustomerID) REFERENCES Customers (CustomerID),
	CONSTRAINT FK_Tickets_Flights FOREIGN KEY (FlightID) REFERENCES Flights (FlightID)
)

-- Store Procedure 
/* is a named set of 1 or more 
SQL statements that can be executed together. 
It is a database object that is created and stored in 
the database management system. Stored procedures are 
typically used for performing common database operations, 
data processing, and automation of complex tasks. 
They are particularly valuable for 
enhancing database security, modularity, 
and code reusability.
 
 1.Enhance security: 
   By allowing controlled access to database operations and 
   reducing the risk of SQL injection attacks.
   
 2. Modularize code: 
    To break down complex SQL logic into manageable, 
	reusable modules for improved maintainability.
	
  3.Improve performance: 
    By reducing the overhead of repeatedly sending 
	SQL statements to the database.
  
  4.Automate tasks: 
    For automating routine or 
	complex database operations and 
	data processing tasks.
  
  5.Implement business logic: 
    To encapsulate business rules and 
	processes directly in the database.
  
   

*/
CREATE PROCEDURE proc_name
    (param1 data_type, param2 data_type, ...)
AS
BEGIN
    -- SQL statements and logic
END;

--
CREATE PROCEDURE GetEmployeesInDepartment
    @DepartmentID INT
AS
BEGIN
    SELECT EmployeeName
    FROM Employees
    WHERE DepartmentID = @DepartmentID;
END;

EXEC GetEmployeesInDepartment @DepartmentID = 101;
 