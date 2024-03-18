-- ===================================================================================================================================================================
-- Author:		<Sirikorn>
-- Create date: <2022-09-20>
-- Description:	<>
-- Last changed:<2022-09-21>, <2022-09-29>
-- ===================================================================================================================================================================

USE EvoProd
GO

DECLARE @todayDate DATE = GETDATE()

--******************************************************************************************************************************************************--
--SELECT	 thm.HhID
--		,thm.HhMemID
--		,CASE 
--			WHEN c39.CharValue = 1 THEN 'Male'
--			ELSE 'Female'
--		END AS [Gender]
--		,CASE 
--			WHEN c265.CharValue = 1 THEN 'Chinese'
--			WHEN c265.CharValue = 2 THEN 'Malay'
--			WHEN c265.CharValue = 3 THEN 'Indian'
--			ELSE 'Others'
--		END AS [Race]
--		,CASE 
--			WHEN c717.CharValue IN (1,2,3,4,5,6,7,8,9) THEN 'Working'
--			ELSE 'Non-Working'
--		END AS [Working or Non-Working]
--		,fur.[Member Status] -- is the respondent still in the same Hh?
--FROM FUGetInstalledHouseHold(@todayDate) fu 
--INNER JOIN tHhMem thm ON fu.HhID = thm.HhID -- active panel homes, 
--INNER JOIN FUGetRespondent(@todayDate) fur ON fur.HhMemID = thm.HhMemID -- get main respondent even if they moved or have not moved out of hh
--INNER JOIN FUGetCharValHistDetails(@todayDate,717) c717 ON c717.RefEntityID = thm.HhMemID --occupation, 
--INNER JOIN FUGetCharValHistDetails(@todayDate,39) c39 ON c39.RefEntityID = thm.HhMemID --gender, 1male , 2female
--INNER JOIN FUGetCharValHistDetails(@todayDate,265) c265 ON c265.RefEntityID = thm.HhMemID --race , 1Chinese 2Malay 3Indian 4others

--******************************************************************************************************************************************************--


--HHID	HHMemID	Age	Gender	Race	Main Contact (Y/N)	Grocery Buyer (Y/N)	Head of HH (Y/N)	Working/Non-working	Occupation
--SELECT *
--FROM FUGetInstalledHouseHold(@todayDate) fu -- active panel homes, 
--INNER JOIN tHhMem thm ON fu.HhID = thm.HhID AND @todayDate BETWEEN thm.PartOfHhFrom AND thm.PartOfHhUntil
--INNER JOIN tPanelHhMem tpm ON tpm.HhMemID = thm.HhMemID AND tpm.PanelID = 1 AND @todayDate BETWEEN tpm.ParticFrom AND tpm.ParticUntil -- panel members ,panelID=1
--INNER JOIN FUGetCharValHistDetails(@todayDate,60) c60 ON c60.RefEntityID = thm.HhMemID AND c60.CharValue >= 15 -- age, 15+
IF OBJECT_ID('tempdb..#tmp') IS NOT NULL DROP TABLE #tmp

