

-- temptable 1
create table #StoreList
(
	Company		varchar(10), 
	Storeno		int,
	StoreName	nvarchar(25)
)

insert into #StoreList
values 
	('uae','405','moe'),
	('uae','416','tdm'),
	('uae','424','yas'),
	('uae','438','hls')


-- temptable 2
create table #StoreList2
(
	Company		varchar(10), 
	Storeno		int,
	StoreName	nvarchar(25)
)

insert into #StoreList2
values 
	('uae','423','dmm'),
	('uae','435','reem'),
	('uae','405','moe'),
	('uae','416','tdm')



select * from #StoreList
select * from #StoreList2

---------------------

;with aa as (
	select a.*
	from #StoreList a
	full join #StoreList2 b
		on a.Storeno = b.Storeno
	),
bb as (
	select b.*
	from #StoreList a
	full join #StoreList2 b
		on a.Storeno = b.Storeno
	),
combined as (
select * from aa
union
select * from bb
)
select distinct * 
into finalstorelist
from combined 
where Storeno is not null order by Storeno

select * from finalstorelist
