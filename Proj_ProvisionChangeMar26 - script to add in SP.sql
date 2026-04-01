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
																													
update vw_stockageing
set Total_Prov$ = 																		
	case 									
		when StoreType in ('Demo','Defective','RTV/TRF')
			or Brand = 'STANL' 
		then Total_Prov$
		else
			case 													
			    when [StockBracket] = '3-6M' then (Total_Stk$ * 0.1)															
			    when [StockBracket] = '6-9M' then (Total_Stk$ * 0.3)
				when [StockBracket] = '>9M' then Total_Prov$
				else Total_Prov$	
			end
	end 
where Dept2 = 'Lifestyle'
									
										
									
										
