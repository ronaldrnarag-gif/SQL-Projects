/*
Purpose		:	Vendor consistency tracking for Jamali 
Logic		:	search for vendors existing in ItemMaster but not in VendorMaster
Created		:	ronaldn/20260406
*/

select a.*
from Dim_ItemMaster a
where Not exists (
	select 1
	from Stg_VendorMaster b
	where a.COMPANY=b.COMPANY and a.VENDORID=b.VENDORID
	)
	and a.VENDORID <> ''



