/*
Title	:	ABC SEGMENTATION 
Purpose	:	ABC Segmentation for Inventory Management Metric
Logic	:

	Rank Sku's existing in 
	Last 90D Sales and Margin Data.

	Rankings : 
		1- Sales based on value;
		2- margin based on value; then 
		3- Final Base based on this calculation = sum(Sales Rank * 40%, margin rank * 60%)

	next steps :
	- create a view out of this script, left join with itemmaster to import ABC Flag column.
	- anything null after applying ABC from below script will be replaed by the following: 
		a. FRD <= dateadd(day,-90,getdate()-1)
		b. 'No Sales' = left over nulls  
Created	:	ronaldn/20260412
*/

-- Temp Table (Stage 1) for the last 90D sales

Drop table if exists #TempStg
Create table #TempStg  
(
	Company		varchar(10), 
	SubClass	nvarchar(50), 
	Brand		nvarchar(25), 
	Itemid		varchar(10), 
	QtySold		int not null default 0,
	Sales		decimal(19,4) not null default 0,
	Margin		decimal(19,4) not null default 0,
		)

; with Stock_Agg as (
	select Company, sku, min(FRDEntity) FRDEntity
	from VW_StockAgeing
	where FRDEntity >= dateadd(day,-90,getdate()-1)
	group by Company, sku
)

Insert Into #TempStg (Company,SubClass,Brand,Itemid,QtySold,Sales,Margin)
	select Company, SubClass, Brand, Itemid,
		sum(qty) QtySold, sum(sales$) Sales, sum(margin$) Margin
	from salesconsol a
	where date between DATEADD(day,-90,getdate()-1) and GETDATE()-1
		and stype in ('normal purchase','purchase foreign','consignment')
		and not exists (
			select 1
			from Stock_Agg b
			where a.Company=b.Company and a.ItemId=b.Sku
			)
	group by Company, SubClass, Brand, Itemid
		
-- create Temp table for Sales and margin Ranking 
-- company + subclass + brand granularity

drop table if exists #TempStg1
Select Company, SubClass, Brand, ItemID,  
		RANK() over (partition by Company, SubClass, Brand
			order by sum(Sales) desc) as SalesRank,
		RANK() over (partition by Company, SubClass, Brand
			order by sum(Margin) desc) as MarginRank,
		CAST(NULL AS decimal(19,4)) as FinalBase,
		sum(QtySold) QtySold, 
		sum(Sales) Sales, 
		sum(Margin) Margin
Into #TempStg1
from #TempStg
group by Company, SubClass, Brand, ItemID ;

-- Update weighted Score
update #TempStg1
set FinalBase = ((SalesRank * 0.40) + (MarginRank * 0.60));

-- Final Ranking
drop table if exists #TempStg2
select *,
RANK() over(partition by Company, SubClass, Brand
		order by FinalBase asc) as FinalRank
into #TempStg2
from #TempStg1
	
-- ABC % Base
select *,
	(
	case 
		when Pct_Total <= 0.4 then 'A'
		when Pct_Total <= 0.8 then 'B'
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
		from #TempStg2
		where Company = 'qat'
		and SubClass = 'iphone'
		and Brand = 'appl') t
		) r ;

GO