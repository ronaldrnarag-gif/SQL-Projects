


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


-- Update First 3 variables before to run
declare @FinYear varchar(10)    = '2024-25';
declare @Month varchar(10)      = 'Mar';
declare @Endd date              = '2024-03-31';
declare @Startd date = DATEADD(DAY, -90, @Endd) ;

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

Insert Into #TempStg (Company,SubClass,Brand,Itemid,QtySold,Sales,Margin)
	select Company, SubClass, Brand, Itemid,
		sum(qty) QtySold, sum(sales$) Sales, sum(margin$) Margin
	from salesconsol a
	where date between @Startd and @Endd
		and stype in ('normal purchase','purchase foreign','consignment')
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
drop table if exists #TempStg3
select *,
	(
	case 
		when Pct_Total <= 0.4 then 'A'
		when Pct_Total <= 0.8 then 'B'
		else 'C' end
	) as ABC
into #TempStg3
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
		) t
		) r ;

-----------------------------------------------------------------------------
/*
	StockProgressinSku Table update of its ABC Flag
*/

UPDATE a
SET a.ABCFlag = 
    CASE  
        WHEN a.FRDEntity > @Startd
            THEN 'Newness'  -- 1. Newness
        WHEN b.ABC IS NOT NULL 
            and a.FRDEntity < @Startd
            THEN b.ABC      -- 2. ABC from view
        ELSE 'NoSale'       -- 3. No Sale
    END
FROM Fact_StockProgressionSku a
LEFT JOIN #TempStg3 b
    ON a.Company = b.Company
   AND a.Sku = b.ItemID
WHERE a.FinYear1 = @FinYear 
	and a.Month=@Month;


GO