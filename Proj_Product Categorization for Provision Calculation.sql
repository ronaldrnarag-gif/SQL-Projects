


/*					
Purpose     :   FIFO Stock Bucketing and Provisioning.
                This file is needed to fulfill Weekly FIFO Report Requested by Karima and Team.
Logic       :   Creates list of all sku's in vw_stockageing 
                plus added column for the Categorization needed to run the provision calculations correctly.
Created     :   ronaldn/20260327					
*/					
					
					
-- create temporary table for 'Tech Hardware' Category				
declare @exclusions table					
(					
    [SubClass Exclusions] NVARCHAR(50)					
);					
					
INSERT INTO @exclusions 					
VALUES 					
    ('ACTIVITY TRACKERS'),					
    ('ALL-IN-ONE PCS'),					
    ('APPLE WATCH'),					
    ('BINOCULARS & SCOPES'),					
    ('DESKTOP PCS'),					
    ('DIGITAL CAMERAS'),					
    ('DRONES'),					
    ('DSLR CAMERAS'),					
    ('ELECTRIC SCOOTERS'),					
    ('E-READERS'),					
    ('GAMING ALL IN ONE PCS'),					
    ('GAMING DESKTOPS'),					
    ('GAMING LAPTOPS'),					
    ('GAMING MONITORS'),					
    ('IMAC AND MAC'),					
    ('INSTANT & FILM CAMERAS'),					
    ('IPADS'),					
    ('IPHONE'),					
    ('LAPTOPS'),					
    ('MACBOOKS'),					
    ('MONITORS'),					
    ('NINTENDO CONSOLES'),					
    ('PAPER TABLETS'),					
    ('PLAYSTATION CONSOLES'),					
    ('SAMSUNG SMARTPHONES'),					
    ('SMART WATCHES'),					
    ('SMARTPHONES'),					
    ('STEAM DECK'),					
    ('TABLETS'),					
    ('VIDEO & ACTION CAMERAS'),					
    ('XBOX CONSOLES');					
					
-- Data Extraction				
drop table if exists #DataExtract					
select a.Company, a.Sku, a.Description,	a.Dept2,	a.Department,	a.Subdepartment,	a.Class,	a.Subclass, a.Brand, a.ABCFlag, a.PopGradeNo, 
    a.Stockbracketdescription, a.Stockbracket,					
	sum(a.total_stk_qty) QtyOH, sum(a.total_stk$)	Stock, sum(a.Total_Prov$) Provision,			
    case					
        when Dept2 = 'Lifestyle' then '1 - LIFESTYLE Categories'					
        when Department = 'music' and SubDepartment in ('VINYL','CDS','CASSETTES','DVD/BLU-RAY') 					
            then '2 A- MUSIC (Main Categories)'					
        when Dept2 = 'Culture' and SubDepartment not in ('VINYL','CDS','CASSETTES','DVD/BLU-RAY') 					
            then '2 B- MUSIC (Other Music+Books)'					
        when Dept2 = 'Tech' and SubClass in (select [SubClass Exclusions] from @exclusions)					
            then '3 - TECH (HARDWARE Categories)'					
        when Dept2 = 'Tech' and SubClass not in (select [SubClass Exclusions] from @exclusions)					
            then '4 - TECH (Other Categories)'			
        else Department
        end as 'Category'					
into #DataExtract					
from VW_StockAgeing a					
left join @exclusions b					
    on a.SubClass = b.[SubClass Exclusions]					
where a.Stype in ('normal purchase','purchase foreign')					
	and a.Department <> 'services'				
group by a.Company, a.Sku, a.Description,	a.Dept2,	a.Department,	a.Subdepartment,	a.Class,	a.Subclass,  a.Brand, a.ABCFlag, a.PopGradeNo, 
    a.stockbracketdescription, a.stockbracket					
having sum(a.total_stk_qty) <>0 and sum(a.total_stk$) <> 0;					
					
Select * from #DataExtract					
					
go	


