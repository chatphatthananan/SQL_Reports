
-- =============================================
-- Author:		Sirikorn Chatphatthananan
-- Create date: 26 August 2022
-- Description:	To know the iCC participation of all active panel homes
-- Last modified: 
-- Notes: Contact In and Out, last tech visit, iCC year, RefData = 1st Aug 2022 for Active Panel Homes, requested by KY
-- =============================================

USE EvoProd
GO

IF OBJECT_ID('tempdb..#tmp_ICCLastParticipatedYear') IS NOT NULL
BEGIN
	DROP TABLE #tmp_ICCLastParticipatedYear
END

IF OBJECT_ID('tempdb..#temp_results') IS NOT NULL
BEGIN
	DROP TABLE #temp_results
END

IF OBJECT_ID('tempdb..#tmp_contactout') IS NOT NULL
BEGIN
	DROP TABLE #tmp_contactout
END

IF OBJECT_ID('tempdb..#tmp_contactin') IS NOT NULL
BEGIN
	DROP TABLE #tmp_contactin
END

IF OBJECT_ID('tempdb..#tmp_contactoutfinal') IS NOT NULL
BEGIN
	DROP TABLE #tmp_contactoutfinal
END

IF OBJECT_ID('tempdb..#tmp_contactinfinal') IS NOT NULL
BEGIN
	DROP TABLE #tmp_contactinfinal
END


DECLARE @todayDate DATE = GETDATE()
DECLARE @FirstAug2022 DATE = '2022-08-01'

-- To get most recent iCC year participated by active panel homes inserted into temp table
SELECT HhID, MAX(YearOfICCInterview) AS ICCYear 
INTO #tmp_ICCLastParticipatedYear
FROM SGTAMProd.dbo.tICCInterviewedList 
GROUP BY HhID 

-- Insert results into temp table #tmp_results
SELECT  activePanelHh.HhID AS [Active Panel Homes HhID],
		CASE 
			WHEN ICCLPY.ICCYear IS NULL THEN NULL
			ELSE ICCLPY.ICCYear
			END AS [Last Participated iCC],
		CASE 
			WHEN activePanelHh.HhID IN (SELECT HhID FROM SGTAMProd.dbo.tICCInterviewedList WHERE YearOfICCInterview = 2017) THEN 'Yes'
			ELSE 'No'  
			END AS [iCC 2017],
			CASE WHEN activePanelHh.HhID IN (SELECT HhID FROM SGTAMProd.dbo.tICCInterviewedList WHERE YearOfICCInterview = 2018) THEN 'Yes'
			ELSE 'No'  
			END AS [iCC 2018],
			CASE WHEN activePanelHh.HhID IN (SELECT HhID FROM SGTAMProd.dbo.tICCInterviewedList WHERE YearOfICCInterview = 2019) THEN 'Yes'
			ELSE 'No'  
			END AS [iCC 2019],
			CASE WHEN activePanelHh.HhID IN (SELECT HhID FROM SGTAMProd.dbo.tICCInterviewedList WHERE YearOfICCInterview = 2020) THEN 'Yes'
			ELSE 'No'  
			END AS [iCC 2020],
			CASE WHEN activePanelHh.HhID IN (SELECT HhID FROM SGTAMProd.dbo.tICCInterviewedList WHERE YearOfICCInterview = 2021) THEN 'Yes'
			ELSE 'No'  
			END AS [iCC 2021],
			CASE WHEN activePanelHh.HhID IN (SELECT HhID FROM SGTAMProd.dbo.tICCInterviewedList WHERE YearOfICCInterview = 2022) THEN 'Yes'
			ELSE 'No'  
			END AS [iCC 2022],
		lv.LastMaintVisit AS [Last Maintenance Visit]
INTO #temp_results
FROM FUGetInstalledHouseHold(@FirstAug2022) activePanelHh
LEFT JOIN #tmp_ICCLastParticipatedYear ICCLPY ON ICCLPY.HhID = activePanelHh.HhID  -- last participated icc year
LEFT JOIN
    (
        SELECT techOrd.HhID,max(toTimeS.TimeFrom) AS LastMaintVisit
        FROM tTechOrder techOrd
        INNER JOIN tTechOrderLine techOrdLine ON techOrd.TechOrderID = techOrdLine.TechOrderID    
        INNER JOIN tTechnicianTimeSheet toTimeS ON techOrd.TechOrderID = toTimeS.TechOrderID AND  (CAST(toTimeS.TimeFrom AS date) <= @todayDate)    
        WHERE techOrdLine.ReasonText NOT IN ('TecOrd: DAM installation','TecOrd: DAM maintenance','TecOrd: Uninstall Hh')
        AND techOrd.ActualTechOrderStatus <> 21
        GROUP BY techOrd.HhID
    ) lv ON lv.HhID = activePanelHh.HhID

-- Contact out information grouped by HhID and Contact Type insert into temp table
SELECT HhID, MAX(CreationDate) AS [Contact Out Date], ContactType 
INTO #tmp_contactout
FROM FUGetContactInOut()
WHERE ContactType LIKE '%Contact out%'
GROUP BY HhID, CreationDate, ContactType

-- Contact out final
SELECT HhID, MAX([Contact Out Date]) AS [ContactOut Date] 
INTO #tmp_contactoutfinal
FROM #tmp_contactout
GROUP BY HhID 
ORDER BY HhID

-- Contact in information grouped by HhID and Contact Type insert into temp table
SELECT HhID, MAX(CreationDate) AS [Contact In Date], ContactType 
INTO #tmp_contactin
FROM FUGetContactInOut()
WHERE ContactType LIKE '%Contact in%'
GROUP BY HhID, CreationDate, ContactType

-- Contact in final
SELECT HhID, MAX([Contact In Date]) AS [ContactIn Date]
INTO #tmp_contactinfinal
FROM #tmp_contactin
GROUP BY HhID 
ORDER BY HhID

-- Results with contact in and out
SELECT	res.[Active Panel Homes HhID],
		res.[Last Participated iCC],
		res.[iCC 2017],
		res.[iCC 2018],
		res.[iCC 2019],
		res.[iCC 2020],
		res.[iCC 2021],
		res.[iCC 2022],
		res.[Last Maintenance Visit],
		cin.[ContactIn Date],
		cout.[ContactOut Date]
FROM #temp_results res
LEFT JOIN #tmp_contactinfinal cin ON cin.HhID = res.[Active Panel Homes HhID]
LEFT JOIN #tmp_contactoutfinal cout ON cout.HhID = res.[Active Panel Homes HhID]
ORDER BY res.[Active Panel Homes HhID]

