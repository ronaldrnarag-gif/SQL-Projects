USE [AxDW]
GO

/****** Object:  StoredProcedure [dbo].[Get_BSTEcommPhy]    Script Date: 4/27/2026 4:56:58 PM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



---Stock details - Best sellers for ecomm and physical stores---


CREATE procedure [dbo].[Get_BSTEcommPhy]
as 
Begin
	
Truncate TABLE Dim_BSTEcommPhy

Drop table if exists #L180DSales


-- 1. Build Last 180 Day sales Database
select Company, StoreNo, ItemId, Description, Dept2, Department, Subdepartment, Class, Subclass, Brand, 
	sum(qty) Qty, SUM(Sales$) Sales, sum(Margin$) Margin, 
	case when StoreNo in ('333','444','666','777') then 'Ecom' else 'Phy' END as StoreType,
	cast('' as nvarchar (50)) as Category, '' as BST_ALL, '' as BST_ECOM, '' as BST_PHY
into #L180DSales
from SalesConsol
where Date between dateadd(day,-180,cast(getdate()-1 as date)) and CAST(GETDATE() - 1 AS DATE)
and Stype in ('Normal Purchase','Purchase Foreign')
and Company in ('omn','bah','uae','kat','qat')
group by Company, StoreNo, ItemId, Description, Dept2, Department, Subdepartment, Class, Subclass, Brand

-- 2. Update BST Product Categorization
update a
set Category =
       Case
		   when Class = 'MOBILE PHONES' then '1-MOBILE PHONES'
		   when Class = 'MOBILE ACCESSORIES' then '2-MOBILE ACCESSORIES'
		   when Class = 'COMPUTERS' then '3-COMPUTERS'
		   when SubDepartment = 'COMPUTERS & ACCESSORIES'
				  and Class <> 'COMPUTERS' then '4-Other Computers'
		   when Class = 'TABLETS & E-READERS' then '5-TABLETS & E-READERS'
		   when Class = 'TABLET ACCESSORIES' then '6-TABLET ACCESSORIES'
		   when Class = 'SMART WATCH ACCESSORIES' then '7-SMART WATCH ACCESSORIES'
		   when Class = 'SMARTWATCHES & TRACKERS' then '8-SMARTWATCHES & TRACKERS'
		   when SubDepartment = 'AUDIO + VIDEO' then '9-AUDIO + VIDEO'
		   when Department = 'ELECTRONICS'
				  and SubDepartment not in ('MOBILES & ACCESSORIES','COMPUTERS & ACCESSORIES','TABLETS & ACCESSORIES','SMART WATCHES + WEARABLES','AUDIO + VIDEO')
						 then '10-Other Electronics'
		   when Class = 'GAMING CONSOLES' then '11-GAMING CONSOLES'
		   when Class = 'GAMING PCS & MONITORS' then '12-GAMING PCS & MONITORS'
		   when SubDepartment = 'VIDEO GAMES & CARDS' then '13-VIDEO GAMES & CARDS'
		   when Department = 'GAMING'
				  and SubDepartment not in ('GAMING HARDWARE','VIDEO GAMES & CARDS')
						 then '14-Other Gaming'
		   when Department = 'FASHION' then '15-FASHION'
		   when Department = 'TOYS' then '16-TOYS'
		   when Department = 'HOUSE' then '17-HOUSE'
		   when Department = 'STATIONERY' then '18-STATIONERY'
		   when Dept2 = 'LIFESTYLE'
				  and SubDepartment not in ('FASHION','TOYS','HOUSE','STATIONERY')
						 then '19-Other Lifestyle'
		   when Department = 'BOOKS' then '20-BOOKS'
		   when SubDepartment = 'VINYL' then '21-VINYL'
		   when SubDepartment = 'TURNTABLES & AUDIO' then '22-TURNTABLES & AUDIO'
		   when SubDepartment = 'CDS' then '23-CDS'
		   when Department = 'MUSIC'
				  and SubDepartment not in ('VINYL','TURNTABLES & AUDIO','CDS')
						 then '24-Other Music'
		END
from #L180DSales a

-- 3. Ecomm Top 80 %
; WITH Ecomm_BST as (
	select *, CummulativeSales/nullif(TotalSales,0) PctTotal, 'Ecm' as Storetype
	from (
		select Company, Category, ItemId
			,sum(Sales) Sales
			,sum(sum(sales)) over(partition by Company, Category order by Company, Category, sum(sales) desc rows between unbounded preceding and current row) as CummulativeSales
			,sum(sum(sales)) over(partition by company, category) as TotalSales 
			,ROW_NUMBER() over(partition by company, category order by Company, Category, sum(sales) desc) Rank
		from #L180DSales
		where StoreType = 'Ecom'
		group by Company, Category, ItemId) t
	where CummulativeSales/nullif(TotalSales,0) <= 0.8
	),

-- 4. Physical Stores Top 80 %
Phy_BST as (
	select *, CummulativeSales/nullif(TotalSales,0) PctTotal, 'Phy' as Storetype
	from (
		select Company, Category, ItemId
			,sum(Sales) Sales
			,sum(sum(sales)) over(partition by Company, Category order by Company, Category, sum(sales) desc rows between unbounded preceding and current row) as CummulativeSales
			,sum(sum(sales)) over(partition by company, category) as TotalSales 
			,ROW_NUMBER() over(partition by company, category order by Company, Category, sum(sales) desc) Rank
		from #L180DSales
		where StoreType = 'Phy'
		group by Company, Category, ItemId) t
	where CummulativeSales/nullif(TotalSales,0) <= 0.8
	)

-- 5. 

INSERT into Dim_BSTEcommPhy 
SELECT  * FROM (
select * from Ecomm_BST
UNION ALL
select * from Phy_BST) d
 


End; 


GO

