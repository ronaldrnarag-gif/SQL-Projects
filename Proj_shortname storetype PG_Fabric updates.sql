USE AzadeaWarehouse

shortname					= dimstore
storetype					= dimstore
productlifecyclestateid		= dimproduct

---------

select max(date) from factsalesnew

select distinct purchstatus from factpurchaseorder

select top 10 * from dimproduct

select * from sys.objects 
where type_desc not in ('INTERNAL_TABLE','SERVICE_QUEUE','SYSTEM_TABLE')
order by type_desc

----------

select top 10 * from factscrdwh

select distinct ltshortname from factsalestransactioncountnew


---------------------


-- 1- fact_inventory_with_provision_aging

	select top 10 * from fact_inventory_with_provision_aging



	---------

	alter table fact_inventory_with_provision_aging
	drop column popgradeno

	alter table fact_inventory_with_provision_aging
	add popgradeno varchar(50)

	---------

	update a
	set 
		a.storeshortname	= b.shortname,
		a.storetype			= b.storetype,
		a.popgradeno		= c.productlifecyclestateid
	from fact_inventory_with_provision_aging a
	left join dimstore b
		on a.warehouseid=b.warehouseid
	left join dimproduct c
		on upper(a.company)=upper(c.companyid)
		and a.productkey=c.productkey


-- 2- factsalesnew
	




-- 3- factsalestransactioncountnew

USE AzadeaWarehouse
USE Lakehouse_Curated

select top 10 * from salestable
select * from sys.objects


select top 10 * from factsalestransactioncountnew where warehouseid = '444'