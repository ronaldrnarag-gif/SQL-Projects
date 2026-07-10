


-- Total count
select format(count(*),'#,###') totaSkuCount from dimproduct

-- Count of multiple variant skus'
; with itemm_agg as (
	select upper(companyid) companyid, productid,
		count(*) ct
	from dimproduct
	where upper(companyid) = 'UAE'
	group by upper(companyid) , productid
	having count(*) > 1000
	)
select distinct format(count(*),'#,###') highCountskus
from itemm_agg


-- sample sku's
; with itemm_agg as (
	select upper(companyid) companyid, productid,
		count(*) SkuCount
	from dimproduct
	where upper(companyid) = 'UAE'
	group by upper(companyid) , productid
	having count(*) > 1000
	)
select top 10 * 
from itemm_agg


