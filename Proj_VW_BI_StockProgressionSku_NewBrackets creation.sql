/*
Purpose			:	StockProgressionSku based on new aging bucketing rules
Requested by	:	Karima/Liana 
Created			:	ronaldn/20260429
*/

CREATE VIEW VW_BI_StockProgressionSku_NewBrackets AS

-- 1. Create temptable for date
WITH Calendar_agg as (
	select distinct Fin_Yr1, Fin_Mo, 
		cast(MAX([date]) over(partition by Fin_Yr1, Fin_Mo order by Fin_Yr1, Fin_Mo) as date) MaxDate
	from Dim_VirginCalendar
	where Fin_Yr1 in ('2025-26','2026-27')
	),

-- 2.
StockProgSku as (
	select a.*, b.MaxDate as [Date],
		CASE 
			WHEN DATEDIFF(day, cast(a.LRDEntity as date), cast(b.MaxDate as date)) <= 90 then '0-3m'
			WHEN DATEDIFF(day, cast(a.LRDEntity as date), cast(b.MaxDate as date)) <= 180 then '3-6m'
			WHEN DATEDIFF(day, cast(a.LRDEntity as date), cast(b.MaxDate as date)) <= 270 then '6-9m'
			WHEN DATEDIFF(day, cast(a.LRDEntity as date), cast(b.MaxDate as date)) <= 360 then '9-12m'
			WHEN DATEDIFF(day, cast(a.LRDEntity as date), cast(b.MaxDate as date)) <= 540 then '12-18m'
			WHEN DATEDIFF(day, cast(a.LRDEntity as date), cast(b.MaxDate as date)) > 540 then '>18m'	
		END as 'NewBracket'
	from Fact_StockProgressionSku a
	left join Calendar_agg b
		on a.FinYear1=b.Fin_Yr1 and a.Month=b.Fin_Mo
	where a.Stype like '%purch%'
	AND a.DeptCode <> '12'
	and a.FinYear1 in ('2025-26','2026-27')
	)

-- 3. Results
select FinYear1, Month, 	Company, Supplier,	Brand,	PopGradeNo,	Dept2,	DeptCode,	
	StoreType,	StockBracket,	ABCFlag,	Date,	NewBracket,
	sum(Total_Stk_Qty) QtyOH,
	sum(Total_Stk$) Stock$,
	sum(Total_Prov$) Prov$
from StockProgSku
group by FinYear1, Month, 	Company, Supplier,	Brand,	PopGradeNo,	Dept2,	DeptCode,	
	StoreType,	StockBracket,	ABCFlag,	Date,	NewBracket

SELECT FINYEAR1, MONTH, SUM(Stock$) STK
FROM VW_BI_StockProgressionSku_NewBrackets
GROUP BY FINYEAR1, MONTH