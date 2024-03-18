-- ================================================================================
-- Author:		<Dennis Khor>
-- Create date: <2023-08-29>
-- Description:	<Inactive SMS to DAM panelists>
-- Last changed:<yyyy-MM-dd by ????,>
-- ================================================================================

---Drop TempTable It If Existed.
IF OBJECT_ID('tempdb..#tempLDMUsgA') IS NOT NULL
BEGIN
	DROP TABLE #tempLDMUsgA
END

IF OBJECT_ID('tempdb..#tempLDMUsgB') IS NOT NULL
BEGIN
	DROP TABLE #tempLDMUsgB
END


--------------------------------------------------------------USEFUL FUNCTIONS START----------------------------------------------------------------
--SELECT * FROM FUGetCharValHistDetails(@ReferenceDate, 741)
--SELECT * FROM FUGetInstalledHouseHold(@ReferenceDate)
--SELECT * FROM FUGetUninstalledHouseHold(@ReferenceDate)
--SELECT * FROM FUGetHHSizeWithMaids(@ReferenceDate)
--SELECT * FROM FUGetContactInOut()
--SELECT [dbo].[fnGetContactNumByHHID] (10001)
--SELECT [dbo].[fnGetContactNumByHHMemID] (10001)
--SELECT [dbo].[fnGetTVSeqByHHMemIDRefDate] (10021, @ReferenceDate)
--SELECT [dbo].[GetWeekDayNameOfDate](@ReferenceDate)

-----Delimiter Function Script.
--DECLARE @sInputList VARCHAR(MAX) -- List of delimited items	
--DECLARE @sDelimiter VARCHAR(20) = ','	--Delimiter that separates items
--SET @sInputList = ''
--IF @sInputList IS NOT NULL
--	SELECT value INTO #HHID FROM dbo.fn_Split(@sInputList,@sDelimiter)
--------------------------------------------------------------USEFUL FUNCTIONS ENDED----------------------------------------------------------------


-----------------------------------------------------------USEFUL STORED PROCEDURES START-----------------------------------------------------------
--SP_GetCharInfo 0, 'ldm'
--SP_GetDwellingType 10001
-----------------------------------------------------------USEFUL STORED PROCEDURES ENDED-----------------------------------------------------------


---------------------------------------------------------------USEFUL SCRIPTS START-----------------------------------------------------------------
-----Drop TempTable It If Existed.
--IF OBJECT_ID('tempdb..#tempTodayChars') IS NOT NULL
--BEGIN
--	DROP TABLE #tempTodayChars
--END

-----Pivot
--DECLARE @cols AS nvarchar(MAX)

