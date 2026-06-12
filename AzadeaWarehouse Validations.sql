USE AzadeaWarehouse
--USE Lakehouse_Presentation

select * from sys.tables order by name

select top 10 * from factinventory
select top 10 * from dimproduct
select top 10 * from dimstore
select top 10 * from fact_inventory_with_provision_aging

select *
from factinventory a
left join dimproduct b
	on a.productkey=b.productkey and upper(a.companyid)=upper(b.companyid)
left join dimstore c
	on a.storekey=c.storekey