SELECT	 fu.HhID
		,thm.HhMemID
		,c60.CharValue AS [Age]
		,CASE 
			WHEN c39.CharValue = 1 THEN 'Male'
			WHEN c39.CharValue = 2 THEN 'Female'
			ELSE c39.CharValue
		END AS [Gender]
		,CASE 
			WHEN c265.CharValue = 1 THEN 'Chinese'
			WHEN c265.CharValue = 2 THEN 'Malay'
			WHEN c265.CharValue = 3 THEN 'Indian'
			WHEN c265.CharValue = 4 THEN 'Others'
			ELSE c265.CharValue
		END AS [Race]
		,CASE 
			WHEN resp.[Member Status] IS NOT NULL THEN 'Yes'			
			ELSE 'No'
		END AS [Main Contact]
		,CASE WHEN resp.[Member Status] IS NOT NULL THEN resp.[Member Status] -- filter out inactive non respondent memebers for this column
			  WHEN @todayDate BETWEEN thm.PartOfHhFrom AND thm.PartOfHhUntil THEN 'Active Non-Respondent'
			  ELSE 'Inactive Non-Respondent'
		END AS [Member Status]
		,CASE 
			WHEN c254.CharValue = '1' THEN 'Yes'
			WHEN c254.CharValue = '2' THEN 'No'
			ELSE c254.CharValue
		END AS [Grocery Buyer]
		,CASE 
			WHEN c253.CharValue = '1' THEN 'Yes'
			WHEN c253.CharValue = '2' THEN 'No'
			ELSE c253.CharValue
		END AS [Head of HH]
		,CASE 
			WHEN c717.CharValue IN (1,2,3,4,5,6,7,8,9) THEN 'Working'
			WHEN c717.CharValue IN (10,11,12,13,14,15) THEN 'Non-Working'
			ELSE c717.CharValue
		END AS [Working or Non-Working]
		,CASE
			WHEN c717.CharValue IN (1,2,3,4,5) THEN 'PMEB'
			WHEN c717.CharValue IN (6,7,8,9) THEN 'Non-PMEB'
			WHEN c717.CharValue = 10 THEN 'Homemaker'
			WHEN c717.CharValue = 11 THEN 'Student'
			WHEN c717.CharValue = 13 THEN 'Retiree'
			WHEN c717.CharValue IN (12,14,15) THEN 'Others'
			ELSE c717.CharValue
		END AS [Occupation Breakdown]
	, c251.TextFull AS [Live-In]
INTO #tmp
FROM FUGetInstalledHouseHold(@todayDate) fu -- active panel homes, 
INNER JOIN tHhMem thm ON fu.HhID = thm.HhID --AND @todayDate BETWEEN thm.PartOfHhFrom AND thm.PartOfHhUntil -- commented out partofhhfrom and until out to include 'inactive members' as well as some of then still want to be considered as main contact for the hh they moved out
INNER JOIN tPanelHhMem tpm ON tpm.HhMemID = thm.HhMemID AND tpm.PanelID = 1 AND @todayDate BETWEEN tpm.ParticFrom AND tpm.ParticUntil -- panel members ,panelID=1
INNER JOIN FUGetCharValHistDetails(@todayDate,60) c60 ON c60.RefEntityID = thm.HhMemID AND c60.CharValue >= 15 -- age, 15+
--LEFT JOIN FUGetCharValHistDetails(@todayDate,255) c255 ON c255.RefEntityID = thm.HhMemID -- respondent?
LEFT JOIN FUGetRespondent(@todayDate) resp ON resp.HhMemID = thm.HhMemID -- respondent function?
LEFT JOIN FUGetCharValHistDetails(@todayDate,251) c251 ON c251.RefEntityID = thm.HhMemID --live-in,HH-Member only, exclude maids and tenants
LEFT JOIN FUGetCharValHistDetails(@todayDate,717) c717 ON c717.RefEntityID = thm.HhMemID --occupation, 
LEFT JOIN FUGetCharValHistDetails(@todayDate,39) c39 ON c39.RefEntityID = thm.HhMemID --gender, 1male , 2female
LEFT JOIN FUGetCharValHistDetails(@todayDate,265) c265 ON c265.RefEntityID = thm.HhMemID --race , 1Chinese 2Malay 3Indian 4others
LEFT JOIN FUGetCharValHistDetails(@todayDate,254) c254 ON c254.RefEntityID = thm.HhMemID -- Grocery buyer?
LEFT JOIN FUGetCharValHistDetails(@todayDate,253) c253 ON c253.RefEntityID = thm.HhMemID -- head of household?
WHERE (resp.[Member Status] IS NOT NULL OR (@todayDate BETWEEN thm.PartOfHhFrom AND thm.PartOfHhUntil))
ORDER BY fu.HhID, thm.HhMemID
--******************************************************************************************************************************************************--



SELECT * FROM #tmp
ORDER BY HhID, HhMemID


--SELECT HhID, COUNT(*)
--FROM #tmp 
--WHERE [Main Contact] = 'Yes'
--GROUP BY HhID
--HAVING COUNT(*) > 1
