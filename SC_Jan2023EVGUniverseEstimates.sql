-- =============================================
-- Author:		Sirikorn Chatphatthananan
-- Create date: 31-01-2023
-- Description:	Report includes 2 tables, table 1 is race of head of Hh for different residential statuses. Table 2 is different languages spoken and understood for indian panel homes
-- Last changed: 
-- =============================================

USE EvoProd
GO

DECLARE @refDate DATE = '2023-01-31' --change according to the required period

--/*
--Race of Head of Hh for different Residential statuses
--*/
SELECT
	ra.TextFull AS Race,
	HhRes.[Residential Status],
	COUNT(*) AS [Total]
FROM FUGetInstalledHouseHold(@refDate) p 
INNER JOIN FUGetCharValHistDetails(@refDate,744) ra ON ra.RefEntityID = p.HhID --Race head of household
INNER JOIN 
	(SELECT thm.HhID, c253.TextFull, CASE WHEN c303.CharValue = '1' THEN 'SG Citizens' WHEN c303.CharValue = '2' THEN 'Permanent Residents' ELSE 'Non-Residents' END AS [Residential Status]
	FROM tHhMem thm
	INNER JOIN FUGetCharValHistDetails(@refDate,253) c253 ON thm.HhMemID = c253.RefEntityID --Head of Household
	INNER JOIN FUGetCharValHistDetails(@refDate,303) c303 ON thm.HhMemID = c303.RefEntityID --Residential status
	WHERE c253.TextFull = 'Yes') HhRes ON HhRes.HhID = p.HhID
GROUP BY ra.TextFull,[Residential Status]
ORDER BY ra.TextFull, HhRes.[Residential Status] DESC



/*
-- Different languages understood and spoken for Indian panel homes
*/
SELECT
	*
FROM FUGetInstalledHouseHold(@refDate) p 
INNER JOIN FUGetCharValHistDetails(@refDate,744) ra ON ra.RefEntityID = p.HhID AND ra.TextFull = 'Indian' --Race head of household, Hh level
INNER JOIN 
	(	
		SELECT thm.HhID
			   ,thm.HhMemID
			   ,thm.FirstName
			   ,thm.LastName
			   ,thm.PartOfHhUntil
			   ,c253.TextFull
			   ,CASE WHEN c303.CharValue = '1' THEN 'SG Citizens' WHEN c303.CharValue = '2' THEN 'Permanent Residents' ELSE 'Non-Residents' END AS [Residential Status]
			   ,c268.TextFull as [Understand English]
			   ,c283.TextFull as [Speak English]
			   ,c269.TextFull as [Understand Mandarin]
			   ,c284.TextFull as [Speak Mandarin]
			   ,c270.TextFull as [Understand Malay]
			   ,c285.TextFull as [Speak Malay]
			   ,c271.TextFull as [Understand Tamil]
			   ,c286.TextFull as [Speak Tamil]
			   ,c272.TextFull as [Understand Hindi]
			   ,c287.TextFull as [Speak Hindi]
			   ,c273.TextFull as [Understand Other Indian Languages]
			   ,c288.TextFull as [Speak Other Indian Languages]
			   ,c274.TextFull as [Understand Chinese Dialects]
			   ,c289.TextFull as [Speak Chinese Dialects]
			   ,c275.TextFull as [Understand Other Languages]
			   ,c290.TextFull as [Speak Other Languages]
		FROM tHhMem thm
		INNER JOIN FUGetCharValHistDetails(@refDate,253) c253 ON thm.HhMemID = c253.RefEntityID AND c253.TextFull = 'Yes' --Head of Household, HhMem level
		INNER JOIN FUGetCharValHistDetails(@refDate,303) c303 ON thm.HhMemID = c303.RefEntityID --Residential status, HhMem level
		INNER JOIN FUGetCharValHistDetails(@refDate,268) c268 ON thm.HhMemID = c268.RefEntityID -- english understand, HhMem level
		INNER JOIN FUGetCharValHistDetails(@refDate,283) c283 ON thm.HhMemID = c283.RefEntityID -- english spoken, HhMem level
		INNER JOIN FUGetCharValHistDetails(@refDate,269) c269 ON thm.HhMemID = c269.RefEntityID -- Mandarin understand, HhMem level
		INNER JOIN FUGetCharValHistDetails(@refDate,284) c284 ON thm.HhMemID = c284.RefEntityID -- Mandarin spoken, HhMem level
		INNER JOIN FUGetCharValHistDetails(@refDate,270) c270 ON thm.HhMemID = c270.RefEntityID -- Malay understand, HhMem level
		INNER JOIN FUGetCharValHistDetails(@refDate,285) c285 ON thm.HhMemID = c285.RefEntityID -- Malay spoken, HhMem level
		INNER JOIN FUGetCharValHistDetails(@refDate,271) c271 ON thm.HhMemID = c271.RefEntityID -- Tamil understand, HhMem level
		INNER JOIN FUGetCharValHistDetails(@refDate,286) c286 ON thm.HhMemID = c286.RefEntityID -- Tamil spoken, HhMem level
		INNER JOIN FUGetCharValHistDetails(@refDate,272) c272 ON thm.HhMemID = c272.RefEntityID -- Hindi understand, HhMem level
		INNER JOIN FUGetCharValHistDetails(@refDate,287) c287 ON thm.HhMemID = c287.RefEntityID -- Hindi spoken, HhMem level
		INNER JOIN FUGetCharValHistDetails(@refDate,273) c273 ON thm.HhMemID = c273.RefEntityID -- Other Indian Languages un, HhMem levelderstand
		INNER JOIN FUGetCharValHistDetails(@refDate,288) c288 ON thm.HhMemID = c288.RefEntityID -- Other Indian Languages spoken, HhMem level
		INNER JOIN FUGetCharValHistDetails(@refDate,274) c274 ON thm.HhMemID = c274.RefEntityID -- Chinese Dialects understand, HhMem level
		INNER JOIN FUGetCharValHistDetails(@refDate,289) c289 ON thm.HhMemID = c289.RefEntityID -- Chinese Dialects spoken, HhMem level
		INNER JOIN FUGetCharValHistDetails(@refDate,275) c275 ON thm.HhMemID = c275.RefEntityID -- Other understand, HhMem level, HhMem level
		INNER JOIN FUGetCharValHistDetails(@refDate,290) c290 ON thm.HhMemID = c290.RefEntityID -- Other spoken, HhMem level
	)HhRes ON HhRes.HhID = p.HhID
ORDER BY ra.TextFull, HhRes.[Residential Status] DESC													   





