/*
Purpose         :   Fill in Missing family/subfamily descriptions in OtherLSBrands Sales table
Logic           :   left join company and Family/Subfamily Code with master table
                        where DRRT = FM for family and SF for subfamily.
Dependencies    :
                    [SQLCONS].[PS_DEVCONS].[dbo].[vTransactions_Lifestyle] -- Sales Table
                    [SQLCONS].[PS_DEVCONS].[dbo].[vUDCs_Lifestyle] -- Family/Subfamily master table
Created         :   ronaldn/20260424
*/

-- update FAMILY Description

SELECT a.STRP01 AS Company, a.STSEG1 as [Family Code], b.DRDL01 as [Family]
FROM [SQLCONS].[PS_DEVCONS].[dbo].[vTransactions_Lifestyle] a
LEFT JOIN [SQLCONS].[PS_DEVCONS].[dbo].[vUDCs_Lifestyle] b
    ON a.STRP01=b.DRRP01 and a.STSEG1=LTRIM(RTRIM(b.DRKY))
WHERE b.DRSY = '55' and b.DRRT = 'FM'
GROUP BY a.STRP01, a.STSEG1, b.DRDL01
ORDER BY 1,2


-- update SUB-FAMILY Description

SELECT a.STRP01 AS Company, a.STSEG1 as [Family Code], b.DRDL01 as [SubFamily]
FROM [SQLCONS].[PS_DEVCONS].[dbo].[vTransactions_Lifestyle] a
LEFT JOIN [SQLCONS].[PS_DEVCONS].[dbo].[vUDCs_Lifestyle] b
    ON a.STRP01=b.DRRP01 and a.STSEG2=LTRIM(RTRIM(b.DRKY))
WHERE b.DRSY = '55' and b.DRRT = 'SF'
GROUP BY a.STRP01, a.STSEG1, b.DRDL01
ORDER BY 1,2

    