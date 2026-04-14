USE [AxDW]
GO

/****** Object:  View [dbo].[View_BI_Attachment]    Script Date: 14-Apr-2026 10:26:58 AM ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



/*
Purpose :   provide data output to be utilized for Attachment Report in BI
Logic   :

            1- create CTE base data using TransConsol
            2-  a. create CTE for distinct TransID's pertaining to 'Principal' Categories
                b. create CTE for distinct TransID's pertaining to 'Attachment' Categories
            3- create a IsAttachment flag using this logic, where TransID and GROUP matches.
                a. WHEN c.[type_code] = 'P' AND b.[type_code] = 'A'    THEN '1- Attachment Transaction'	
                b. WHEN c.[type_code] = 'P' AND b.[type_code] IS NULL  THEN '2- MISSED opportunity'	
                c. WHEN c.[type_code] IS NULL AND b.[type_code] = 'A'  THEN '3- Attachment Only'
File Dependencies :
            1- Fact_TransConsol
            2- Dim_AttachmentPrincipal
Created :   ronaldn/mar2026
*/

ALTER VIEW [dbo].[View_BI_Attachment]
AS
WITH TransCons_Agg AS (		 
    SELECT 
        a.FinYear1, a.Date,a.Month,a.WeekNo, a.Company, a.StoreNo,a.StoreName, a.ItemId, a.Description, 
        a.Dept2, a.Department, a.SubDepartment, a.Class, a.SubClass,a.Brand, a.TransID,a.Supplier,a.SupplierName,

        b.[GROUP], b.[TYPE_CODE],
        SUM(a.Qty) AS QtySold, 
        SUM(a.Sales$) AS Sales$, 
		SUM(a.Cost$) AS Cost$,
        SUM(a.Sales$ - Cost$) AS Margin$

    FROM Fact_TransConsol a	
    LEFT JOIN Dim_AttachmentPrincipal b	
        ON a.SubClass = b.SUB_CLASS_NAME
    WHERE a.DATE >= '2025-02-01' 	 
        AND a.stype NOT IN ('','Concession','Service','Ticketing')	
		and b.[GROUP] <> 'J'
    GROUP BY 
        a.FinYear1, a.Date,a.Month,a.WeekNo, a.Company, a.StoreNo,a.StoreName, a.ItemId, a.Description, 
        a.Dept2, a.Department, a.SubDepartment, a.Class, a.SubClass,a.Brand, a.TransID,a.Supplier,a.SupplierName,
        b.[GROUP], b.[TYPE_CODE]
),		

Type_A_Agg AS (		
    SELECT DISTINCT TransId, [GROUP], [TYPE_CODE]	
    FROM TransCons_Agg	
    WHERE [TYPE_CODE] = 'A'	
),		

Type_P_Agg AS (	
    SELECT DISTINCT TransId, [GROUP], [TYPE_CODE]	
    FROM TransCons_Agg	
    WHERE [TYPE_CODE] = 'P'	
)		

SELECT 
   a.FinYear1,
   a.Date,
   a.Month,
   a.WeekNo,
   a.Company,
   a.StoreNo,
   a.StoreName,
   a.ItemId,
   a.Description,
   a.Dept2,
   a.Department,
   a.SubDepartment,
   a.Class,
   a.SubClass,
   a.Brand,
   a.TransID,
   a.Supplier,
   a.SupplierName,
   a.[GROUP],
    a.[TYPE_CODE],		
    c.[type_code] AS Type_Code_P, 
    b.[type_code] AS Type_Code_A,	
    CASE 	
        WHEN c.[type_code] = 'P' AND b.[type_code] = 'A' THEN '1- Attachment Transaction'	
        WHEN c.[type_code] = 'P' AND (b.[type_code] IS NULL or b.[type_code] = '') THEN '2- MISSED opportunity'	
        WHEN c.[type_code] IS NULL AND b.[type_code] = 'A' THEN '3- Attachment Only'	
        ELSE 'Non Attachment Trans'	
    END AS FLAG,	
    SUM(a.QtySold) AS QtySold,	
    SUM(a.Sales$) AS Sales$,	
	SUM(a.Cost$) AS Cost$,
    SUM(a.Margin$) AS Margin$,
	d.StoreType
FROM TransCons_Agg a	
LEFT JOIN Type_A_Agg b	
    ON a.TransId = b.TransId AND a.[GROUP] = b.[GROUP]
LEFT JOIN Type_P_Agg c	
    ON a.TransId = c.TransId AND a.[GROUP] = c.[GROUP]
LEFT JOIN Dim_StoreName d
    ON a.Company = d.Company AND a.StoreNo = d.Store
--WHERE a.[GROUP] = 'D'	
GROUP BY 
    a.FinYear1,a.Date,a.Month,a.WeekNo,a.Company,a.StoreNo,a.StoreName,a.ItemId,
   a.Description,a.Dept2,a.Department,a.SubDepartment,a.Class,a.SubClass,a.Brand,a.TransID,
   a.Supplier,a.SupplierName, a.[GROUP], a.[TYPE_CODE],c.[type_code], b.[type_code],d.StoreType ;



GO


