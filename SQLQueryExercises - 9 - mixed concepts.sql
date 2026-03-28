


/*
random test
	*/


declare @StartDate date, @enddate date;
set @StartDate = DATEADD(DAY,-90,@enddate);
set @enddate = DATEADD(DAY,-1,GETDATE());

declare @storelist1 table
	(
	company		varchar(10),
	storeno		varchar(10),
	storename	nvarchar(50)
		)

declare @storelist2 table
	(
	company		varchar(10),
	storeno		varchar(10),
	storename	nvarchar(50)
		)

insert into @storelist1 (company, storeno, storename)
select DISTINCT Company, StoreNo, StoreName
from SalesConsol
where FinYear1 = '2026-27'
	and Level = 'L-1'

insert into @storelist2
select distinct company, store, storename
from VW_StockAgeing
where stype in ('normal purchase','purchase foreign','consignment')

drop table if exists #tempTable;
create table #tempTable 
(
	Company		nvarchar(10),
	Storeno		varchar(10),
	StoreName	nvarchar(50),
	Stock$		decimal(15,2)
	)

insert into #tempTable (Company, Storeno, StoreName)
select * from @storelist1 
union
select * from @storelist2 
order by storeno

;with Stock_Agg as (
	select Company, Store, cast(SUM(total_stk$) as  int) stock$
	from VW_StockAgeing
	where stype in ('normal purchase','purchase foreign') 
	group by Company, Store
)

select a.Company,a.Storeno, a.StoreName, b.stock$ as 'Stock$'
from #tempTable a
left outer join Stock_Agg b
	on a.Storeno=b.Store


GO

/*
	Dates 
*/

declare @datetoday date, @date1 date, @date2 date, @date3 date, @date4 date;
set @datetoday = GETDATE();
set @date1 = DATEADD(DAY,-1,@datetoday);
set @date2 = DATEADD(DAY,-2,@datetoday);
set @date3 = DATEADD(DAY,-3,@datetoday);
set @date4 = DATEADD(DAY,-4,@datetoday);

drop table if exists #TempCalendar;
CREATE table #TempCalendar
(
	Date	date,
	Year	int,
	Month	varchar(10),
	Day		int
	)

insert into #TempCalendar (DATE)
VALUES 
	(@date1),
	(@date2),
	(@date3),
	(@date4)

update #TempCalendar
set Year = DATEPART(year,date),
	month = datepart(month,date),
	Day=DATEPART(DAY,date);

SELECT * FROM #TempCalendar ORDER BY DATE ASC 


