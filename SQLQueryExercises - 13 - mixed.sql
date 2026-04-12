

declare @endd date = cast(getdate()-1 as date);
declare @startd date = dateadd(day,-90,@endd);
declare @elapsed int = datediff(day,@startd,@endd)

declare @storelist table
(
	Company		varchar(5),
	Store		int,
	StoreName	nvarchar(25)
		)

insert into @storelist
values 
	('uae','405','moe'),
	('uae','416','tdm'),
	('uae','424','yas')
	;

drop table if exists #temp
select company, storeno, storename, dept2, department, sum(sales$) sls, @elapsed EL
into #temp
from salesconsol
where date between @startd and @endd
and level = 'L-1'
and storeno in
	(select distinct store from @storelist)
group by company, storeno, storename, dept2, department;

select *,
	row_number() over(partition by company, storeno order by company desc, storeno asc) as RowNum,
	sum(sls) over(partition by storeno) TotalStore,
	sum(sls) over(partition by storeno) TotalCompany,
	sum(sls) over(partition by storeno order by company desc, storeno asc rows between unbounded preceding and current row) Cummulative
from #temp

go
	