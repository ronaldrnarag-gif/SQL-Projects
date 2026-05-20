
/*

Purpose		:	script used to update LFLYN field automatically.
Logic		:	utilizes LFL dimensional info from 'Dim_LFL_TotalDiv' table and updates LFLYN field automatically
Created		:	ronaldn/20260520

*/

UPDATE a
SET LFLYN = 
	CASE
		-- OPENINGS
		WHEN	b.Type = 'new' 
				and b.type_period = 'TY'
				THEN 'Non-LFL'

		WHEN	b.Type = 'new' 
				and b.type_period = 'LY'
				and a.Date between '2026-02-01' 
					and DATEFROMPARTS(year(dateadd(YEAR,1,b.StartDate)),month(b.StartDate),DAY(b.StartDate))	-- this year
				THEN 'Non-LFL'

		WHEN	b.Type = 'new' 
				and b.type_period = 'LY'
				and a.Date between '2025-02-01' and b.StartDate		-- last year
				THEN 'Non-LFL'

		-- CLOSURES
		WHEN	b.Type = 'Closure' 
				and b.type_period = 'LY'
				THEN 'Non-LFL'

		WHEN	b.Type = 'Closure' 
				and b.type_period = 'TY'
				and a.Date between b.StartDate and '2027-01-31'	-- this year
				THEN 'Non-LFL'

		WHEN	b.Type = 'Closure' 
				and b.type_period = 'TY'
				and a.Date between DATEFROMPARTS(year(dateadd(YEAR,1,b.StartDate)),month(b.StartDate),DAY(b.StartDate))
					and '2026-01-31' -- last year
				THEN 'Non-LFL'

	ELSE 'LFL'

	END
FROM Stg_SalesConsol_OtherLS a
left join Dim_LFL_TotalDiv b
	on trim(a.[BU Code]) = trim(b.Store_Code)
WHERE a.FinYear1 in ('2026-27','2025-26')
