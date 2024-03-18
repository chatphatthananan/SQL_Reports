-- =============================================
-- Author:		Sirikorn Chatphatthananan
-- Create date: 28 February 2022
-- Description:	Get archived panel numbers for 27 February 2022
-- Last changed: 
-- =============================================

USE EvoProd
GO

DECLARE @refDate DATE = '2022-02-27'

SELECT
	ra.TextFull AS Race,
	HhRes.[Residential Status],
	COUNT(*) AS [Total]
FROM FUGetInstalledHouseHold(@refDate) p 
INNER JOIN FUGetCharValHistDetails(@refDate,744) ra ON ra.RefEntityID = p.HhID --Race head of household
INNER JOIN 
	(SELECT thm.HhID, c253.TextFull, CASE WHEN c303.CharValue = '1' OR c303.CharValue = '2' THEN 'Resident' 
	ELSE 'Non-Resident' END AS [Residential Status]
	FROM tHhMem thm
	INNER JOIN FUGetCharValHistDetails(@refDate,253) c253 ON thm.HhMemID = c253.RefEntityID --Head of Household
	INNER JOIN FUGetCharValHistDetails(@refDate,303) c303 ON thm.HhMemID = c303.RefEntityID --Residential status
	WHERE c253.TextFull = 'Yes') HhRes ON HhRes.HhID = p.HhID
GROUP BY ra.TextFull,[Residential Status]
ORDER BY ra.TextFull, HhRes.[Residential Status] DESC

--SELECT *
--FROM FUGetInstalledHouseHold(@refDate) p 
--INNER JOIN FUGetCharValHistDetails(@refDate,744) ra ON ra.RefEntityID = p.HhID --Race head of household
--INNER JOIN 
--	(SELECT thm.HhID, c253.TextFull, CASE WHEN c303.CharValue = '1' OR c303.CharValue = '2' THEN 'Resident' 
--	ELSE 'Non-Resident' END AS [Residential Status]
--	FROM tHhMem thm
--	INNER JOIN FUGetCharValHistDetails(@refDate,253) c253 ON thm.HhMemID = c253.RefEntityID --Head of Household
--	INNER JOIN FUGetCharValHistDetails(@refDate,303) c303 ON thm.HhMemID = c303.RefEntityID --Residential status
--	WHERE c253.TextFull = 'Yes') HhRes ON HhRes.HhID = p.HhID



