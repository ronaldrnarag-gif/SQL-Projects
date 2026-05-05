USE [AxDW]
GO

/****** Object:  View [dbo].[View_DSR_TotalDiv]    Script Date: 05-May-2026 2:38:34 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*

Purpose			:	Combine all lifestyle division brands into 1 table to be utilized in building total division DSR.
Logic			:	SalesConsol + View_SalesConsol_OtherLS, combine into 1
Created			:	ronaldn/20260505

*/

ALTER View [dbo].[View_DSR_TotalDiv] as

-- Sales - Virgin Brand
WITH SalesCons_Virgin as (
	select 'Virgin' as BrandName, a.FinYear1, a.Month, a.Date, b.Country, b.Country_Code, a.StoreNo as Store_Code, b.BU,
		b.Store_Name, b.Short_Name, a.Dept2, a.Department, a.SubDepartment, a.Class, a.SubClass, a.Level, a.[LFL26 vs 25] as LFLYN,
		SUM(a.Qty) Qty, SUM(a.Sales$) Sales, SUM(a.Cost$) Cost, SUM(a.ClaimAmount$) Claim, SUM(a.Margin$) Margin
	from SalesConsol a
	left join Dim_StoreName_TotalDiv b
		on a.Company=b.Country_Code and a.StoreNo=b.Store_Code
	where a.Level in ('L-1','L-2')
		and (
			-- This years YTD date range
			(a.Date between 
			(select cast(MIN(date) as date)
			from Dim_VirginCalendar
			where Fin_Yr1 = (
				select distinct Fin_Yr1
				from Dim_VirginCalendar
				where Date = cast(getdate()-1 as date) 
							)
			) 
			and 
			cast(GETDATE()-1 as date)) 
		or 
			-- Last years YTD date range
			(a.Date between 
			(select cast(MIN(date) as date)
			from Dim_VirginCalendar
			where Fin_Yr1 = (
				select distinct Fin_Yr1
				from Dim_VirginCalendar
				where Date = DATEADD(YEAR,-1,cast(GETDATE()-1 as date)) 
							)
			) 
			and DATEADD(YEAR,-1,cast(GETDATE()-1 as date))) 
			)
	group by b.BrandName, a.FinYear1, a.Month, a.Date, b.Country, b.Country_Code , a.StoreNo, b.BU,
		b.Store_Name, b.Short_Name, a.Dept2, a.Department, a.SubDepartment, a.Class, a.SubClass, a.Level, a.[LFL26 vs 25]

	),

-- Sales - Other Lifestyle Brands 

SalesCons_OtherLS as (
	select b.BrandName, a.FinYear1, a.Month, a.Date, b.Country, b.Country_Code, b.Store_Code, b.BU,
		b.Store_Name, b.Short_Name, '' Dept2, trim(a.Family) as Department, trim(a.SubFamily) as SubDepartment, 
		'' Class, '' SubClass, 'L-1' as Level, 'LFL' LFLYN,
		SUM(a.Qty) Qty, SUM(a.Sales$) Sales, SUM(Cost$) Cost, 0 as Claim, SUM(Margin$)  Margin
	from View_SalesconsolOtherLS a
	left join Dim_StoreName_TotalDiv b
		on trim(a.[BU Code])=trim(b.Store_Code)
	where 
			-- This years YTD date range
			(a.Date between 
			(select cast(MIN(date) as date)
			from Dim_VirginCalendar
			where Fin_Yr1 = (
				select distinct Fin_Yr1
				from Dim_VirginCalendar
				where Date = cast(getdate()-1 as date) 
							)
			) 
			and 
			cast(GETDATE()-1 as date)) 
		or 
			-- Last years YTD date range
			(a.Date between 
			(select cast(MIN(date) as date)
			from Dim_VirginCalendar
			where Fin_Yr1 = (
				select distinct Fin_Yr1
				from Dim_VirginCalendar
				where Date = DATEADD(YEAR,-1,cast(GETDATE()-1 as date)) 
							)
			) 
			and DATEADD(YEAR,-1,cast(GETDATE()-1 as date))) 
	group by b.BrandName, a.FinYear1, a.Month, a.Date, b.Country, b.Country_Code, b.Store_Code, b.BU,
		b.Store_Name, b.Short_Name, a.Family, a.SubFamily

	)

-- Combine Virgin and Other LS Sales Data into 1
select *, 
	CASE 
		WHEN Month(date)=Month(cast(GETDATE()-1 as date))
		THEN 'Y'
		ELSE 'N'
	END isMTD,
	CASE
		WHEN FinYear1 = (
			SELECT distinct Fin_Yr1 
			FROM Dim_VirginCalendar 
			WHERE Date = cast(GETDATE()-1 as date))
		THEN 'TY'
		ELSE 'LY'
	END isTYLY
from (
SELECT * from SalesCons_Virgin
UNION ALL
SELECT * from SalesCons_OtherLS
	) t


GO


