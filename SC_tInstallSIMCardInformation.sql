/*

-- ================================================================================
-- Author:		Sirikorn Chatphatthananan	
-- Create date: 2023-01-13
-- Description:	SIM Card Information of tInst
-- Request by: Alexz
-- Request email title: 
-- Request email date: 
-- Last changed: 16 Jan 2023
-- *Add more columns to state if on 13-15 Jan has data available for particular SIM Cards
-- ================================================================================

- installation list
- sim card used
- sim serial number
- reception level
sp_getcharinfo 455 --SIM card provider used
sp_getcharinfo 440 --SIM-card No. 1
sp_getcharinfo 441 --SIM-card No. 2
sp_getcharinfo 555 --Reception Level (inst)
SELECT * FROM FUGetInstalledHouseHold(GETDATE())
select * from tInst
select * from tInstDom
*/

USE EvoProd
GO


IF OBJECT_ID('tempdb..#A') IS NOT NULL DROP TABLE #A



----13-15 Jan 2023, have data available?
SELECT dse.RefEntityID, sc.[Name] as [Status Name], dse.ReferenceDate
INTO #A
FROM tDayStatusEntry dse
INNER JOIN tStatusDefinition sd ON dse.StatusDefinitionID = sd.DefinitionID
INNER JOIN tStatusCode sc ON dse.StatusCodeID = sc.StatusCodeID
where ReferenceDate BETWEEN '2023-01-13' AND '2023-01-15' and DefinitionID IN ('7') 


--SELECT * FROM #A		

SELECT instd.HhID
	   ,c455.TextFull
	   ,c440.TextFull
	   ,(
		SELECT [Status Name] FROM #A WHERE #A.ReferenceDate='2023-01-13' AND #A.RefEntityID = instd.HhID 
	   ) AS [13 Jan data available?]
	   ,(
		SELECT [Status Name] FROM #A WHERE #A.ReferenceDate='2023-01-14' AND #A.RefEntityID = instd.HhID 
	   ) AS [14 Jan data available?]
	   ,(
		SELECT [Status Name] FROM #A WHERE #A.ReferenceDate='2023-01-15' AND #A.RefEntityID = instd.HhID 
	   ) AS [15 Jan data available?]
FROM tInstDom instD 
INNER JOIN tInst inst ON instD.InstDomID = inst.InstDomID AND CAST(GETDATE() AS DATE) BETWEEN instd.ActiveFrom AND instd.ActiveUntil AND CAST(GETDATE() AS DATE) BETWEEN inst.ActiveFrom AND inst.ActiveUntil
INNER JOIN FUGetCharValHistDetails(GETDATE(),455) c455 ON inst.InstID = c455.RefEntityID --sim provider
INNER JOIN FUGetCharValHistDetails(GETDATE(), 440) c440 ON c455.RefEntityID = c440.RefEntityID --sim serial
ORDER BY instd.HhID ASC


