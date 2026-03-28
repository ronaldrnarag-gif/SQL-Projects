
-- 
	declare @startdate date = '2026-03-01';
	declare @enddate date = '2026-03-10';
	declare @company varchar (5) = 'uae';

	select day(date) dayno, sum(sales$) sales
	from SalesConsol
	where date between @startdate and @enddate
		and Company = @company
	group by day(date)
	order by day(date);



select top 10 * from salesconsol