--	;WITH UsageDate AS
--	 (SELECT DISTINCT a.[Program Date] as [Broadcast_Date] FROM #TempProgramLogs a)
--	SELECT @cols = ISNULL(@cols + ',[', '[') + CONVERT(VARCHAR, [Broadcast_Date],102) + ']'
--	 FROM UsageDate
--	 ORDER BY [Broadcast_Date] ASC

--	DECLARE @sql AS nvarchar(MAX)
--	SET @sql = '
--		DECLARE @unofficialDate AS date
--		SET @unofficialDate = ''2016-03-31''
--		SELECT ''C2'' AS [QC Code], CASE WHEN [Station ID] BETWEEN 3000 AND 3006 THEN ''FTA''
--				ELSE ''PAID TV''
--			END AS [FTA/PAID TV],*
--		FROM
--		(SELECT [Station group reporting],[Program Log Source], StationID AS [Station ID], CurrentStationName AS [Station Name],[TOP 20],[Program Type],[Program Type Desc],[Program Date] AS broadCastDate, [Ref Day]
--			FROM #TempProgramLogs
--		) AS a
--		PIVOT
--		(
--			SUM([Ref Day]) FOR broadCastDate IN(' + @cols + N')
--		) AS b
--		WHERE ((SELECT CAST(MAX([Program Date]) AS date) FROM #TempProgramLogs) > @unofficialDate OR (SELECT CAST(MAX([Program Date]) AS date) FROM #TempProgramLogs) <= @unofficialDate AND [Station ID] BETWEEN 3000 AND 3006)
--			AND [Station ID] NOT IN (3202,3206,3209,3217,3218)
--		ORDER BY [FTA/PAID TV],[Program Log Source],[Station Name]
--	'

--	--PRINT @sql -- for debugging
--	EXEC sp_executesql @sql
---------------------------------------------------------------USEFUL SCRIPTS ENDED-----------------------------------------------------------------



DECLARE @ReferenceDate AS date

SET @ReferenceDate = '2023-07-31'


SELECT @ReferenceDate AS [ReferenceDate]

SELECT ldm.AtlasID
	, MAX(ldm.ReferenceDate) AS [ReferenceDate]
INTO #tempLDMUsgA
FROM
(
	SELECT DISTINCT CASE WHEN LEN(CAST(ldmAct.[panel_household_id] AS bigint)) >= 8 THEN ldmAct.[panel_household_id]
			WHEN LEN(CAST(ldmAct.[panel_household_id] AS bigint)) < 8 
				THEN ISNULL((
						SELECT TOP 1 a.[Atlas ID]
						FROM [SGTAMProd].[dbo].[ConversionTable] a 
						WHERE a.panel_household_id = CAST(ldmAct.[panel_household_id] AS bigint) 
							AND a.panel_person_id = CAST(ldmAct.[panel_person_id] AS bigint)
					), ldmAct.[panel_household_id])
			ELSE ldmAct.[panel_household_id]
		END AS [AtlasID]
		, CAST(ldmAct.last_activity_date AS date) AS [ReferenceDate]
	FROM SGTAMProd.dbo.tLeoTraceDeviceDaily ldmAct
	WHERE ISNUMERIC(ldmAct.[panel_household_id]) = 1
		AND ldmAct.[panel_household_id] <> ''
		AND ldmAct.device_type IN ('SMARTPHONE','TABLET','FIXED')
		AND ldmAct.last_activity_date BETWEEN DATEADD(DAY, -27, @ReferenceDate) AND DATEADD(DAY, -1, @ReferenceDate)
) AS ldm
WHERE ldm.AtlasID IS NOT NULL
GROUP BY ldm.AtlasID

SELECT @ReferenceDate AS [ReferenceDate] 
	, actDAM.[C691-LDM LAMI HhID] AS [AtlasID]
	, mem.FirstName
	, mem.LastName
	, c453.TextFull AS [Mobile phone member]
	, c454.TextFull AS [Email]
	, ldmUsg.ReferenceDate AS [Last LDM Activity Date]
FROM FUGetActiveDAMPanelist(@ReferenceDate) actDAM
LEFT JOIN tHhMem mem ON actDAM.HhMemID = mem.HhMemID
LEFT JOIN FUGetCharValHistDetails(CAST(GETDATE() AS date), 453) c453 ON actDAM.HhMemID = c453.RefEntityID	--Mobile phone member
LEFT JOIN FUGetCharValHistDetails(CAST(GETDATE() AS date), 454) c454 ON actDAM.HhMemID = c454.RefEntityID	--Email
INNER JOIN #tempLDMUsgA ldmUsg ON actDAM.[C691-LDM LAMI HhID] = ldmUsg.AtlasID
ORDER BY ldmUsg.ReferenceDate


SET @ReferenceDate = '2023-08-27'
SELECT @ReferenceDate AS [ReferenceDate]

SELECT ldm.AtlasID
	, MAX(ldm.ReferenceDate) AS [ReferenceDate]
INTO #tempLDMUsgB
FROM
(
	SELECT DISTINCT CASE WHEN LEN(CAST(ldmAct.[panel_household_id] AS bigint)) >= 8 THEN ldmAct.[panel_household_id]
			WHEN LEN(CAST(ldmAct.[panel_household_id] AS bigint)) < 8 
				THEN ISNULL((
						SELECT TOP 1 a.[Atlas ID]
						FROM [SGTAMProd].[dbo].[ConversionTable] a 
						WHERE a.panel_household_id = CAST(ldmAct.[panel_household_id] AS bigint) 
							AND a.panel_person_id = CAST(ldmAct.[panel_person_id] AS bigint)
					), ldmAct.[panel_household_id])
			ELSE ldmAct.[panel_household_id]
		END AS [AtlasID]
		, CAST(ldmAct.last_activity_date AS date) AS [ReferenceDate]
	FROM SGTAMProd.dbo.tLeoTraceDeviceDaily ldmAct
	WHERE ISNUMERIC(ldmAct.[panel_household_id]) = 1
		AND ldmAct.[panel_household_id] <> ''
		AND ldmAct.device_type IN ('SMARTPHONE','TABLET','FIXED')
		AND ldmAct.last_activity_date BETWEEN DATEADD(DAY, -27, @ReferenceDate) AND DATEADD(DAY, -1, @ReferenceDate)
) AS ldm
WHERE ldm.AtlasID IS NOT NULL
GROUP BY ldm.AtlasID

--sp_getcharinfo 0, 'mobile'
--sp_getcharinfo 0, 'email'

SELECT @ReferenceDate AS [ReferenceDate] 
	, actDAM.[C691-LDM LAMI HhID] AS [AtlasID]
	, mem.FirstName
	, mem.LastName
	, c453.TextFull AS [Mobile phone member]
	, c454.TextFull AS [Email]
	, ldmUsg.ReferenceDate AS [Last LDM Activity Date]
FROM FUGetActiveDAMPanelist(@ReferenceDate) actDAM
LEFT JOIN tHhMem mem ON actDAM.HhMemID = mem.HhMemID
LEFT JOIN FUGetCharValHistDetails(CAST(GETDATE() AS date), 453) c453 ON actDAM.HhMemID = c453.RefEntityID	--Mobile phone member
LEFT JOIN FUGetCharValHistDetails(CAST(GETDATE() AS date), 454) c454 ON actDAM.HhMemID = c454.RefEntityID	--Email
INNER JOIN #tempLDMUsgB ldmUsg ON actDAM.[C691-LDM LAMI HhID] = ldmUsg.AtlasID
ORDER BY ldmUsg.ReferenceDate