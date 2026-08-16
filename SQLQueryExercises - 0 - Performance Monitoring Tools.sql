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

-- Which users are connected, Which machines (host_name) they are connecting from, Which application is connecting (program_name), How long they've been connected
select * from sys.dm_exec_sessions 

-- Identify Long-Running Queries via 'total_elapsed_time' expressed in milliseconds
select (total_elapsed_time/1000)/60 ElapsedinMins, *
from sys.dm_exec_requests 


-- Find Blocked sessions
SELECT
    session_id,
    blocking_session_id,
    wait_type,
    wait_time
FROM sys.dm_exec_requests
WHERE blocking_session_id <> 0;

-- CPU Hungry Queries
SELECT
    session_id,
    cpu_time,
    total_elapsed_time,
    command
FROM sys.dm_exec_requests
ORDER BY cpu_time DESC;

-- Monitor Query Progress
-- ETL completion %, Backup/restore progress, Index rebuild progress
SELECT
    session_id,
    command,
    percent_complete
FROM sys.dm_exec_requests
WHERE percent_complete > 0;