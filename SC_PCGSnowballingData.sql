-- =============================================
-- Author:		Sirikorn Chatphatthananan 
-- Create date: 13 April 2022
-- Description:	PCG data requested by Louise on 12 April 2022
-- Details from email: PCG – to generate count under Col C in the attached file, for period 8 Jan 2022 to 7 Apr 2022 – I used the same grid format from the weekly DAM Panel Control Grid
-- =============================================

USE [EvoProdCopy]
GO

--DECLARE @todayDate DATE = GETDATE()
DECLARE @refDate DATE = DATEADD(DAY,-2,GETDATE())
DECLARE @startDate DATE, @endDate DATE

SELECT TOP 1 @startDate = [Data range start date]
	 , @endDate = [Data range end date] 
FROM EvoProd.dbo.FUGetActiveDAMPanelistWithActivity(90, DATEADD(DAY,-4,@refDate))

-- Get Start Date and End Date of Hyperlane Activity past 90 days
--SELECT @startDate AS StartDate, @endDate AS EndDate

/* Get Hyperlane Device for past 90 days */
IF OBJECT_ID('tempdb..#tmpHyperlaneDevice') IS NOT NULL DROP TABLE #tmpHyperlaneDevice

;WITH tmpIDConversionHyperlane AS (
	/* Find their converted AtlasID if their old ID remains in Hyperlane activity */
	SELECT CASE WHEN LEN(CAST(a.[panel_household_id] AS bigint)) >= 8 THEN [panel_household_id]
					WHEN LEN(CAST(a.[panel_household_id] AS bigint)) < 8 
						THEN (
								SELECT TOP 1 a.[Atlas ID] 
								FROM [SGTAMProd].[dbo].[ConversionTable] a 
								WHERE a.panel_household_id = CAST(a.panel_household_id AS bigint) 
									AND a.panel_person_id = CAST(a.panel_person_id AS bigint)
							)
				END AS [AtlasID]
			 , *
		FROM SGTAMProd.dbo.tHyperlaneDailyActivity a
		WHERE a.reference_day BETWEEN @startDate AND @endDate
)
, tmpHyperlaneDevice AS (
	/* Group their device by AtlasID */
	SELECT AtlasID
		 , device_type_id
		 , operating_system_id
		 , MIN(reference_day) AS MinRefDay
		 , MAX(reference_day) AS MaxRefDay
	FROM tmpIDConversionHyperlane
	GROUP BY AtlasID, device_type_id, operating_system_id
)
SELECT * 
INTO #tmpHyperlaneDevice
FROM tmpHyperlaneDevice

/* Get Active DAM Panelists past 90 days */
IF OBJECT_ID('tempdb..#tmpActiveDAMPanelistP90D') IS NOT NULL DROP TABLE #tmpActiveDAMPanelistP90D
SELECT a.[C691-LDM LAMI HhID]
	 , a.HhID
	 , a.HhMemID
INTO #tmpActiveDAMPanelistP90D
FROM EvoProd.dbo.FUGetActiveDAMPanelistWithActivity(90, @refDate) a

/* Join Active DAM Panelists with their EPM profile */
IF OBJECT_ID('tempdb..#tmpActiveDAMPanelistP90DProfile') IS NOT NULL DROP TABLE #tmpActiveDAMPanelistP90DProfile

SELECT adp.HhID
	 , adp.HhMemID
	 , c39.TextFull				AS [Gender]
	 , c60.CharValue			AS [Age]
	 , CASE WHEN c60.CharValue BETWEEN 0  AND 14 THEN '10-14 years old'
			WHEN c60.CharValue BETWEEN 15 AND 29 THEN '15-29 years old'
			WHEN c60.CharValue BETWEEN 30 AND 49 THEN '30-49 years old'
			WHEN c60.CharValue >= 50 THEN '50+ years old'
			ELSE 'Missing' END  AS [Age Group]
	 , c265.TextFull			AS [Race]	 
INTO #tmpActiveDAMPanelistP90DProfile
FROM #tmpActiveDAMPanelistP90D adp
LEFT JOIN EvoProd.dbo.FUGetCharValHistDetails(@refDate, 39)  c39  ON adp.HhMemID = c39.RefEntityID	-- Gender
LEFT JOIN EvoProd.dbo.FUGetCharValHistDetails(@refDate, 60)  c60  ON adp.HhMemID = c60.RefEntityID	-- Age
LEFT JOIN EvoProd.dbo.FUGetCharValHistDetails(@refDate, 265) c265 ON adp.HhMemID = c265.RefEntityID	-- Race
INNER JOIN FUGetCharValHistDetails(@refDate, 1200) c1200 ON adp.HhMemID = c1200.RefEntityID AND c1200.CharValue='110' -- Snowballing

