
-- top 3 highest VSP's by company by stype

	select *
	from
	(
		select Company, ITEMGROUPNAME, ITEMNUMBER, PRODUCTNAME,
			cast(Price as int) Price,
			row_number() over (partition by company, itemgroupname order by Company desc, ITEMGROUPNAME asc , PRICE desc) as RowNum
		from Dim_ItemMaster
		where ITEMGROUPNAME not in ('Fixed License','Marketing Income')
		) t
	where RowNum <= 3
	order by Company desc, ITEMGROUPNAME asc , PRICE desc


--- top 3 highest VSP's by company by stype

	with StockAg_Agg as (
		select company, sku, 
			sum(total_stk_qty) Qtyoh
		from vw_stockageing 
		where company = 'uae'
		group by Company, sku
	),
	ItemMaster_Agg as (
	select Company, ITEMGROUPNAME, ITEMNUMBER, PRODUCTNAME,
			cast(Price as int) Price, 
			row_number() over (partition by company, itemgroupname order by Company desc, ITEMGROUPNAME asc , PRICE desc) as RowNum
		from Dim_ItemMaster a
		where ITEMGROUPNAME not in ('Fixed License','Marketing Income')
			and company = 'uae'
			and exists 
			(
				select 1
				from StockAg_Agg b
				where b.Qtyoh > 0
				and a.ITEMNUMBER=b.sku
			)
		)
	select a.*, b.Qtyoh
	from ItemMaster_Agg a
	left join StockAg_Agg b
		on a.ITEMNUMBER=b.Sku
	where a.RowNum <= 3
	order by a.Company desc, a.ITEMGROUPNAME asc , a.PRICE desc