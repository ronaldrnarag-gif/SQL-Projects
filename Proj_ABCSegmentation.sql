
/*

ABC SEGMENTATION :

	Partition Level : 
	company + subclass + 	brand

	Last 90D Sales and Margin

	Exclusions :
	- Newness (FRD <= 90D)
	- No Sales for the Last 90D

	Final Rank Matrix
	- Sales 40% and margin 60%

constraints : 
	what if margin is negative?? margin ranking is also zero?

comments :
	add sales $ and margin$ numbers

*/


-- Variable Declarations
declare @startdate as date, @enddate as date;
set @startdate = DATEADD(day,-90,getdate()-1);
set @enddate = getdate()-1;

-- CTE Stock
with Stock_Agg as (
	select Company, Sku, FRDEntity, 
		sum(total_stk_qty) QtyOH, sum(total_stk$) Stock, sum(total_prov$) Provision
	from VW_StockAgeing
group by Company, Sku, FRDEntity
	),

-- CTE last 90D sales, exclude New Items
Sales_Agg as (
	select Company, SubClass, Brand, Itemid, Description,
		sum(qty) QtySold, sum(sales$) sales, sum(margin$) margin
	from salesconsol a
	where date between @startdate and @enddate
		and stype in ('normal purchase','purchase foreign','consignment')
		and exists 
			(
			select 1
			from Stock_Agg b
			where b.Company = a.Company and b.Sku = a.ItemId
			and b.FRDEntity <= @startdate
			)
	group by Company, SubClass, Brand, Itemid, Description
	)

-- create Temp table for Sales and margin Ranking
-- company + subclass + brand granularity
select Company, SubClass, Brand, ItemID, Description, 
		DENSE_RANK() over (partition by Company, SubClass
			order by Company, SubClass, Brand, sum(Sales) desc) as SalesRank,
		DENSE_RANK() over (partition by Company, SubClass
			order by Company, SubClass, Brand, sum(Margin) desc) as MarginRank,
		CAST(NULL AS decimal(10,2)) as FinalBase,
		sum(QtySold) QtySold, sum(Sales) Sales, sum(Margin) Margin
into #RankingStage1
from Sales_Agg
group by Company, SubClass, Brand, ItemID, Description ;

-- Update weighted Score
update #RankingStage1
set FinalBase = ((SalesRank * 0.40) + (MarginRank * 0.60));

-- Final Ranking
with SalesRank_Agg as (
	select *,
	DENSE_RANK() over(partition by Company, SubClass, Brand
			order by FinalBase asc) as FinalRank
	from #RankingStage1
	)

-- ABC % Base
select *,
	(
	case 
		when Pct_Total <= 0.4 then 'A'
		when Pct_Total <= 0.7 then 'B'
		else 'C' end
	) as ABC
from 
	(
	select *,
		CAST(
		CAST(finalrank AS decimal(10,4))
		/
		NULLIF(MaxRank,0)
		AS decimal(10,4)) as Pct_Total
	from
		(
		select *,
			max(finalrank) over(partition by Company, Subclass, Brand
				order by Company, Subclass) as MaxRank
		from SalesRank_Agg
		where company = 'bah') t
		) r ;

GO
