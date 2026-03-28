

-- while loop

DECLARE @MINDATE DATE, @ENDDATE DATE;

SET @MINDATE = (SELECT MIN(DATE) FROM SalesConsol WHERE FinYear1 = '2026-27');
SET @ENDDATE = (SELECT MAX(DATE) FROM SalesConsol WHERE FinYear1 = '2026-27');

drop table if exists #DateList;
create table #DateList 
	(
		Date date
		);

declare @counter int = 1

while @counter <= 10
begin
	insert into #DateList
	values (@MINDATE);
	set @counter += 1;
end

select * from #DateList;

go






