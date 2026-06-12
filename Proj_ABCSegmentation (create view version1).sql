USE [AxDW]
GO

/****** Object:  View [dbo].[View_BI_ABCFlags]    Script Date: 12/06/2026 17:24:53 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO



CREATE VIEW [dbo].[View_BI_ABCFlags]
AS

-- CTE last 90D sales, exclude New Items

WITH Sales_Agg AS (
    SELECT 
        a.Company, 
        a.SubClass, 
        a.Brand, 
        a.Itemid, 
        a.Description,
        SUM(a.qty) AS QtySold, 
        SUM(a.sales$) AS Sales, 
        SUM(a.margin$) AS Margin
    FROM salesconsol a
    WHERE a.date BETWEEN DATEADD(DAY, -90, CAST(GETDATE()-1 AS DATE)) 
                     AND CAST(GETDATE()-1 AS DATE)
        AND a.stype IN ('normal purchase','purchase foreign','consignment')
    GROUP BY 
        a.Company, a.SubClass, a.Brand, a.Itemid, a.Description
),

-- Ranking Stage
RankingStage AS (
    SELECT 
        Company, SubClass, Brand, ItemID, Description,
        QtySold, Sales, Margin,

        RANK() OVER (
            PARTITION BY Company, SubClass, Brand
            ORDER BY Sales DESC
        ) AS SalesRank,

        RANK() OVER (
            PARTITION BY Company, SubClass, Brand
            ORDER BY Margin DESC
        ) AS MarginRank,

        (
            (RANK() OVER (
                PARTITION BY Company, SubClass, Brand
                ORDER BY Sales DESC
            ) * 0.40) 
            +
            (RANK() OVER (
                PARTITION BY Company, SubClass, Brand
                ORDER BY Margin DESC
            ) * 0.60)
        ) AS FinalBase

    FROM Sales_Agg
),

-- Final Rank
SalesRank_Agg AS (
    SELECT *,
        RANK() OVER (
            PARTITION BY Company, SubClass, Brand
            ORDER BY FinalBase ASC
        ) AS FinalRank
    FROM RankingStage
),

-- Max Rank
MaxRankCalc AS (
    SELECT *,
        MAX(FinalRank) OVER (
            PARTITION BY Company, SubClass, Brand
        ) AS MaxRank
    FROM SalesRank_Agg
)

-- Final Output
SELECT 
    *,
    CAST(
        CAST(FinalRank AS DECIMAL(10,4)) /
        NULLIF(MaxRank, 0)
    AS DECIMAL(10,4)) AS Pct_Total,

    CASE 
        WHEN CAST(FinalRank AS DECIMAL(10,4)) / NULLIF(MaxRank, 0) <= 0.4 THEN 'A'
        WHEN CAST(FinalRank AS DECIMAL(10,4)) / NULLIF(MaxRank, 0) <= 0.8 THEN 'B'
        ELSE 'C'
    END AS ABC

FROM MaxRankCalc;
GO


