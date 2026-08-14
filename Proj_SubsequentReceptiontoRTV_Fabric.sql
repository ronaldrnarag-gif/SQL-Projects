USE AzadeaWarehouse
			
-- 		

/*
Title       : Report on Rtv's with subsequent Rcp
Purpose     : Provides rtv data with info about receptions done 15 days subsequent to rtv date
Logic       : 
    1- utilizes factpurchase which contains combination of purchase orders and return orders.
    2- creates cte for returns, then for purchase
    3- recreates rtv table, add's 2 more columns for repurchase qty and value by left joining it with purchase cte.
        join criteria is 
            company, 
            productkey and 
            a.date <= b.date and b.date <= dateadd(day,15,a.date)
    4- apply repurchase logic to the new dataset.
Stakeholder : Internal Control
Created     : ronaldn/20260814
*/
			
; with purchase_agg as (			
        select a.date, a.companyid, a.productkey, b.productid, a.ltitemgroupid_it itemgroupid, a.apntprimaryvendorid_it vendorid, c.vendorname,			
                b.hir1 Dept, b.hir2 SDept, b.hir3 Cls, b.hir4 Scls,			
                sum(a.qtypurchased) qtypurchased, sum(a.costpurchased) costpurchased			
        from factpurchase a			
        left join dimproduct b			
                on a.productkey=b.productkey and upper(a.companyid)=upper(b.companyid)	
        left join dimvendor c
                on a.apntprimaryvendorid_it = c.vendorid
        where date between '2026-02-01' and getdate()-1			
        and purchasetype = 'Purchase Order'			
        group by a.date, a.companyid, a.productkey, b.productid, a.ltitemgroupid_it, a.apntprimaryvendorid_it, c.vendorname,			
                b.hir1 , b.hir2 , b.hir3 , b.hir4 			
        ),		
        
returns_agg as (			
        select a.date, a.companyid, a.productkey, b.productid, a.ltitemgroupid_it itemgroupid, a.apntprimaryvendorid_it vendorid, c.vendorname,			
                b.hir1 Dept, b.hir2 SDept, b.hir3 Cls, b.hir4 Scls,			
                sum(a.qtypurchased) qtyreturns, sum(a.costpurchased) costreturns			
        from factpurchase a			
        left join dimproduct b			
                on a.productkey=b.productkey and upper(a.companyid)=upper(b.companyid)	
        left join dimvendor c
                on a.apntprimaryvendorid_it = c.vendorid
        where date between '2026-02-01' and getdate()-1			
        and purchasetype = 'Return Order'			
        group by a.date, a.companyid, a.productkey, b.productid, a.ltitemgroupid_it, a.apntprimaryvendorid_it, c.vendorname,			
                b.hir1 , b.hir2 , b.hir3 , b.hir4 			
        ),

repurchase_agg as (
        select a.date, a.companyid, a.productkey, a.productid, a.itemgroupid, a.vendorid, a.vendorname,			
                        a.Dept, a.SDept, a.Cls, a.Scls,			
                sum(a.qtyreturns) qtyreturns, sum(a.costreturns) costreturns,			
                isnull(sum(b.qtypurchased),0) qtypurchased, isnull(sum(b.costpurchased),0) costpurchased
        from returns_agg a			
        left join purchase_agg b			
                on a.companyid=b.companyid			
                and a.productkey=b.productkey			
                and a.date <= b.date and b.date <= dateadd(day,15,a.date)			
        group by a.date, a.companyid, a.productkey, a.productid, a.itemgroupid, a.vendorid, a.vendorname,			
                        a.Dept, a.SDept, a.Cls, a.Scls					
        )

select *,
    case when qtypurchased > 0 
        and -qtyreturns > 2
        then 'Y' else 'N'
    end as 'repurchaseyn',
    case when -qtyreturns = qtypurchased 
        then 'Y' else 'N'
    end as 'sameqtyrepurchaseyn'
from repurchase_agg
where itemgroupid in ('N','I','C')

