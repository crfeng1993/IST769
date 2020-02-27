/* Cheat Sheet of PostgreSQL basic functions */
/*             Mainly for IST769             */
/*      Credit to Ruifeng in 02/26/2020      */

-- 1.1 Declare/Set/print function

Declare @factor1 varchar(20)
set @factor1 = 'In 2020 I am already'
Declare @factor2 int = 23
Declare @factor3 varchar(MAX) = 'years old.'

Print @factor1 + ' ' + CONVERT(varchar(10),@factor2) + @factor3


-- 1.2 Change Data Types

Print CAST('2020' as INT) -- ANSI SQL Standard
Print CONVERT(char(20),24.6) -- SQL Server Specific function
Print TRY_CAST ('27' AS datetime) -- Return NULL instead of showing error message
/*
	Hints for Data Types:
	decimal(p,s) -- p is the maximum total number of decimal digits to be stored, and s means the number of decimal digits that are stored to the right of the decimal point
	datetime -- default format: YYYY-MM-DD hh:mm:ss
	date -- default format: YYYY-MM-DD
	nchar(s) -- n means this string is decoded by Unicode
 */


-- 1.3 The USE/GO/INSERT/ALTER/SELECT/WAIT statement

USE some_database_name
GO
SELECT TOP 10
	O.name,
	C.telephone,
	SUM(O.order) AS total_orders
FROM
	Customer AS C
	LEFT JOIN
	Orders AS O
	ON C.name_id = O.name_id
GROUP BY
	O.name,
	C.telephone
ORDER BY
	SUM(O.order) DESC
GO
CREATE TABLE Customers (
    name_id INT PRIMARY KEY IDENTITY,
    name varchar(50) NOT NULL,
    Age int CHECK (Age>=18),
    telephone char(20) DEFAULT 'Null',
    FORK INT NOT NULL
    CONSTRAINT FOREGIN_KEY_CUSTOMERS FOREGIN KEY(FORK) REFERENCE Other_table(PK)
)
WAITFOR DELAY '00:00:05' -- Wait for 5 seconds and then execute next query
ALTER TABLE Customers
	ADD Email varchar(255) -- Add new column
	ALTER Email nvarchar(30) -- Change column data type
	DROP COLUMN Email -- Drop a column
GO
INSERT INTO Customers(name,Age, telephone, FORK)
	VALUES('Rick',25,'312-2233-2233',452) -- One way to insert a single row of data
GO
INSERT INTO Customers(name,Age, FORK)
	SELECT 'Jack',23,312
	UNION ALL 
	SELECT 'Hank',21,126
	UNION ALL
	SELECT 'Mark',36,344 -- Another way to insert multiple rows into the table for one time
GO


-- 1.4 String Function

Print LEN('Hello World') -- 11
Print LEFT('Hello World', 8) -- 'Hello Wo'
Print RIGHT('Hello World', 3) -- 'rld'
Print CHARINDEX(' ','Hello World') -- 6

SELECT REVERSE('Hello World') -- 'dlroW olleH'

Declare @factor4 varchar(20)
Print ISNULL(@factor4, 'Replacement if Null') -- 'Replacement if Null'

SELECT * FROM STRING_SPLIT(string ,separator) -- produce a single-column table whose only column name is value

SELECT 
	Condition,
	STRING_AGG(col, ',') WITHIN GROUP(ORDER BY col ASC) AS Combine_col 
FROM
	Table 
GROUP BY
	Condition -- produce a table whose with a column containing combined info


-- 1.5 Frquently-used Date Function

Print GETDATE() -- today's date and time :YYYY-MM-DD hh:mm:ss.sss
Print DATEPART(month, '2020-02-26') -- 2
Print DATENAME(month, '2020-02-26') – 'Feburary'
Print DATEPART(year, '10:34:39 PM') -- 1900 1900-1-1 is epoch
Print DATEPART(hour, '10:24:39 PM') -- 22
Print DATENAME(second, '10:24:39 PM') -- '39'


-- 1.6 Built-in Function

USE some_database_name
GO
IF EXISTS(SELECT * FROM sys.objects WHERE NAME = 'function_name_1')
	DROP Function function_name_1
