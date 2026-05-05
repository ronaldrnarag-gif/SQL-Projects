USE [AxDW]
GO

/****** Object:  View [dbo].[View_DSR_TotalDiv_Budget]    Script Date: 05/05/2026 18:54:58 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO


/*
Purpose		:	Create a Budget table with combined numbers from all Lifestyle Division Brands
Logic		:	Fact_Budget for Virgin + Fact_Budget_OtherLS --> combine into 1 view table
Created		:	ronaldn/20260505

*/

ALTER VIEW [dbo].[View_DSR_TotalDiv_Budget] as

-- Sales - Virgin Brand
WITH SalesCons_Virgin as (
	select b.BrandName, a.FinYear1, a.Month, a.WeekNo, a.Date,b.Country, b.Country_Code, a.StoreNo as Store_Code, b.BU,  b.Store_Name, 
		isnull(SUM(a.OriginalBudget),0) SalesBudget, isnull(SUM(a.Margin),0) MarginBudget
	from Fact_Budget a
	left join Dim_StoreName_TotalDiv b
		on a.StoreNo=b.Store_Code
	where (
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
	group by b.BrandName, a.FinYear1, a.Month, a.WeekNo, a.Date,b.Country, b.Country_Code, a.StoreNo, b.BU,  b.Store_Name

	),

-- Sales - Other Lifestyle Brands 
SalesCons_OtherLS as (
	select b.BrandName, a.FinYear1, a.Month, a.WeekNo, a.Date,b.Country, b.Country_Code, a.StoreNo as Store_Code, b.BU,  b.Store_Name, 
		SUM(a.Sales$) SalesBudget, SUM(a.Margin$) MarginBudget
	from Fact_Budget_OtherLS a
	left join Dim_StoreName_TotalDiv b
		on a.StoreNo=b.Store_Code
	where (
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
	group by b.BrandName, a.FinYear1, a.Month, a.WeekNo, a.Date, b.Country, b.Country_Code, a.StoreNo, b.BU,  b.Store_Name

	)

	-- Combine Virgin and Other LS Brands Budget into 1 file
	SELECT * ,
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
	FROM (
	SELECT * from SalesCons_Virgin
	UNION ALL
	SELECT * from SalesCons_OtherLS) t
GO


