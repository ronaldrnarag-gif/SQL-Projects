


-- High Level Check 
		-- As on
		select Company,
			cast(sum(Total_Stk_Qty) as int) QtyOH, 
			cast(sum(total_stk$) as int) Stock, 
			cast(sum(total_prov$) as int) Provision, 
			'Ason' [Ref]
		from vw_stockageing
		where stype in ('normal purchase','purchase foreign')
		and Department <> 'services'
		and company in ('uae','qat','bah','omn','kat')
		group by Company order by 1 desc

		-- BD Last Month
		select Company,
			cast(sum(Total_Stk_Qty) as int) QtyOH, 
			cast(sum(total_stk$) as int) Stock, 
			cast(sum(total_prov$) as int) Provision, 
			'BD' [Ref]
		from VW_StockAgeing_BD_202602
		where stype in ('normal purchase','purchase foreign')
		and Department <> 'services'
		and company in ('uae','qat','bah','omn','kat')
		group by Company order by 1 desc


-- Granular Check
	with Ason_Agg as (
		-- As on 
		select company, Store, Dept2, Department, SubDepartment, Class, Subclass, Brand, supplier, SupplierName,
				StockBracketDescription, StockBracket,
				cast(sum(total_stk$) as int) Stock, cast(sum(total_prov$) as int) Provision,
				'Ason' [Ref]
		from vw_stockageing
		where stype in ('normal purchase','purchase foreign')
		and Department <> 'services'
		and Company = 'qat'
		group by company, Store, Dept2, Department, SubDepartment, Class, Subclass, Brand, supplier, SupplierName,
				StockBracketDescription, StockBracket
		),
	BD_Agg as (
		-- Last Month
		select company, Store, Dept2, Department, SubDepartment, Class, Subclass, Brand, supplier, SupplierName,
				StockBracketDescription, StockBracket,
				cast(sum(total_stk$) as int) Stock, cast(sum(total_prov$) as int) Provision,
				'BD' [Ref]
		from VW_StockAgeing_BD_202602
		where stype in ('normal purchase','purchase foreign')
		and Department <> 'services'
		and Company = 'qat'
		group by company, Store, Dept2, Department, SubDepartment, Class, Subclass, Brand, supplier, SupplierName,
				StockBracketDescription, StockBracket
		),
	Agg_Agg as (
		select *
		from Ason_Agg
		union all
		select *
		from BD_Agg
	)
	select * from Agg_Agg


	select stype, sum(onhandqty) OHQty, sum(total_stk) Stock
	from Stg_StockStaging
	where company = 'qat'
	group by stype order by stype