GO
CREATE Function function_name_1(
	@f1 INT
) RETURNS decimal(5,2) AS
	BEGIN
	/* Processes in the function */
	END
GO
SELECT function_name_1(20)


-- 1.7 Table Valued Function

USE some_database_name
GO
IF EXISTS(SELECT * FROM sys.objects WHERE NAME = 'function_name_2')
	DROP Function function_name_2
GO
CREATE Function function_name_2(
	@f1 INT
) RETURNS TABLE AS
	RETURN(
		/* Processes in the function */	
		)
GO
SELECT function_name_2(30)


-- 1.8 View

IF EXISTS(SELECT * FROM sys.objects WHERE NAME = 'view_name_1')
	DROP VIEW view_name_1
GO
CREATE VIEW view_name_1
AS
SELECT
	*
FROM
	Table
GO
SELECT * FROM view_name_1


-- 2.1 Procedure & Transaction & Execute

IF EXISTS(SELECT * FROM sys.objects WHERE NAME = 'procedure_name_1')
	DROP PROCEDURE procedure_name_1
GO
CREATE PROCEDURE procedure_name_1(
	@f1 INT,
	@f2 char(10),
	@f3 BIT
) AS BEGIN
	BEGIN TRY
		BEGIN TRANSACTION
			/* Process 1 in the procedure */
			/* Process 2 in the procedure */
			IF /* Condition */
				/* Process 3 in the procedure */
			ELSE
				/* Process 4 in the procedure */
			Print 'COMMITING...'
		COMMIT
	END TRY
	BEGIN CATCH
		SELECT error_number() AS errors, error_message() AS Messages
		Print 'ROLLING BACK...'
		ROLLBACK
	END CATCH
END
GO
EXECUTE procedure_name_1 2, 'Syracuse', 1


-- 2.2 Temporal Table

ALTER TABLE table_name
	ADD
		valid_from DATETIME2(2) GENERATED ALWAYS AS ROW START HIDDEN
		CONSTRAINT constraint_name_1 FROM DEFAULT DATEADD(second, -1, SYSUTCDATETIME())
		, valid_to DATETIME2(2) GENERATED ALWAYS AS ROW END HIDDEN
		CONSTRAINT constraint_name_2 FROM DEFAULT '9999.12.31 23:59:59.99'
		, PERIOD FOR SYSTEM_TIME(valid_from,valid_to)
GO
ALTER TABLE table_name
	SET(SYSTEM_VERSIONING = ON (HISTORY_TABLE = some_database_name.table_name_history))
GO
SELECT * FROM some_database_name.table_name_history
GO
SELECT * FROM some_database_name.table_name_history
	FOR SYSTEM_TIME AS OF '2020-02-26 14:13:26' -- Check the history version at a certain time
GO
SELECT * FROM some_database_name.table_name_history
	FOR SYSTEM_TIME BETWEEN '2020-02-26 14:13:26' AND '2020-02-26 14:15:26' -- Check the history in a period of time


-- 3.1 NON-CLUSTERED INDEX
IF EXISTS(SELECT * FROM sys.indexes WHERE NAME = 'Non_Clustered_index' AND object_id = OBEJECT_ID('Schema.Table_Name'))
	DROP INDEX Non_Clustered_index
GO
CREATE NONCLUSTERED INDEX Non_Clustered_index 
	ON Table_Name(The_key_column,[...]) -- Always the column in the GROUP BY and WHERE statement
	INCLUDE (column_to_be_read,[...]) -- Always columns in the SELECT statement

/* 	
	IF the The_key_column is used as The_key_column = ... in the WHERE clause, it will be an Index Seek 
	In other cases, most likely it will be an Index Scan
	Only when all the column involved in a SELECT statement are all in the index can it be a index-relevant function
	A table can have multiple non-clustered indexes, but only one clustered index
	In fact we usually have the clustered index on our tables--The primary key
 */


-- 3.2 Columnstore INDEX

IF EXISTS(SELECT * FROM sys.indexes WHERE NAME = 'Non_Columnstore_index' AND object_id = OBEJECT_ID('Schema.Table_Name'))
	DROP INDEX Non_Columnstore_index
