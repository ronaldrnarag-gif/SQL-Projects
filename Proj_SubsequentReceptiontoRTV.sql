USE AzadeaWarehouse
			
-- SUBSEQUENT RCP SCRIPT			
			
; with purchase_agg as (			
        select a.date, a.companyid, a.productkey, b.productid, b.vendorgroup, b.vendorid, b.vendorname,			
                b.hir1 Dept, b.hir2 SDept, b.hir3 Cls, b.hir4 Scls,			
                sum(a.qtypurchased) qtypurchased, sum(a.costpurchased) costpurchased			
        from factpurchase a			
        left join dimproduct b			
                on a.productkey=b.productkey and upper(a.companyid)=upper(b.companyid)			
        where date between '2026-02-01' and getdate()-1			
        and purchasetype = 'Purchase Order'			
        group by a.date, a.companyid, a.productkey, b.productid, b.vendorgroup, b.vendorid, b.vendorname,			
                b.hir1 , b.hir2 , b.hir3 , b.hir4 			
        ),			
returns_agg as (			
        select a.date, a.companyid, a.productkey, b.productid, b.vendorgroup, b.vendorid, b.vendorname,			
                b.hir1 Dept, b.hir2 SDept, b.hir3 Cls, b.hir4 Scls,			
                sum(a.qtypurchased) qtyreturns, sum(a.costpurchased) costreturns			
        from factpurchase a			
        left join dimproduct b			
                on a.productkey=b.productkey and upper(a.companyid)=upper(b.companyid)			
        where date between '2026-02-01' and getdate()-1			
        and purchasetype = 'Return Order'			
        group by a.date, a.companyid, a.productkey, b.productid, b.vendorgroup, b.vendorid, b.vendorname,			
                b.hir1 , b.hir2 , b.hir3 , b.hir4 			
        )			
select a.date, a.companyid, a.productkey, a.productid, a.vendorgroup, a.vendorid, a.vendorname,			
                a.Dept, a.SDept, a.Cls, a.Scls,			
        sum(a.qtyreturns) qtyreturns, sum(a.costreturns) costreturns,			
        isnull(sum(b.qtypurchased),0) qtypurchased, isnull(sum(b.costpurchased),0) costpurchased 			
from returns_agg a			
left join purchase_agg b			
        on a.companyid=b.companyid			
        and a.productkey=b.productkey			
        and a.date <= b.date and b.date <= dateadd(day,15,a.date)			
group by a.date, a.companyid, a.productkey, a.productid, a.vendorgroup, a.vendorid, a.vendorname,			
                a.Dept, a.SDept, a.Cls, a.Scls			
order by 1 			
