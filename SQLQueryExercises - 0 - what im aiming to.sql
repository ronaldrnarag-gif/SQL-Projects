SELECT     A.ENTRYSTATUS, A. 'INVENTLOCATIONID', A.ITEMID, A.ITEMNAME, A. 'INVOICEDATE', A.ITEMGROUPNAME, A.SALESID, A.BRAND, A.VENDORID, A.DEPARTMENT, 
                      A.SUBDEPARTMENT, A.CLASS, A.SUBCLASS, A.PRODUCTTYPE, A.QTY, A.LINEAMOUNT, A.PRICE, CASE WHEN A.UNITPRICE = 0 THEN ABS(B.PRICEINVENT) 
                      ELSE ABS(UNITPRICE) END AS UNITPRICE, CASE WHEN COSTPRICE = 0 THEN (B.PRICEINVENT * - 1) * QTY ELSE COSTPRICE END AS COSTPRICE, A.DISCAMOUNT, 
                      A.TAXAMOUNT, A.CLAIMAMOUNT, A.COMPANY
FROM         (SELECT     'POSTED' AS ENTRYSTATUS, 'INVENTLOCATIONID', ITEMID, ITEMNAME, PRODUCTTYPE, SALESID, ITEMGROUPNAME, BRAND, VENDORID, 
                                              'INVOICEDATE', DEPARTMENT, SUBDEPARTMENT, CLASS, SUBCLASS, PRICE, 'UNITPRICE', 'UNITPRICE' * SUM('QTY') AS 'COSTPRICE', SUM('QTY') 
                                              AS QTY, SUM('LINEAMOUNT') AS LINEAMOUNT, SUM('DISCAMOUNT') AS DISCAMOUNT, SUM('TAXAMOUNT') AS TAXAMOUNT, SUM('CLAIMAMOUNT') 
                                              AS CLAIMAMOUNT, COMPANY
                       FROM          (SELECT     A.ITEMID, A.COMPANY, B.PRODUCTNAME AS 'ITEMNAME', B.ITEMGROUPNAME, B.BRAND, B.PRIMARYVENDORID AS 'VENDORID', 
                                                                      B.LTCATEGORY1 AS 'DEPARTMENT', B.LTCATEGORY2 AS 'SUBDEPARTMENT', B.LTCATEGORY3 AS 'CLASS', B.LTCATEGORY4 AS 'SUBCLASS',
                                                                       CASE WHEN PRODUCTTYPE = 1 THEN 'ITEM' WHEN PRODUCTTYPE = 2 THEN 'SERVICE' END AS PRODUCTTYPE, A.SALESID, 
                                                                      ISNULL(CONVERT(DATE, A.INVOICEDATE), N'') AS 'INVOICEDATE', ISNULL(A.INVENTLOCATIONID, N'') AS 'INVENTLOCATIONID', 
                                                                      CASE WHEN PRODUCTSUBTYPE = 2 AND F.RELATION = 4 THEN F.AMOUNT ELSE PRICE END AS PRICE, ISNULL(SUM(A.QTY), 0) AS 'QTY', 
                                                                      ISNULL(SUM(A.LINEAMOUNT), 0) AS 'LINEAMOUNT', ISNULL(D. 'UNITPRICE' * - 1, 0) AS 'UNITPRICE', ISNULL(SUM(A.LINEAMOUNTTAXMST), 0) 
                                                                      AS 'TAXAMOUNT', ISNULL(SUM(A.DISCAMOUNT), 0) AS 'DISCAMOUNT', ISNULL(SUM(A.LTCLAIMAMOUNT), 0) AS 'CLAIMAMOUNT'
                                               FROM          dbo.LTCustInvoiceJourDEStaging AS A LEFT OUTER JOIN
                                                                      dbo.LTInventoryDataStaging AS B ON A.ITEMID = B.ITEMNUMBER AND A.COMPANY = B.COMPANY LEFT OUTER JOIN
                                                                      dbo.VW_VendorMaster AS C ON B.PRIMARYVENDORID = C.VENDORID LEFT OUTER JOIN
                                                                          (SELECT     ITEMID, INVENTTRANSID, COMPANY, SUM(QTY) AS QTY, SUM(COSTPRICE) AS COSTPRICE, SUM(COSTPRICE) 
                                                                                                   / NULLIF (SUM(QTY), 0) AS 'UNITPRICE'
                                                                            FROM          (SELECT     INVENTLOCATIONID, ITEMID, INVENTTRANSID, REFERENCEID, DATEPHYSICAL, COMPANY, REFERENCECATEGORY, 
                                                                                                                           STATUSISSUE, STATUSRECEIPT, QTY, 
                                                                                                                           CASE WHEN COSTAMOUNTPOSTED = 0 THEN COSTAMOUNTPHYSICAL ELSE COSTAMOUNTPOSTED END AS COSTPRICE
                                                                                                    FROM          dbo.LTInventTransDataStaging) AS A
                                                                            WHERE      (REFERENCECATEGORY = '0') AND (STATUSISSUE = '1' OR
                                                                                                   STATUSISSUE = '2') OR
                                                                                                   (REFERENCECATEGORY = '0') AND (STATUSRECEIPT = '1') OR
                                                                                                   (REFERENCECATEGORY = '0') AND (STATUSRECEIPT = '2')
                                                                            GROUP BY ITEMID, INVENTTRANSID, COMPANY) AS D ON A.INVENTTRANSID = D.INVENTTRANSID AND 
                                                                      A.COMPANY = D.COMPANY LEFT OUTER JOIN
                                                                          (SELECT     RELATION, ITEMRELATION AS 'ITEMID', COMPANY, MIN(AMOUNT) AS AMOUNT
                                                                            FROM          dbo.LTItemPriceTableDataStaging
                                                                            WHERE      (ACCOUNTRELATION <> '') AND (ITEMRELATION <> '') AND (TODATE = '') AND (RELATION = '4')
                                                                            GROUP BY ITEMRELATION, COMPANY, RELATION) AS F ON B.ITEMNUMBER = F. 'ITEMID' AND B.COMPANY = F.COMPANY
                                               WHERE      (A.SALESID NOT IN
                                                                          (SELECT DISTINCT SALESORDERID
                                                                            FROM          (SELECT DISTINCT SALESORDERID, TYPE
                                                                                                    FROM          dbo.LTRetailTransDataStaging
                                                                                                    WHERE      (TYPE <> '19')) AS A))
                                               GROUP BY A.ITEMID, A.COMPANY, B.PRODUCTNAME, B.ITEMGROUPNAME, B.BRAND, B.PRIMARYVENDORID, B.LTCATEGORY1, B.LTCATEGORY2, 
                                                                      B.LTCATEGORY3, B.LTCATEGORY4, B.PRODUCTTYPE, A.INVOICEDATE, A.INVENTLOCATIONID, D. 'UNITPRICE', B.PRICE, 
                                                                      B.PRODUCTSUBTYPE, A.SALESID, F.RELATION, F.AMOUNT) AS A
                       WHERE      ('QTY' <> 0) AND ('LINEAMOUNT' <> 0)
                       GROUP BY 'INVENTLOCATIONID', ITEMID, 'ITEMNAME', ITEMGROUPNAME, 'INVOICEDATE', 'DEPARTMENT', PRODUCTTYPE, 'SUBDEPARTMENT', 'CLASS', 
                                              'SUBCLASS', PRICE, 'UNITPRICE', BRAND, 'VENDORID', SALESID, COMPANY
                       UNION
                       SELECT     'ENTRYSTATUS', 'INVENTLOCATIONID', ITEMID, ITEMNAME, PRODUCTTYPE, SALESORDERID, ITEMGROUPNAME, BRAND, VENDORID, 'BUSINESSDATE', 
                                             DEPARTMENT, SUBDEPARTMENT, CLASS, SUBCLASS, PRICE, 'UNITPRICE', 'UNITPRICE' * SUM('QTY') AS 'COSTPRICE', SUM('QTY') AS QTY, 
                                             SUM('NETAMOUNT') AS NETAMOUNT, SUM('DISCAMOUNT') AS DISCAMOUNT, SUM('TAXAMOUNT') AS TAXAMOUNT, SUM('CLAIMAMOUNT') 
                                             AS CLAIMAMOUNT, COMPANY
                       FROM         (SELECT     A.ITEMID, A.COMPANY, B.ITEMGROUPNAME, B.PRODUCTNAME AS 'ITEMNAME', B.BRAND, B.PRIMARYVENDORID AS 'VENDORID', 
                                                                     B.LTCATEGORY1 AS 'DEPARTMENT', B.LTCATEGORY2 AS 'SUBDEPARTMENT', B.LTCATEGORY3 AS 'CLASS', B.LTCATEGORY4 AS 'SUBCLASS', 
                                                                     CASE WHEN PRODUCTTYPE = 1 THEN 'ITEM' WHEN PRODUCTTYPE = 2 THEN 'SERVICE' END AS PRODUCTTYPE, A.SALESORDERID, 
                                                                     CASE WHEN PRODUCTSUBTYPE = 2 AND F.RELATION = 4 THEN F.AMOUNT ELSE PRICE END AS PRICE, E.AMOUNT, E.RELATION, 
                                                                     CASE WHEN ENTRYSTATUS = 0 THEN 'None' WHEN ENTRYSTATUS = 1 THEN 'Voided' WHEN ENTRYSTATUS = 2 THEN 'Posted' WHEN ENTRYSTATUS
                                                                      = 3 THEN 'Concluded' WHEN ENTRYSTATUS = 4 THEN 'Cancelled' WHEN ENTRYSTATUS = 5 THEN 'OnHold' WHEN ENTRYSTATUS = 6 THEN 'Training'
                                                                      WHEN ENTRYSTATUS = 7 THEN 'PendingInvoice' WHEN ENTRYSTATUS = 8 THEN 'CreatingOrder' END AS 'ENTRYSTATUS', CONVERT(DATE, 
                                                                     A.BUSINESSDATE) AS 'BUSINESSDATE', ISNULL(A.INVENTLOCATIONID, N'') AS 'INVENTLOCATIONID', CONVERT(NUMERIC(18, 2), 
                                                                     ISNULL(SUM(A.QTY * - 1), 0)) AS 'QTY', CASE WHEN PAYMENTAMOUNT = 0 THEN 0 ELSE CONVERT(NUMERIC(18, 2), SUM(NETAMOUNT * - 1)) 
                                                                     END AS 'NETAMOUNT', CONVERT(NUMERIC(18, 2), ISNULL(D. 'UNITPRICE' * - 1, 0)) AS 'UNITPRICE', 
                                                                     CASE WHEN PAYMENTAMOUNT = 0 THEN 0 ELSE ISNULL(SUM(TAXAMOUNT * - 1), 0) END AS 'TAXAMOUNT', SUM(A.NETAMOUNTINCLTAX) 
                                                                     - ISNULL(SUM(A.COSTAMOUNT), 0) * SUM(A.QTY * - 1) AS 'CONTRIBUTIONMARGIN', SUM(A.DISCAMOUNT) AS 'DISCAMOUNT', 
                                                                     SUM(A.LTCLAIMAMOUNT) AS 'CLAIMAMOUNT'
                                              FROM          dbo.LTRetailTransDataStaging AS A LEFT OUTER JOIN
                                                                     dbo.LTInventoryDataStaging AS B ON A.ITEMID = B.ITEMNUMBER AND A.COMPANY = B.COMPANY LEFT OUTER JOIN
                                                                         (SELECT     INVENTLOCATIONID, ITEMID, REFERENCEID, DATEPHYSICAL, COMPANY, SUM(QTY) AS QTY, SUM(COSTPRICE) AS COSTPRICE, 
                                                                                                  SUM(COSTPRICE) / NULLIF (SUM(QTY), 0) AS 'UNITPRICE'
                                                                           FROM          (SELECT     INVENTLOCATIONID, ITEMID, REFERENCEID, DATEPHYSICAL, COMPANY, QTY, 
                                                                                                                          CASE WHEN COSTAMOUNTPOSTED = 0 THEN COSTAMOUNTPHYSICAL ELSE COSTAMOUNTPOSTED END AS COSTPRICE
                                                                                                   FROM          dbo.LTInventTransDataStaging) AS A
                                                                           GROUP BY INVENTLOCATIONID, ITEMID, REFERENCEID, DATEPHYSICAL, COMPANY) AS D ON A.SALESORDERID = D.REFERENCEID AND 
                                                                     A.COMPANY = D.COMPANY AND A.ITEMID = D.ITEMID LEFT OUTER JOIN
                                                                         (SELECT     ACCOUNTRELATION AS 'VENDORID', RELATION, ITEMRELATION AS 'ITEMID', COMPANY, MIN(AMOUNT) AS AMOUNT
                                                                           FROM          dbo.LTItemPriceTableDataStaging AS A
                                                                           WHERE      (ACCOUNTRELATION <> '') AND (ITEMRELATION <> '') AND (TODATE = '') AND (RELATION = 0)
                                                                           GROUP BY ACCOUNTRELATION, RELATION, ITEMRELATION, COMPANY) AS E ON B.ITEMNUMBER = E. 'ITEMID' AND 
                                                                     B.PRIMARYVENDORID = E. 'VENDORID' AND B.COMPANY = E.COMPANY LEFT OUTER JOIN
                                                                         (SELECT     RELATION, ITEMRELATION AS 'ITEMID', COMPANY, MIN(AMOUNT) AS AMOUNT
                                                                           FROM          dbo.LTItemPriceTableDataStaging
                                                                           WHERE      (ACCOUNTRELATION <> '') AND (ITEMRELATION <> '') AND (TODATE = '') AND (RELATION = '4')
                                                                           GROUP BY ITEMRELATION, COMPANY, RELATION) AS F ON B.ITEMNUMBER = F. 'ITEMID' AND B.COMPANY = F.COMPANY
                                              WHERE      (A.TYPE NOT IN ('36', '19'))
                                              GROUP BY A.BUSINESSDATE, A.INVENTLOCATIONID, A.ITEMID, D. 'UNITPRICE', A.PAYMENTAMOUNT, A.COMPANY, B.PRODUCTTYPE, 
                                                                     B.ITEMGROUPNAME, B.PRODUCTNAME, B.PRICE, B.LTCATEGORY1, B.LTCATEGORY2, B.LTCATEGORY3, B.LTCATEGORY4, B.BRAND, 
                                                                     B.PRIMARYVENDORID, B.PRODUCTSUBTYPE, A.SALESORDERID, A.ENTRYSTATUS, F.RELATION, F.AMOUNT, E.AMOUNT, E.RELATION) 
                                             AS A
                       WHERE     ('ENTRYSTATUS' <> 'None')
                       GROUP BY 'ENTRYSTATUS', 'INVENTLOCATIONID', ITEMID, 'ITEMNAME', PRODUCTTYPE, SALESORDERID, ITEMGROUPNAME, BRAND, 'VENDORID', 
                                             'BUSINESSDATE', 'DEPARTMENT', 'SUBDEPARTMENT', 'CLASS', 'SUBCLASS', PRICE, 'UNITPRICE', COMPANY
                       UNION
                       SELECT     'ENTRYSTATUS', 'INVENTLOCATIONID', ITEMID, ITEMNAME, PRODUCTTYPE, SALESORDERID, ITEMGROUPNAME, BRAND, VENDORID, 'BUSINESSDATE', 
                                             DEPARTMENT, SUBDEPARTMENT, CLASS, SUBCLASS, PRICE, 'UNITPRICE', 'UNITPRICE' * SUM('QTY') AS 'COSTPRICE', SUM('QTY') AS QTY, 
                                             SUM('NETAMOUNT') AS NETAMOUNT, SUM('DISCAMOUNT') AS DISCAMOUNT, SUM('TAXAMOUNT') AS TAXAMOUNT, SUM('CLAIMAMOUNT') 
                                             AS CLAIMAMOUNT, COMPANY
                       FROM         (SELECT     A.ITEMID, A.COMPANY, B.ITEMGROUPNAME, B.PRODUCTNAME AS 'ITEMNAME', B.BRAND, B.PRIMARYVENDORID AS 'VENDORID', 
                                                                     B.LTCATEGORY1 AS 'DEPARTMENT', B.LTCATEGORY2 AS 'SUBDEPARTMENT', B.LTCATEGORY3 AS 'CLASS', B.LTCATEGORY4 AS 'SUBCLASS', 
                                                                     CASE WHEN PRODUCTTYPE = 1 THEN 'ITEM' WHEN PRODUCTTYPE = 2 THEN 'SERVICE' END AS PRODUCTTYPE, A.SALESORDERID, 
                                                                     CASE WHEN PRODUCTSUBTYPE = 2 AND F.RELATION = 4 THEN F.AMOUNT ELSE PRICE END AS PRICE, E.AMOUNT, E.RELATION, 
                                                                     CASE WHEN ENTRYSTATUS = 0 THEN 'None' WHEN ENTRYSTATUS = 1 THEN 'Voided' WHEN ENTRYSTATUS = 2 THEN 'Posted' WHEN ENTRYSTATUS
                                                                      = 3 THEN 'Concluded' WHEN ENTRYSTATUS = 4 THEN 'Cancelled' WHEN ENTRYSTATUS = 5 THEN 'OnHold' WHEN ENTRYSTATUS = 6 THEN 'Training'
                                                                      WHEN ENTRYSTATUS = 7 THEN 'PendingInvoice' WHEN ENTRYSTATUS = 8 THEN 'CreatingOrder' END AS 'ENTRYSTATUS', CONVERT(DATE, 
                                                                     A.BUSINESSDATE) AS 'BUSINESSDATE', ISNULL(A.INVENTLOCATIONID, N'') AS 'INVENTLOCATIONID', CONVERT(NUMERIC(18, 2), 
                                                                     ISNULL(SUM(A.QTY * - 1), 0)) AS 'QTY', CASE WHEN PAYMENTAMOUNT = 0 THEN 0 ELSE CONVERT(NUMERIC(18, 2), SUM(NETAMOUNT * - 1)) 
                                                                     END AS 'NETAMOUNT', CONVERT(NUMERIC(18, 2), ISNULL(E.AMOUNT * - 1, 0)) AS 'UNITPRICE', 
                                                                     CASE WHEN PAYMENTAMOUNT = 0 THEN 0 ELSE ISNULL(SUM(TAXAMOUNT * - 1), 0) END AS 'TAXAMOUNT', SUM(A.NETAMOUNTINCLTAX) 
                                                                     - ISNULL(SUM(A.COSTAMOUNT), 0) * SUM(A.QTY * - 1) AS 'CONTRIBUTIONMARGIN', SUM(A.DISCAMOUNT) AS 'DISCAMOUNT', 
                                                                     SUM(A.LTCLAIMAMOUNT) AS 'CLAIMAMOUNT'
                                              FROM          dbo.LTRetailTransDataStaging AS A LEFT OUTER JOIN
                                                                     dbo.LTInventoryDataStaging AS B ON A.ITEMID = B.ITEMNUMBER AND A.COMPANY = B.COMPANY LEFT OUTER JOIN
                                                                         (SELECT     ACCOUNTRELATION AS 'VENDORID', RELATION, ITEMRELATION AS 'ITEMID', COMPANY, MIN(AMOUNT) AS AMOUNT
                                                                           FROM          dbo.LTItemPriceTableDataStaging AS A
                                                                           WHERE      (ACCOUNTRELATION <> '') AND (ITEMRELATION <> '') AND (TODATE = '') AND (RELATION = 0)
                                                                           GROUP BY ACCOUNTRELATION, RELATION, ITEMRELATION, COMPANY) AS E ON B.ITEMNUMBER = E. 'ITEMID' AND 
                                                                     B.PRIMARYVENDORID = E. 'VENDORID' AND B.COMPANY = E.COMPANY LEFT OUTER JOIN
                                                                         (SELECT     RELATION, ITEMRELATION AS 'ITEMID', COMPANY, MIN(AMOUNT) AS AMOUNT
                                                                           FROM          dbo.LTItemPriceTableDataStaging
                                                                           WHERE      (ACCOUNTRELATION <> '') AND (ITEMRELATION <> '') AND (TODATE = '') AND (RELATION = '4')
                                                                           GROUP BY ITEMRELATION, COMPANY, RELATION) AS F ON B.ITEMNUMBER = F. 'ITEMID' AND B.COMPANY = F.COMPANY
                                              WHERE      (A.TYPE NOT IN ('36', '19'))
                                              GROUP BY A.BUSINESSDATE, A.INVENTLOCATIONID, A.ITEMID, E.AMOUNT, A.PAYMENTAMOUNT, A.COMPANY, B.PRODUCTTYPE, B.ITEMGROUPNAME, 
                                                                     B.PRODUCTNAME, B.PRICE, B.LTCATEGORY1, B.LTCATEGORY2, B.LTCATEGORY3, B.LTCATEGORY4, B.BRAND, B.PRIMARYVENDORID, 
                                                                     B.PRODUCTSUBTYPE, A.SALESORDERID, A.ENTRYSTATUS, F.RELATION, F.AMOUNT, E.AMOUNT, E.RELATION) AS A
                       WHERE     ('ENTRYSTATUS' = 'None')
                       GROUP BY 'ENTRYSTATUS', 'INVENTLOCATIONID', ITEMID, 'ITEMNAME', PRODUCTTYPE, SALESORDERID, ITEMGROUPNAME, BRAND, 'VENDORID', 
                                             'BUSINESSDATE', 'DEPARTMENT', 'SUBDEPARTMENT', 'CLASS', 'SUBCLASS', PRICE, 'UNITPRICE', COMPANY) AS A LEFT OUTER JOIN
                      dbo.LTInventoryDataStaging AS B ON A.ITEMID = B.ITEMNUMBER AND A.COMPANY = B.COMPANY