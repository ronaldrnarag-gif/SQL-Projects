/*	
-- Further update on Provision Calculation
-- Calculation Logic : 										
										
	• Lifestyle Only 									
	• Stanley brand, Demo, Defective, RTV locations will follow old calculation									
	• Change in Prov %'s for the rest of categories :									
		○ Bracket [3-6M] From 25% To 10%								
		○ Bracket [6-9M] From 50% To 30%								
		○ Brackets [>9M] and the rest of brackets remains the same as old.	
		
-- Check if impact is the same -$357k (Mar26 vs Feb)
-- created ronaldn/20260401
*/										
										
										
; with temp_tbl as (										
select Company, Store, StoreType, StockbracketDescription, StockBracket, Brand, 										
	SUM(total_stk_qty) QtyOH, SUM(total_Stk$) Stock$, SUM(total_prov$) Prov$,									
	case 									
		when StoreType in ('Demo','Defective','RTV/TRF') then 'Demo/Defective/Rtv'								
		when Brand = 'STANL' then 'Stanley'								
		else 'others'								
	end as 'Ref'									
from VW_StockAgeing										
where Stype in ('normal purchase','purchase foreign')										
	and Dept2 = 'lifestyle'									
group by Company, Store, StoreType, StockbracketDescription, StockBracket, Brand										
	)									
										
-- new provision simulation										
select *,										
	ISNULL(									
	case 									
		when [Ref] <> 'Others' then Prov$								
		when [Ref] = 'Others' 								
			and [StockBracket] = '>9M' then Prov$							
		when [Ref] = 'Others' 								
			and [StockBracket] = '3-6M' then (Stock$ * 0.1)							
		when [Ref] = 'Others' 								
			and [StockBracket] = '6-9M' then (Stock$ * 0.3) 							
	end, 0) as 'NewProv$'									
from temp_tbl;										
										
go										
										
