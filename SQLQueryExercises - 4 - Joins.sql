

-- build table variables

declare @Stocktable table (company varchar(10), store varchar(10), storename nvarchar(50));
declare @Salestable table (company varchar(10), store varchar(10), storename nvarchar(50));

insert into @Stocktable (company, store, storename)
select distinct company, store, storename
from vw_stockageing

insert into @Salestable (company, store, storename)
select distinct company, StoreNo, storename
from salesconsol

select * from @Stocktable
select * from @Salestable

-- join practice

select distinct company, store, storename
into #StockTable
from vw_stockageing

select distinct company, StoreNo, storename
into #SalesTable
from salesconsol
	where FinYear1 = '2025-26'

-- 
-- inner join
select *
from #StockTable i
inner join #SalesTable s
	on i.Store = s.StoreNo

-- left join
select *
from #StockTable i
left outer join #SalesTable s
	on i.Store = s.StoreNo

-- right join
select *
from #StockTable i
right outer join #SalesTable s
	on i.Store = s.StoreNo

-- full join
select *
from #StockTable i
full outer join #SalesTable s
	on i.Store = s.StoreNo

-- anti join
select *
from #StockTable i
where NOT exists (
	select 1
	from #SalesTable s
	where i.Store = s.StoreNo
	)






