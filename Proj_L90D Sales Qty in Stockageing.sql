



declare @startd as date;
declare @endd as date;
set @endd = GETDATE()-1
set @startd = DATEADD(day,-90,@endd)

select *
from (
	select Company, StoreNo, ItemId, stype, SUM(qty) QtySoldL90D
	from SalesConsol
	where Date between @startd and @endd
	group by Company, StoreNo, ItemId, stype
	) t

