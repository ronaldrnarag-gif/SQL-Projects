
SELECT COUNT(*)
FROM [AZUREDB].[AxDW].[dbo].[ApntSCRLinesStaging]
where DATAAREAID = 'UAE'
AND WAREHOUSE = '416';

-- copy table from azure server, dumps it into entirely new table in the on-premise
SELECT *
INTO Temp_SCRUAE_ForAuditors
FROM [AZUREDB].[AxDW].[dbo].[ApntSCRLinesStaging]
where DATAAREAID = 'UAE'
AND WAREHOUSE = '416';

-- remove unnecessary columns
ALTER TABLE Temp_SCRUAE_ForAuditors
DROP COLUMN FROMDATE, TODATE