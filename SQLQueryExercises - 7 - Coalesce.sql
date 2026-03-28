
select coalesce(a.company,b.company) as company,
	coalesce(a.store,b.brand) as store,
	coalesce(sum(a.total_stk_qty),0) as qtyoh, 
	coalesce(sum(a.total_stk$),0) as stk$
from vw_stockageing a
full join SalesConsol b 
on (a.Company=b.company and a.store=b.brand)
where coalesce(a.company,b.Company) = 'uae'
and coalesce(a.stype, b.stype) = 'normal purchase'
and coalesce(a.Store, b.brand) = '416'
and b.FinYear1 = '2025-26'
and b.Month = 'mar' 
group by coalesce(a.company,b.company),
	coalesce(a.store,b.brand)
order by coalesce(a.company,b.company),
	coalesce(a.store,b.brand)