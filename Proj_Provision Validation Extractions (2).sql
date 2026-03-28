
select sum(total_stk_qty) QtyOH, sum(total_stk$) Stock, sum(total_prov$) Provision
from vw_stockageing_bd_202602
where company = 'uae'
	and stype in ('Normal purchase','PURCHASE FOREIGN')
	and department <> 'services'



select Sku, Description, Dept2, Department, Subdepartment, Class, Subclass, 
	StockBracketDescription, StockBracket,
	sum(total_stk_qty) QtyOH, sum(total_stk$) Stock, sum(total_prov$) Provision
from vw_stockageing_bd_202602
where company = 'uae'
	and stype in ('Normal purchase','PURCHASE FOREIGN')
group by Sku, Description, Dept2, Department, Subdepartment, Class, Subclass, 
	StockBracketDescription, StockBracket
	
-- 1 - LIFESTYLE Categories
select Sku, Description, Dept2, Department, Subdepartment, Class, Subclass, 
	StockBracketDescription, StockBracket,
	sum(total_stk_qty) QtyOH, sum(total_stk$) Stock, sum(total_prov$) Provision
from vw_stockageing_bd_202602
where company = 'uae'
	and stype in ('Normal purchase','PURCHASE FOREIGN')
	and department <> 'services'
	and Dept2 = 'LIFESTYLE'
group by Sku, Description, Dept2, Department, Subdepartment, Class, Subclass, 
	StockBracketDescription, StockBracket

-- 4 - TECH (Other Categories)
select Sku, Description, Dept2, Department, Subdepartment, Class, Subclass, 
	StockBracketDescription, StockBracket,
	sum(total_stk_qty) QtyOH, sum(total_stk$) Stock, sum(total_prov$) Provision
from vw_stockageing_bd_202602
where company = 'uae'
	and stype in ('Normal purchase','PURCHASE FOREIGN')
	and department <> 'services'
	and Dept2 = 'TECH'
	AND subclass not in 
		('ACTIVITY TRACKERS',
		'ALL-IN-ONE PCS',
		'APPLE WATCH',
		'BINOCULARS & SCOPES',
		'DESKTOP PCS',
		'DIGITAL CAMERAS',
		'DRONES',
		'DSLR CAMERAS',
		'ELECTRIC SCOOTERS',
		'E-READERS',
		'GAMING ALL IN ONE PCS',
		'GAMING DESKTOPS',
		'GAMING LAPTOPS',
		'GAMING MONITORS',
		'IMAC AND MAC',
		'INSTANT & FILM CAMERAS',
		'IPADS',
		'IPHONE',
		'MACBOOKS',
		'MONITORS',
		'NINTENDO CONSOLES',
		'PAPER TABLETS',
		'PLAYSTATION CONSOLES',
		'SAMSUNG SMARTPHONES',
		'SMART WATCHES',
		'SMARTPHONES',
		'STEAM DECK',
		'TABLETS',
		'VIDEO & ACTION CAMERAS',
		'XBOX CONSOLES')
group by Sku, Description, Dept2, Department, Subdepartment, Class, Subclass, 
	StockBracketDescription, StockBracket



-- 3 - TECH (HARDWARE Categories)

select Sku, Description, Dept2, Department, Subdepartment, Class, Subclass, 
	StockBracketDescription, StockBracket,
	sum(total_stk_qty) QtyOH, sum(total_stk$) Stock, sum(total_prov$) Provision
from vw_stockageing_bd_202602
where company = 'uae'
	and stype in ('Normal purchase','PURCHASE FOREIGN')
	and department <> 'services'
	and Dept2 = 'TECH'
	AND subclass in 
		('ACTIVITY TRACKERS',
		'ALL-IN-ONE PCS',
		'APPLE WATCH',
		'BINOCULARS & SCOPES',
		'DESKTOP PCS',
		'DIGITAL CAMERAS',
		'DRONES',
		'DSLR CAMERAS',
		'ELECTRIC SCOOTERS',
		'E-READERS',
		'GAMING ALL IN ONE PCS',
		'GAMING DESKTOPS',
		'GAMING LAPTOPS',
		'GAMING MONITORS',
		'IMAC AND MAC',
		'INSTANT & FILM CAMERAS',
		'IPADS',
		'IPHONE',
		'MACBOOKS',
		'MONITORS',
		'NINTENDO CONSOLES',
		'PAPER TABLETS',
		'PLAYSTATION CONSOLES',
		'SAMSUNG SMARTPHONES',
		'SMART WATCHES',
		'SMARTPHONES',
		'STEAM DECK',
		'TABLETS',
		'VIDEO & ACTION CAMERAS',
		'XBOX CONSOLES')
group by Sku, Description, Dept2, Department, Subdepartment, Class, Subclass, 
	StockBracketDescription, StockBracket






-- 2 B- MUSIC (Other Categories)

select Sku, Description, Dept2, Department, Subdepartment, Class, Subclass, 
	StockBracketDescription, StockBracket,
	sum(total_stk_qty) QtyOH, sum(total_stk$) Stock, sum(total_prov$) Provision
from vw_stockageing_bd_202602
where company = 'uae'
	and stype in ('Normal purchase','PURCHASE FOREIGN')
	and department <> 'services'
	and department = 'music'
	and subdepartment in 
		('PRE-OWNED VINYL',
		'TURNTABLES & AUDIO',
		'OTHER MUSIC ITEMS',
		'MUSIC MERCHANDISE',
		'ISLAMIC',
		'MUSICAL INSTRUMENTS')
group by Sku, Description, Dept2, Department, Subdepartment, Class, Subclass, 
	StockBracketDescription, StockBracket


-- 2 A- MUSIC (Main Categories) & BOOK Categories

select Sku, Description, Dept2, Department, Subdepartment, Class, Subclass, 
	StockBracketDescription, StockBracket,
	sum(total_stk_qty) QtyOH, sum(total_stk$) Stock, sum(total_prov$) Provision
from vw_stockageing_bd_202602
where company = 'uae'
	and stype in ('Normal purchase','PURCHASE FOREIGN')
	and department <> 'services'
	and department in ('music','books')
	and subdepartment not in 
		('PRE-OWNED VINYL',
		'TURNTABLES & AUDIO',
		'OTHER MUSIC ITEMS',
		'MUSIC MERCHANDISE',
		'ISLAMIC',
		'MUSICAL INSTRUMENTS')
group by Sku, Description, Dept2, Department, Subdepartment, Class, Subclass, 
	StockBracketDescription, StockBracket
