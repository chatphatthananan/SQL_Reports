USE EvoProd

GO

--sp_getcharinfo 348

/*

select top 100 * from EvoProdSingKPI.dbo.HouseholdUsageSG_Export

select top 100 * from tStation

*/
IF OBJECT_ID('tempdb..#smartHomes') IS NOT NULL
BEGIN
    DROP TABLE #smartHomes
END

IF OBJECT_ID('tempdb..#tempUsg') IS NOT NULL
BEGIN
    DROP TABLE #tempUsg
END
--============================================================================================================================================================================================-------

DECLARE @refDate AS DATE = '2023-03-08'

-- This part to get HhID, SmartTV yes or no
SELECT a.HhID
	  ,CASE WHEN ISNULL(c348.CharValue,'-1') = '1' AND ISNULL(c349.CharValue,'-1') = '1' THEN 1 ELSE 0 END AS SmartTVHHWithInternet
	  ,CASE WHEN ISNULL(c348.CharValue,'-1') = '1' THEN 1 ELSE 0 END AS SmartTVHH
INTO #smartHomes
FROM FUGetInstalledHouseHold (@refDate) a
INNER JOIN tInstDom b ON a.hhid =b.HhID AND @refDate BETWEEN b.ActiveFrom AND b.ActiveUntil 
INNER JOIN tInst c on c.InstDomID = b.InstDomID AND @refDate BETWEEN c.ActiveFrom AND c.ActiveUntil
INNER JOIN tMedDevInst d ON c.InstID = d.InstID AND @refDate BETWEEN d.ActiveFrom AND d.ActiveUntil
INNER JOIN tMedDev e ON e.MedDevID = d.MedDevID AND e.MedDevType = 1 AND @refDate BETWEEN e.PartOfHhFrom AND e.PartOfHhUntil
LEFT JOIN FUGetCharValHistDetails(@refDate,348) c348 ON d.MedDevID = c348.RefEntityID --AND c348.CharValue = '1'
LEFT JOIN FUGetCharValHistDetails(@refDate,349) c349 ON d.MedDevID = c349.RefEntityID --AND c349.CharValue = '1'
WHERE a.HhID NOT IN (55122)

SELECT usg.HouseholdID
	,usg.StationID
	,(SELECT TOP 1 tst.CurrentStationName FROM tStation tst WHERE usg.StationID = tst.StationID) AS CurrentStationName
	,SUM(usg.durationSec) AS DurationSec
INTO #tempUsg
FROM EvoProdSingKPI.dbo.HouseholdUsageSG_Export usg
WHERE usg.Date BETWEEN '2023-02-27' AND '2023-03-05' 
	AND usg.HouseholdID>=10000
GROUP BY usg.HouseholdID
	,usg.StationID
	
SELECT smh.HhID
	, smh.SmartHomeStatus
	, (SELECT SUM(usg.DurationSec) FROM #tempUsg usg WHERE smh.HhID = usg.HouseholdID AND usg.StationID = 0) AS ARDuration
	, (SELECT SUM(usg.DurationSec) FROM #tempUsg usg WHERE smh.HhID = usg.HouseholdID AND usg.StationID = 1102) AS DVDDuration
	, (SELECT SUM(usg.DurationSec) FROM #tempUsg usg WHERE smh.HhID = usg.HouseholdID AND usg.StationID = 1103) AS GameConsoleDuration
	, (SELECT SUM(usg.DurationSec) FROM #tempUsg usg WHERE smh.HhID = usg.HouseholdID AND usg.StationID <> -1) AS TotalDuration
	, (SELECT SUM(usg.DurationSec) FROM #tempUsg usg WHERE smh.HhID = usg.HouseholdID AND usg.StationID NOT IN (0,1102,1103)) AS OthersDuration
FROM
(
	SELECT HhID,
		   CASE WHEN MAX(SmartTVHH) = 1 THEN 'Smart Home' ELSE 'Non SMart Home' END AS [SmartHomeStatus]
	FROM #smartHomes
	GROUP BY HhID
) AS smh



