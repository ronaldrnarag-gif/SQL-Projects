/*
select top 3 *
from Stg_SalesConsol_OtherLS

select top 3 *
from View_OtherLS_DSRYTD

select top 3 *
from SalesConsol

select top 3 *
from View_DSRMTD

select top 3 *
from View_DSRYTD

select top 3 *
from View_DSRBudget

select * from dim_storename_totaldiv
*/
--------------------------------------

-- 75,134

Drop table if exists #TempTable
GO

; WITH Virgin_Agg as (
	SELECT cast('' as nvarchar(50)) as DivisionBrand, FinYear1, [Month], [Date], cast('' as nvarchar(50)) as Country, Company, StoreNo, cast('' as nvarchar(50)) as StoreName, cast('' as nvarchar(50)) as ShortName,
		Dept2, Department, Level, '' as MTDYN, [LFL26 vs 25] as LFLYN, 
		SUM(Qty) Qty, SUM(sales$) Sales$, SUM(Cost$) Cost$, SUM(ClaimAmount$) ClaimAmount$, SUM(Margin) Margin$ 
	FROM SalesConsol
	WHERE Date between DATEADD(YEAR,-1,cast(GETDATE()-1 as date)) and cast(GETDATE()-1 as date)
		and Level = 'L-1'
	GROUP BY FinYear1, [Month], [Date], Company, StoreNo, Dept2, Department, Level, [LFL26 vs 25]
		),
-- 776,139
OtherLSBrands_Agg as (
	SELECT cast('' as nvarchar(50)) as DivisionBrand, FinYear1, [Month], [Date], cast('' as nvarchar(50)) as Country, '' as Company, TRIM([BU Code]) as StoreNo, cast('' as nvarchar(50)) as StoreName, cast('' as nvarchar(50)) as ShortName,
		UPPER(Family) as Dept2, UPPER(SubFamily) as Department, 'L-1' as Level, '' as MTDYN, 'LFL' as LFLYN,
		SUM(Qty) Qty, SUM(sales$) Sales$, cast('0' as decimal(19,4)) Cost$, '0' as ClaimAmount$, cast('0' as decimal(19,4)) as Margin$ 
	FROM Stg_SalesConsol_OtherLS 
	WHERE Date between DATEADD(YEAR,-1,cast(GETDATE()-1 as date)) and cast(GETDATE()-1 as date)
		and Brand in ('B4','B5','D1')
	GROUP BY FinYear1, [Month], [Date], TRIM([BU Code]), 
		Family, SubFamily
	)

SELECT *
INTO #TempTable -- combined data but few missing fields that needs to be updated.
FROM (
	SELECT * FROM Virgin_Agg
	UNION ALL
	SELECT * FROM OtherLSBrands_Agg) t

-- Update DivisionBrand, Country, StoreName, ShortName
Update a
set 
	a.DivisionBrand	= b.BrandName,
	a.Country		= b.Country,
	a.StoreName		= b.StoreName,
	a.ShortName		= b.ShortName
from #TempTable a
left join Dim_StoreName_TotalDiv b
	on a.StoreNo = b.StoreCode

-- Update MTDYN
Update a
set a.MTDYN	= 
	case when Month(GETDATE()-1) = Month(date)
		then 'Y' else 'N'
	end 
from #TempTable a

SELECT * FROM #TempTable

GO






