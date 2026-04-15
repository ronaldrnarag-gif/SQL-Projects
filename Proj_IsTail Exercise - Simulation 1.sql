
/*

granularity -- company, Sku level

types = purchase types only

*/

declare @endd date = getdate()-1;
declare @startdd date = dateadd(DAY,-90,@endd);

with Stock_Agg as (
	select Company, Sku, ABCFlag,
		sum(total_stk_qty) QtyOH, SUM(total_stk$) Stock, SUM(total_prov$) Prov
	from VW_StockAgeing
	where Stype like '%purch%'
	and department <> 'services'
	group by Company, Sku, ABCFlag
			),

Sales_Agg as (
	select Company, ItemId, 
		SUM(qty) QtySold
	from SalesConsol
	where Date between @startdd and @endd
	group by Company, ItemId
			),

Combined_agg as (
	select a.Company, a.Sku, a.ABCFlag,
		sum(a.QtyOH) QtyOH,
		sum(a.Stock) Stock,
		sum(a.Prov) Prov,
		sum(b.QtySold) QtySold
	from Stock_Agg a
	LEFT JOIN Sales_Agg b
		on a.Company=b.Company and a.Sku=b.ItemId
	group by a.Company, a.Sku, a.ABCFlag
	),

IsTail_Data as (
	select *,
		case 
			WHEN Prov <> 0 THEN 'Y'
			WHEN (ABCFlag in ('c','nosale')
				AND QtySold/nullif((QtySold+QtyOH),0) < 0.6) THEN 'Y'
			else 'N'
		end 'IsTail'
	from Combined_agg
			)

select ISTAIL, SUM(Stock)
from IsTail_Data
GROUP BY IsTail

