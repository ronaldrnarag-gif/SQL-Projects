

-- Back up a table

SELECT *
INTO FactSales_Backup
FROM FactSales

-- OR a cleaner Version

SELECT *
INTO FactSales_Backup	
FROM FactSales

TRUNCATE TABLE FactSales_Backup

INSERT INTO FactSales_Backup
SELECT * FROM FactSales


-- into directly a temp table


drop table if exists #temptable


select distinct companyid, warehouseid
into #temptable
from dimstore


-- create table, manually populate dataset

	drop table if exists #temptable

	create table #temptable (
		companyid		varchar(10),
		warehouseid		varchar(10)
		)

	insert into #temptable
	values ('uae','405')

-- create temporary table, populate table using data from cte

	drop table if exists #temptable

	create table #temptable (
		companyid		varchar(10),
		warehouseid		varchar(10)
		)

	insert into #temptable
	values ('uae','405')

	; with storelist_agg as (
		select distinct companyid, warehouseid
		from dimstore
		)

	insert into #temptable
	select * from storelist_agg


-- create table variable, manually populate dataset

	declare @temptable table (
		companyid		varchar(10),
		warehouseid		varchar(10)
		)

	insert into #temptable
	values ('uae','405')