/* Join Active DAM Panelists with their digital devices */
IF OBJECT_ID('tempdb..#tmpActiveDAMPanelistP90DDevice') IS NOT NULL DROP TABLE #tmpActiveDAMPanelistP90DDevice

SELECT adp.HhID
	 , adp.HhMemID
	 , hdev.AtlasID
	 , hdev.device_type_id		AS [DeviceType]
	 , hdev.operating_system_id	AS [DeviceOS]
INTO #tmpActiveDAMPanelistP90DDevice
FROM #tmpActiveDAMPanelistP90D adp
INNER JOIN #tmpHyperlaneDevice hdev ON adp.[C691-LDM LAMI HhID] = hdev.AtlasID
INNER JOIN FUGetCharValHistDetails(@refDate, 1200) c1200 ON adp.HhMemID = c1200.RefEntityID AND c1200.CharValue='110' -- Snowballing


/* Gender x Age Group */
IF OBJECT_ID('tempdb..#tmpGenderAge') IS NOT NULL DROP TABLE #tmpGenderAge

/* Generate new pivot columns if required
	DECLARE @GenderAgeCols AS NVARCHAR(MAX)
	;WITH GenderAge AS (
		SELECT DISTINCT CONCAT(Gender, ' ', [Age Group]) AS Val FROM #tmpActiveDAMPanelistP90DProfile
	)
	SELECT @GenderAgeCols = ISNULL(@GenderAgeCols + ',[', '[') + Val + ']'
	FROM GenderAge
	ORDER BY Val
*/

SELECT *
INTO #tmpGenderAge
FROM (
	SELECT CONCAT(Gender, ' ', [Age Group]) AS Value
		 , COUNT(*)			AS [Total]
	FROM #tmpActiveDAMPanelistP90DProfile
	GROUP BY Gender, [Age Group]
) a
PIVOT (
	MAX(Total) FOR Value IN ([Male 10-14 years old], [Male 15-29 years old], [Male 30-49 years old], [Male 50+ years old], [Female 10-14 years old], [Female 15-29 years old], [Female 30-49 years old], [Female 50+ years old])
) pvt

/* Race */
IF OBJECT_ID('tempdb..#tmpRace') IS NOT NULL DROP TABLE #tmpRace

/* Generate new pivot columns if required
	DECLARE @RaceCols AS NVARCHAR(MAX)
	;WITH Race AS (
		SELECT DISTINCT Race AS Val FROM #tmpActiveDAMPanelistP90DProfile
	)
	SELECT @RaceCols = ISNULL(@RaceCols + ',[', '[') + Val + ']'
	FROM Race
	ORDER BY Val
*/

SELECT *
INTO #tmpRace
FROM (
	SELECT Race		AS [Value]	 
		 , COUNT(*) AS [Total]
	FROM #tmpActiveDAMPanelistP90DProfile
	GROUP BY Race
) a
PIVOT (
	MAX(Total) FOR Value IN ([Chinese], [Malay], [Indian], [others])
) pvt

/* Device Type */
IF OBJECT_ID('tempdb..#tmpDeviceType') IS NOT NULL DROP TABLE #tmpDeviceType

/* Generate new pivot columns if required
	DECLARE @DeviceTypeCols AS NVARCHAR(MAX)
	;WITH DeviceType AS (
		SELECT DISTINCT DeviceType AS Val FROM #tmpActiveDAMPanelistP90DDevice
	)
	SELECT @DeviceTypeCols = ISNULL(@DeviceTypeCols + ',[', '[') + Val + ']'
	FROM DeviceType
	ORDER BY Val
*/

SELECT *
INTO #tmpDeviceType
FROM (
	SELECT DeviceType	AS [Value]	 
		 , COUNT(*)		AS [Total]
	FROM #tmpActiveDAMPanelistP90DDevice a
	GROUP BY DeviceType
) a
PIVOT (
	MAX(Total) FOR Value IN ([PC], [Tablet], [Smartphone])
) pvt




SELECT @refDate		AS RefDate
	 , @startDate	AS StartDate
	 , @endDate		AS EndDate
	 , ga.[Male 10-14 years old]
	 , ga.[Male 15-29 years old]
	 , ga.[Male 30-49 years old]
	 , ga.[Male 50+ years old]
	 , ga.[Female 10-14 years old]
	 , ga.[Female 15-29 years old]
	 , ga.[Female 30-49 years old]
	 , ga.[Female 50+ years old]
	 , r.Chinese
	 , r.Malay
	 , r.Indian
	 , r.others
	 , dt.PC
	 , dt.Tablet
	 , dt.Smartphone
FROM #tmpGenderAge ga, #tmpRace r, #tmpDeviceType dt

--SELECT * FROM SGTAMProd.dbo.tDAMPanelControlGrid WHERE RefDate = @todayDate
