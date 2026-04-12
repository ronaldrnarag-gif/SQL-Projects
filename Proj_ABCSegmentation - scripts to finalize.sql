/*
	potential issue : what if first transaction date isnt reception but rather a sale?
	
*/



-- creates FRD table in BYOD
CREATE TABLE FirstReceiptDate
	(
		COMPANY				VARCHAR(10),
		ITEMID				NVARCHAR(25),
		FIRSTRECEIPTDATE	DATE
		)

-- populates FRD table 
INSERT INTO FIRSTRECEIPTDATE (COMPANY, ITEMID, FIRSTRECEIPTDATE)
(
	SELECT COMPANY, ITEMID, MIN(isnull(DATEPHYSICAL,'')) FIRSTRECEIPTDATE
	FROM LTInventTransDataStaging 
	WHERE DATEPHYSICAL > '1900-01-01 00:00:00.000' 
		and QTY > 0
	group by COMPANY, ITEMID
	)

-- bring in FRD table to local


-- left join with ItemMaster to fill in FRD Field 
-- (this also can be used to populate BD Files from last year??)


-- CREATE VIEW

CREATE VIEW VW_FirstReceiptDate as (
	SELECT COMPANY, ITEMID, MIN(isnull(DATEPHYSICAL,'')) FIRSTRECEIPTDATE
	FROM LTInventTransDataStaging 
	WHERE DATEPHYSICAL > '1900-01-01 00:00:00.000' 
		and QTY > 0
	group by COMPANY, ITEMID
	);


-- QUERY FRD TABLE IN BYOD FROM LOCAL

SELECT TOP 10 *
FROM OPENQUERY(AZUREDB,
'
    SELECT *
    FROM dbo.VW_FirstReceiptDate
');
---------------------------------------------------------------------------------------------------------------
-- creates FRD table in Local server
CREATE TABLE Dim_FirstReceiptDate 
(
    COMPANY             VARCHAR(10),
    ITEMID              NVARCHAR(25),
    FIRSTRECEIPTDATE    DATE
    )

-- populates local FRD Table
INSERT INTO Dim_FirstReceiptDate (COMPANY, ITEMID, FIRSTRECEIPTDATE)
SELECT *
FROM OPENQUERY(AZUREDB,
'
    SELECT *
    FROM dbo.VW_FirstReceiptDate
');

-- populates itemmaster using local FRD table
update im
set im.firstreceiptdate = fr.firstreceiptdate
from Dim_ItemMaster im
left join Dim_FirstReceiptDate fr
    on im.company=fr.company and im.itemnumber=fr.itemid

-- check and validate, this should result to blank.
select Company, Sku, LASTRECEIPTDATE_ENTITY, 
    SUM(total_stk_qty) qtyoh, SUM(Total_Stk$) stk
from VW_StockAgeing a
where exists (
    select 1
    from Dim_ItemMaster b
    where a.Company = b.COMPANY and a.Sku = b.ITEMNUMBER
        and (FIRSTRECEIPTDATE is null or FIRSTRECEIPTDATE = '')
        and ITEMGROUPID not in ('H','D','ticketing','services')
        and PopGradeNo <> '5'
            )
group by Company, Sku, LASTRECEIPTDATE_ENTITY
having SUM(total_stk_qty) > 1

-- populate missing FRD in 2024 BD Files in StockProgressionSku (missing is starting july and before)

-- check
select *
from Fact_StockProgressionSku
where FinYear1 = '2024-25'
    and Month = 'jul'
    and FRDEntity > '2024-07-31'
    and Total_Stk_Qty > 0
order by FRDEntity desc

-- update FRD in ProgressionSku
update a
set a.FRDEntity = b.firstreceiptdate
from Fact_StockProgressionSku a
left join Dim_ItemMaster b
    on a.Company=b.COMPANY and a.Sku=b.ITEMNUMBER
where a.FinYear1 = '2024-25'
    and a.Month in ('feb','mar','apr','may','jun')
    and (a.FRDEntity is null or a.FRDEntity = '')