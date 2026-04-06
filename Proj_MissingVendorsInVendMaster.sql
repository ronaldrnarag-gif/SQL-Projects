/*
Purpose		:	Vendor consistency tracking for Jamali 
Logic		:	search for vendors existing in ItemMaster but not in VendorMaster
Created		:	ronaldn/20260406
*/


;with IM_agg as (
	select distinct COMPANY, VENDORID, VENDORNAME, ITEMGROUPNAME 
	from Dim_ItemMaster
	)

select a.*
from IM_agg a
where not exists (
	select 1
	from Stg_VendorMaster b
	where a.COMPANY=b.COMPANY and a.VENDORID=b.VENDORID
	)
	and a.VENDORID <> ''



