

-- sample 1 -- full control over data types

	create table #StoreList
		(
			Company		varchar (10),
			Storeno		int,
			StoreName	nvarchar (25),
			Area		decimal (10,2)
		)

	insert into #StoreList
	values 
		('uae','405','mall of the emirates','1500'),
		('uae','416','the dubai mall','2200')
	;
	select * from #StoreList
	;

-- sample 2 --

	select day(date) dayno, sum(sales$) sales
	into #TempSales
	from salesconsol
	where finyear1 = '2026-27'
		and MONTH = 'mar'
	group by day(date) 
	;
	select * from #TempSales order by dayno
	;

-- sample 3

	insert into #TempSales2 (dayno, sales)
	select day(date) dayno, sum(sales$) sales
	from salesconsol
	where finyear1 = '2026-27'
		and MONTH = 'mar'
	group by day(date) 
	;
	select * from #TempSales2 order by dayno
	;

-- sample 4 -- a bit of complexity


select day(date) dayno, 
	sum(case when finyear1 = '2026-27' then sales$ else 0 end) as FY26,
	sum(case when finyear1 = '2025-26' then sales$ else 0 end) as FY25
INTO #TSALES
from SalesConsol
where FinYear1 in ('2025-26','2026-27')
	and Month = 'MAR'
	and level = 'L-1'
GROUP BY DAY(DATE)
ORDER BY DAY(DATE);

WITH TSALES_AGG AS (
	SELECT *, (FY26-FY25) Variance
	FROM #TSALES
	WHERE DAYNO <= day(GETDATE() -1)
)
select * from TSALES_AGG
order by dayno;


-- sample 5

declare @tyyear varchar (10), @lyyear varchar (10), @startdate date, @enddate date; 

set @tyyear = '2026-27'
set @lyyear = '2025-26'
set @startdate = '2026-03-01'
set @enddate = '2026-03-10'

select day(date) dayno, sum(sales$) sales
from salesconsol
where FinYear1 in (@tyyear,@lyyear)
	and date between @startdate and @enddate
group by day(date) order by  day(date)