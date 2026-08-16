select name from sys.tables

select * from sys.objects order by type_desc

SELECT * FROM INFORMATION_SCHEMA.TABLES where TABLE_TYPE = 'VIEW'
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
SELECT * FROM INFORMATION_SCHEMA.COLUMN_PRIVILEGES
SELECT * FROM INFORMATION_SCHEMA.TABLE_PRIVILEGES

SELECT * FROM INFORMATION_SCHEMA.VIEWS
SELECT * FROM INFORMATION_SCHEMA.VIEW_COLUMN_USAGE
SELECT * FROM INFORMATION_SCHEMA.VIEW_TABLE_USAGE

SELECT * FROM INFORMATION_SCHEMA.TABLES where TABLE_TYPE = 'VIEW'
SELECT * FROM INFORMATION_SCHEMA.VIEWS

--------

/*
	Fabric Dynamic Management Views (DMV's)
--	monitor connection, session and request status
--	gives no of active queries and which queries are running for extended time.
*/

select * from sys.dm_exec_connections

select * from sys.dm_exec_sessions where nt_user_name = 'ronald.narag'

select * from sys.dm_exec_requests



