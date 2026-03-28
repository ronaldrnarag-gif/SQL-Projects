

-- Basic Variable Declaration
declare @EndDate date = getdate()-1;
declare @StartDate date = dateadd(day,-90,@enddate;

select min(date) min, max(date) max
from salesconsol
where date between @StartDate and @enddate;


-- Table Variables
declare @StoreList table
	(
		company		varchar(10),
		storeno		int,
		storename	nvarchar(25),
		area		decimal(10,2)
	)

insert into @storelist
values 
	('uae','405','moe','1200'),
	('uae','416','tdm','2400')

select * from @storelist;

-- combine 2 select tables into 1 Table variable 

declare @StoreListTable table (
	Company		varchar(10),
	Storeno		varchar(10),
	StoreName	nvarchar(50),
	Source		varchar(10)
	)

insert into @StoreListTable
select distinct company, store, StoreName, 'Stock' Source
from vw_stockageing

insert into @StoreListTable
select distinct company, storeno as store, StoreName, 'Sales' Source
from SalesConsol
	where FinYear1 = '2026-27'

select * from @StoreListTable

-- combine 2 select tables into 1 Table variable

declare @StoreListTable2 table (
	Company		varchar(10),
	Storeno		varchar(10),
	StoreName	nvarchar(50)
	)

insert into @StoreListTable2 (Company, Storeno, Storename)
	(
select distinct company, store, StoreName
from vw_stockageing

union

select distinct company, storeno as store, StoreName
from SalesConsol
	where FinYear1 = '2026-27'
	)