GO
CREATE [ClUSTERED|NONCLUSTERED] COLUMNSTORE INDEX Non_Columnstore_index 
	ON Table_Name(The_key_column,[...])

/*
	The columnstore index can be clustered or non-clustered，
	Only when all the column involved in a SELECT statement are all in the index can it be a index-relevant function
 */


-- 3.3 Indexed View
USE some_database_name
GO
IF EXISTS(SELECT * FROM sys.objects WHERE NAME = 'view_name_2')
	DROP VIEW view_name_2
GO
CREATE VIEW view_name_2 -- Create View
WITH SCHEMABINDING
AS
SELECT
	*
FROM
	Table
GO
IF EXISTS(SELECT * FROM sys.indexes WHERE NAME = 'indexed_view_index' AND object_id = OBEJECT_ID('Schema.Table_Name'))
	DROP INDEX indexed_view_index
GO
CREATE UNIQUE ClUSTERED INDEX indexed_view_index -- Create Index
	ON view_name_2(The_key_column,[...])
GO
SELECT -- Display Indexed View
	The_key_column,[...]
FROM
	view_name_2
WHERE
	The_key_column = 'Condition_1'

-- 4.1 JSON/XML Format
PRINT isjson(@factor) -- Returns 1 if the string contains valid JSON; otherwise, returns 0. Returns null if expression is null. Does not return errors.

DECLARE @JSONFILE varchar(MAX) = '[
	{"Reviewer":{"Name": "Kent Belevit", "Rating" : 2 }}, 
	{"Reviewer":{"Name": "Artie Choke", "Email": "ack@mail.com", "Rating" : 3 }}
	]'
SELECT * FROM OPENJSON(@JSONFILE) -- It will return a flatterned json structure: a two-row table containing a reviewed info each

SELECT * INTO Reviews
	FROM OPENJSON(@JSONFILE)
	WITH(Name varchar(20) '$.Reviewer.Name',
		 Email varchar(100) '$.Reviewer.Email',
		 Rating decimal(3,2) '$.Reviewer.Rating') -- It would extract the value from the basic structure, showing a table of 3 columns and 2 rows

JSON_QUERY(@JSONFILE) -- When you save a table with JSON info into a JSON file, use JSON_QUERY so that the system would deal with the info as JSON not string

SELECT * 
FROM
	table_name
FOR JSON AUTO --Transform the table into JSON format

SELECT *
FROM
	table_name
FOR XML PATH('Node'), ROOT('Root') --Transform the table into XML


-- 5.1 Security & Permission

CREATE LOGIN loginname
WITH PASSWORD = N'123456'
	,DEFAULT_DATABASE = some_database_name
	,CHECK_EXPIRATION = OFF
	,CHECK_POLICY = OFF
GO
CREATE USER username FROM LOGIN loginname
GO
SELECT * FROM sys.database_principals -- Show all the information about default principals in the database system
SELECT * FROM sys.database_permissions -- Show all the information about default permissions in the database system
GO
GRANT SELECT ON Schema::[some_database_name | view_name_1] TO username -- Now the User can read the some_database_name/view_name_1
GRANT EXECUTE ON Schema::procedure_name_1 TO username -- Now the User can use procedure_name_1
DENY permission ON object TO principal -- Denies a permission to a principal
REVOKE permission ON object TO principal -- Removes a previously granted or denied permission


-- 5.2 CROSS APPLY/OUTER APPLY

SELECT a.*,b.*
FROM
	table_name_1 AS a
CROSS APPLY
	( SELECT colum,COUNT(*) FROM table_name_2 WHERE column < a.column GROUP BY column ) AS b

/*
In fact, the CROSS APPLY function is like the INNER JOIN/LEFT JOIN function
However, the difference is that the APPLY function could directly apply the value of the former table into the latter table
it can be used in WHERE/ON clauses or any other functions (such as OPENJSON() or STRING_SPLIT() ) for more usages
The OUTER APPLY would contain Null value while the CROSS APPLY doesn't
 */
