


select top 10 * from factinventory
select top 10 * from dimproduct
select top 10 * from dimstore

-- Criteria : producttype <> 2 and itemmodelgroup <> 'FIFO'

itemmodelgroup
locationkey
warehouseid
productkey
productid
producttype

productgroup
vendorgroup
_______________


select a.companyid, c.warehouseid, b.productid, a.ltitemgroupid, b.itemmodelgroup, b.productgroup bproductgroup, b.vendorgroup bvendorgroup, a.ltitemgroupidinventtransorigin,sourcemovement,
	cast(sum(a.netqty) as decimal(19,4)) netqty, cast(sum(a.netcost) as decimal(19,4)) netcost
from factinventory a
left join dimproduct b
	on a.productkey = b.productkey
left join dimstore c 
	on a.locationkey = c.locationkey
where date <= '2026-02-28'  and a.locationkey = '15'
group by a.companyid, c.warehouseid, b.productid, a.ltitemgroupid, b.itemmodelgroup, b.productgroup, b.vendorgroup, a.ltitemgroupidinventtransorigin,sourcemovement


--660845

select b.itemmodelgroup, b.productgroup bproductgroup, b.vendorgroup bvendorgroup,b.producttype, a.*
from factinventory a
left join dimproduct b
	on a.productkey = b.productkey
left join dimstore c 
	on a.locationkey = c.locationkey
where date <= '2026-02-28'  and a.locationkey = '15' and b.productid in ('307448','319942','363580')


select distinct producttype from dimproduct
