
/*

    Fixes needed on FRD in the database to be able to build ABC Segmentation flag in multiple database tables
        MLSS, Open PO, GRN, etc

*/

-- Step 1 : Create FRD View in BYOD 

    ALTER VIEW [dbo].[VW_FirstReceiptDate] as (
	    SELECT COMPANY, ITEMID, MIN(isnull(DATEPHYSICAL,'')) FIRSTRECEIPTDATE
	    FROM LTInventTransDataStaging 
	    WHERE DATEPHYSICAL > '1900-01-01 00:00:00.000' 
		    and QTY > 0
	    group by COMPANY, ITEMID
	    );
    GO

-- Step 2: Create Table in Local Server 

    CREATE TABLE Dim_FirstReceiptDate 
    (
        COMPANY             VARCHAR(10),
        ITEMID              NVARCHAR(25),
        FIRSTRECEIPTDATE    DATE
        )


-- Step 3: Write an SP to Populate Local FRD Table

    Truncate TABLE Dim_FirstReceiptDate

    INSERT INTO Dim_FirstReceiptDate (COMPANY, ITEMID, FIRSTRECEIPTDATE)
    SELECT *
    FROM OPENQUERY(AZUREDB,
    '
        SELECT *
        FROM dbo.VW_FirstReceiptDate
    ');

-- Step 4: Using Local FRD Table Left join to Dim_ItemMaster and populate FIRSTRECEIPTDATE field

    update im
    set im.firstreceiptdate = fr.firstreceiptdate
    from Dim_ItemMaster im
    left join Dim_FirstReceiptDate fr
        on im.company=fr.company and im.itemnumber=fr.itemid

    -- ItemMaster Validation, this should result to blank.

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
    
    -- validation script 2
        with stock_agg as (
	    select company, sku, sum(total_stk_qty) qtyoh
	    from vw_stockageing
	    group by company, sku
	    )
        select a.firstreceiptdate, a.company,a.itemnumber, b.qtyoh,a.*,b.*
        from Dim_ItemMaster a
        left join stock_agg b
	        on a.COMPANY=b.Company and a.ITEMNUMBER=b.Sku
        where firstreceiptdate is null 
        order by b.qtyoh desc

-- Step 5: Update missing FRD's in ProgressionSku (july 2024 and before)
    
    update a
    set a.FRDEntity = b.firstreceiptdate
    from Fact_StockProgressionSku a
    left join Dim_ItemMaster b
        on a.Company=b.COMPANY and a.Sku=b.ITEMNUMBER
    where a.FinYear1 = '2024-25'
        and a.Month in ('feb','mar','apr','may','jun')
        and (a.FRDEntity is null or a.FRDEntity = '')


Step 7: BUILD ABC in Dim_ItemMaster, 
        logic is to left join with 'View_ABCFlag', then run 'Newness' based on newly added FRD Column, then rest to flag as 'No Sales'

