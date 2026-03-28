

alter function FN_LatestStock()

/*
	Purpose	:	provides easy way to check latest stock level by country	
	Logic	:	vw_stockageing table, purchase types only
	Created	:	ronaldn/20260328
*/

returns @result Table
	(
	Company		varchar(10),
	Quantity	int,
	Stock		decimal(10,2),
	Provision	decimal (10,2)
	)

as

begin
	insert into @result
		select isnull(Company,'Total') Company, SUM(total_stk_qty), SUM(total_stk$), sum(total_prov$)
		from vw_stockageing
		where Stype in ('normal purchase','purchase foreign')
		and Department <> 'services'
		Group by rollup(Company);
	return;
end;

select *
from FN_LatestStock()



