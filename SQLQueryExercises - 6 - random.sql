
/* 
End result : sku's with sales over a period but today have no stock.
Steps : 
1- creates a list on a #temporary table for sku's with sales YTD but without stock as of date
2- uses the temptable to left join with CTE sales table to create final table showing : sku's with zero stocks but had sales YTD
*/
	-- create #tempTable for sku list
	select store, stype, sku, description, sum(total_stk_qty) qtyoh
	into #OOSTable
	from vw_stockageing a
	where exists (
			select 1
			from salesconsol b
			where a.sku = b.itemid and a.store = b.storeno
				and finyear1 = '2026-27'
				and level = 'L-1')
				and Company = 'uae'
		and total_stk_qty = 0
	group by store, stype, sku, description

	-- CTE for sales table
	;with SalesAgg as (
			select StoreNo, itemid, sum(qty) qtysold
			from salesconsol 
			where finyear1 = '2026-27'
				and level = 'L-1'
				and Company = 'uae'
			group by storeno, ItemId
	)
	-- combine #temptable and #salestable
	select a.*, b.qtysold
	from #OOSTable a
	left join SalesAgg b
		on a.Store = b.StoreNo and a.Sku = b.ItemId

GO


/*
End Result : 
Steps :
1- create temp table
2- expand dimension for the temp table using subquery from other tables.

*/

create table #StoreList
(
	Company		varchar(10),
	Store		int,
	StoreName	nvarchar(25),
	Area		decimal(20,2)
)

insert into #StoreList
values
	('uae','405','mall of the emirates','1205'),
	('uae','416','the dubai mall','2200')

select Company, StoreNo, StoreName,
	sum(Case when finyear1 = '2023-24' then Sales$ else 0 end) FY23,
	sum(Case when finyear1 = '2024-25' then Sales$ else 0 end) FY24,
	sum(Case when finyear1 = '2025-26' then Sales$ else 0 end) FY25
from salesconsol
where FinYear1 in ('2023-24','2024-25','2025-26')
	and level = 'L-1'
	AND storeno in (
		select distinct store from #StoreList
		)
group by Company, StoreNo, StoreName


/**/


-- 

select *
from salesconsol





