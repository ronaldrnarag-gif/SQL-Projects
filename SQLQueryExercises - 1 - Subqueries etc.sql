


-- OverAll Stock Picture 
	-- As on 
	select format(sum(total_stk$), '$ #,###') Stock, format(sum(total_prov$), '$ #,###') ProvisionAson,
			format(sum(total_prov$)/sum(total_stk$), '#.00%') 'Prov%'
	from vw_stockageing
	where stype in ('normal purchase','purchase foreign')
	and Department <> 'services'

	-- Last Month
	select format(sum(total_stk$), '$ #,###') Stock, format(sum(total_prov$), '$ #,###') ProvisionFeb,
			format(sum(total_prov$)/sum(total_stk$), '#.00%') 'Prov%'
	from vw_stockageing_bd_202602
	where stype in ('normal purchase','purchase foreign')
	and Department <> 'services'

-- Example of Subquery

	-- example 1 - inventory level for only Core Categories

	Select stype, sum(total_stk$) 
	from vw_stockageing
	where stype in 
	(
		select distinct Stype
		from SalesConsol
		where level = 'L-1'
		and FinYear1 = '2026-27'
		and stype is not null
		) 
	group by Stype

	-- example 2 -- top 5 selling products by country in march - like CTE

	select *
	from
	(
		select company, ItemID, Description, 
			sum(sales$) sales,
			row_number() over (partition by company order by company desc, sum(sales$) desc) as RowNum
		from SalesConsol
		where FinYear1 = '2026-27' and Month = 'mar' 
			and Level = 'L-1'
		group by company, ItemID, Description
		--order by company desc, sum(sales$) desc
		) as Agg
	where RowNum <= 5
	order by company desc, sales desc

	-- if Converted into CTE this is how it looks :

	; with Agg as (
		select company, ItemID, Description, 
			sum(sales$) sales,
			row_number() over (partition by company order by company desc, sum(sales$) desc) as RowNum
		from SalesConsol
		where FinYear1 = '2026-27' and Month = 'mar' 
			and Level = 'L-1'
		group by company, ItemID, Description
		--order by company desc, sum(sales$) desc
		) 
	select *
	from Agg
	where RowNum <= 5
	order by company desc, sales desc

-- Highest contributing brands to Overall uae business margin in FY25 and their respective combined % contribution

	select brand, sales, margin, cummulativetotals, ranking,
		(cummulativetotals/
		sum(margin) over ()) as PctTotal
	from
	(
		select BRAND, sum(sales$) sales, sum(margin$) margin,
			sum(sum(margin$)) over (order by sum(margin$) desc rows between unbounded preceding and current row) as CummulativeTotals,
			RANK() over (order by sum(margin$) desc) as ranking
		from salesconsol
		where FinYear1 = '2025-26'
		and Company = 'uae'
		and Level = 'L-1'
		GROUP BY BRAND
		--order by sum(margin$) desc
		) as Agg  
	order by margin desc

-- Top 5 brand's with highest provision by Department by Country

-- Top 20 sku's with highest provision in UAE
	
	Select *
	from 
		(
		select company, sku, description, 
			sum(total_stk$) stock, sum(total_prov$) Prov,
			row_number() over (order by sum(total_prov$) desc) as RowNumber
		from vw_stockageing
		where stype in ('normal purchase','purchase foreign')
		and Department <> 'services'
		and Company = 'uae'
		group by company, sku, description
		) Agg
	where RowNumber <= 20
	order by prov desc

-- EXISTS and NOT EXISTS Example

	select i.*
	from Dim_ItemMaster i
	where i.COMPANY = 'uae'
	and EXISTS
	(
		select 1
		from vw_stockageing s
		where s.Company = 'uae'
		and s.total_stk_qty < 0
		and i.itemnumber = s.Sku
		)
	order by i.RELEASEDDATE desc


-- Conditional Aggregation
	select *, ([2026]-[2025]) as var
	from
	(
	select day(date) dayno, 
		sum(case when year(date) = '2026' then sales$ else 0 end) as [2026],
		sum(case when year(date) = '2025' then sales$ else 0 end) as [2025]
	from salesconsol
	where FinYear1 in ('2025-26','2026-27')
		and Month = 'mar'
		and level = 'L-1'
	group by day(date)
	) as agg
	where dayno <= day(getdate()-1)
	order by dayno
	

