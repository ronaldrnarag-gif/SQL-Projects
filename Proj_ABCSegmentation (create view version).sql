CREATE VIEW dbo.vw_ABC_Segmentation
AS
WITH sales_90d AS (
    SELECT
        Company,
        SubClass,
        Brand,
        ItemID,
        Description,
        SUM(qty)       AS QtySold,
        SUM(sales$)    AS Sales,
        SUM(margin$)   AS Margin
    FROM salesconsol
    WHERE [date] >= DATEADD(day, -90, CAST(GETDATE() - 1 AS date))
      AND [date] <  CAST(GETDATE() AS date)
      AND stype IN ('normal purchase','purchase foreign','consignment')
    GROUP BY
        Company, SubClass, Brand, ItemID, Description
),

rank_sales_margin AS (
    SELECT
        Company,
        SubClass,
        Brand,
        ItemID,
        Description,
        QtySold,
        Sales,
        Margin,
        RANK() OVER (
            PARTITION BY Company, SubClass, Brand
            ORDER BY Sales DESC
        ) AS SalesRank,
        RANK() OVER (
            PARTITION BY Company, SubClass, Brand
            ORDER BY Margin DESC
        ) AS MarginRank
    FROM sales_90d
),

final_base AS (
    SELECT
        *,
        (SalesRank * 0.40 + MarginRank * 0.60) AS FinalBase
    FROM rank_sales_margin
),

final_rank AS (
    SELECT
        *,
        RANK() OVER (
            PARTITION BY Company, SubClass, Brand
            ORDER BY FinalBase
        ) AS FinalRank,
        COUNT(*) OVER (
            PARTITION BY Company, SubClass, Brand
        ) AS TotalSkus
    FROM final_base
)

SELECT
    Company,
    SubClass,
    Brand,
    ItemID,
    Description,
    QtySold,
    Sales,
    Margin,
    SalesRank,
    MarginRank,
    FinalBase,
    FinalRank,
    CAST(FinalRank * 1.0 / NULLIF(TotalSkus, 0) AS decimal(10,4)) AS Pct_Total,
    CASE
        WHEN FinalRank * 1.0 / NULLIF(TotalSkus, 0) <= 0.40 THEN 'A'
        WHEN FinalRank * 1.0 / NULLIF(TotalSkus, 0) <= 0.80 THEN 'B'
        ELSE 'C'
    END AS ABC
FROM final_rank
WHERE Company = 'bah';