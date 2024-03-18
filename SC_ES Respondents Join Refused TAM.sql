---- =============================================
---- Author:		Sirikorn Chatphatthananan
---- Create date:   2 March 2023
---- Description:	ES respondents that joined TAM and also those that refused to join within the given periods, within 2022 and "1st Aug 2022 - 31st Jan 2023"
---- Last Modified: <yyyy-MM-dd, by ???, ??>
---- =============================================

USE EvoProd

GO

DECLARE @2022 DATE = '2022-12-31' --ref date to get char for 2022
DECLARE @P6M DATE = '2023-01-31'  --ref date to get char for P6M (01 Aug 2022 - 31 Jan 2023)
DECLARE @today DATE = GETDATE()
--------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- For ES Respondents that joined TAM / "Installed" wihtin 2022
SELECT 
	tphh.HhID AS [HhID],
	tphh.ParticFrom AS [Join Panel Date],
	tphh.ParticUntil AS [Left Panel Date],
	--tphh.PanelID AS [PanelID],
	c482.TextFull AS [Recruitment Status],
	--c482.CharHistFrom AS [Date Of Recruitment Status],
	CASE 
		WHEN c745.CharValue IN (1,2) THEN '1-3 room flats'
		WHEN c745.CharValue IN (3,4) THEN '4-5 room/exec flats'
		WHEN c745.CharValue IN (5,6) THEN 'Condo/Landed properties'
		ELSE 'N/A'
	END AS [Dwelling Type],
	CASE 
		WHEN c744.CharValue = 1 THEN 'Chinese'
		WHEN c744.CharValue = 2 THEN 'Malay'
		WHEN c744.CharValue = 3 THEN 'Indian'
		WHEN c744.CharValue = 4 THEN 'Others'
		ELSE 'N/A'
	END AS [Race (Head of Household)],
	CASE
		WHEN c101.CharValue = 1 THEN '1 TV Set'
		WHEN c101.CharValue >= 2 THEN '2+ TV Sets'
		WHEN c101.CharValue = 0 AND (SELECT TOP 1 CharValue FROM tCharValHist WHERE CharID = 101 AND RefEntityID = tphh.HhID AND CharValue <> 0 AND @2022 >= CharHistFrom ORDER BY CharHistFrom DESC) = 1 THEN '1 TV Set'
		WHEN c101.CharValue = 0 AND (SELECT TOP 1 CharValue FROM tCharValHist WHERE CharID = 101 AND RefEntityID = tphh.HhID AND CharValue <> 0 AND @2022 >= CharHistFrom ORDER BY CharHistFrom DESC) >= 2 THEN '2+ TV Sets'
		ELSE 'N/A'
	END AS [No Of TV set(s)],
	CASE
		WHEN c712.CharValue BETWEEN 1 AND 3 THEN '1-3 person(s)'
		WHEN c712.CharValue >= 4 THEN '4+ persons'
		WHEN c712.CharValue = 0 AND (SELECT TOP 1 CharValue FROM tCharValHist WHERE CharID = 712 AND RefEntityID = tphh.HhID AND CharValue <> 0 AND @2022 >= CharHistFrom ORDER BY CharHistFrom DESC) BETWEEN 1 and 3 THEN '1-3 person(s)'
		WHEN c712.CharValue = 0 AND (SELECT TOP 1 CharValue FROM tCharValHist WHERE CharID = 712 AND RefEntityID = tphh.HhID AND CharValue <> 0 AND @2022 >= CharHistFrom ORDER BY CharHistFrom DESC) >= 4 THEN '4+ persons'
		ELSE 'N/A'
	END AS [Household Size Include Maids],
	CASE
		WHEN c129.CharValue IN (1,2,3) THEN 'StarHub and/or Singtel'
		WHEN c129.CharValue IN (4) THEN 'No subscription (only terrestrial)'
		ELSE 'N/A'
	END AS [Reception Level],
	c553.TextFull AS [Main Panel/IndianMalay Booster],
	c447.TextFull AS [Recruitment Batch],
	c447.CharHistFrom AS [Recruitment Batch Status Date]
FROM tPanelHh tphh 
INNER JOIN FUGetCharValHistDetails(@2022,482) c482 ON tphh.HhID = c482.RefEntityID AND tphh.ParticFrom BETWEEN '2022-01-01' AND '2022-12-31' AND tphh.PanelID = 1 AND c482.CharValue = 1 -- Recruitment status, filter Hh join in 2022 only
LEFT JOIN FUGetCharValHistDetails(@2022,745) c745 ON tphh.HhID = c745.RefEntityID --c745 dwelling type
LEFT JOIN FUGetCharValHistDetails(@2022,744) c744 ON tphh.HhID = c744.RefEntityID --c744 Race of head of hh
LEFT JOIN FUGetCharValHistDetails(@2022,101) c101 ON tphh.HhID = c101.RefEntityID --c101 No of TV sets
LEFT JOIN FUGetCharValHistDetails(@2022,712) c712 ON tphh.HhID = c712.RefEntityID --c712 hh size include maid
LEFT JOIN FUGetCharValHistDetails(@2022,129) c129 ON tphh.HhID = c129.RefEntityID --c129 reception level HH level
LEFT JOIN FUGetCharValHistDetails(@2022,553) c553 ON tphh.HhID = c553.RefEntityID --c553 mainpanel/indian,malay booster
INNER JOIN FUGetCharValHistDetails(@2022,447) c447 ON tphh.HhID = c447.RefEntityID --c447 recruitment batch

--------------------------------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- For ES Respondents that joined TAM / "Installed" wihtin 1st Aug 2022 to 31st Jan 2023
SELECT 
	tphh.HhID AS [HhID],
	tphh.ParticFrom AS [Join Panel Date],
	tphh.ParticUntil AS [Left Panel Date],
	--tphh.PanelID AS [PanelID],
	c482.TextFull AS [Recruitment Status],
	--c482.CharHistFrom AS [Date Of Recruitment Status],
	CASE 
		WHEN c745.CharValue IN (1,2) THEN '1-3 room flats'
		WHEN c745.CharValue IN (3,4) THEN '4-5 room/exec flats'
		WHEN c745.CharValue IN (5,6) THEN 'Condo/Landed properties'
		ELSE 'N/A'
	END AS [Dwelling Type],
	CASE 
		WHEN c744.CharValue = 1 THEN 'Chinese'
		WHEN c744.CharValue = 2 THEN 'Malay'
		WHEN c744.CharValue = 3 THEN 'Indian'
		WHEN c744.CharValue = 4 THEN 'Others'
		ELSE 'N/A'
	END AS [Race (Head of Household)],
	CASE
		WHEN c101.CharValue = 1 THEN '1 TV Set'
		WHEN c101.CharValue >= 2 THEN '2+ TV Sets'
		WHEN c101.CharValue = 0 AND (SELECT TOP 1 CharValue FROM tCharValHist WHERE CharID = 101 AND RefEntityID = tphh.HhID AND CharValue <> 0 AND @2022 >= CharHistFrom ORDER BY CharHistFrom DESC) = 1 THEN '1 TV Set'
		WHEN c101.CharValue = 0 AND (SELECT TOP 1 CharValue FROM tCharValHist WHERE CharID = 101 AND RefEntityID = tphh.HhID AND CharValue <> 0 AND @2022 >= CharHistFrom ORDER BY CharHistFrom DESC) >= 2 THEN '2+ TV Sets'
		ELSE 'N/A'
	END AS [No Of TV set(s)],
	CASE
		WHEN c712.CharValue BETWEEN 1 AND 3 THEN '1-3 person(s)'
		WHEN c712.CharValue >= 4 THEN '4+ persons'
		WHEN c712.CharValue = 0 AND (SELECT TOP 1 CharValue FROM tCharValHist WHERE CharID = 712 AND RefEntityID = tphh.HhID AND CharValue <> 0 AND @2022 >= CharHistFrom ORDER BY CharHistFrom DESC) BETWEEN 1 and 3 THEN '1-3 person(s)'
		WHEN c712.CharValue = 0 AND (SELECT TOP 1 CharValue FROM tCharValHist WHERE CharID = 712 AND RefEntityID = tphh.HhID AND CharValue <> 0 AND @2022 >= CharHistFrom ORDER BY CharHistFrom DESC) >= 4 THEN '4+ persons'
		ELSE 'N/A'
	END AS [Household Size Include Maids],
	CASE
		WHEN c129.CharValue IN (1,2,3) THEN 'StarHub and/or Singtel'
		WHEN c129.CharValue IN (4) THEN 'No subscription (only terrestrial)'
		ELSE 'N/A'
	END AS [Reception Level],
	c553.TextFull AS [Main Panel/IndianMalay Booster],
	c447.TextFull AS [Recruitment Batch],
	c447.CharHistFrom AS [Recruitment Batch Status Date]
FROM tPanelHh tphh 
INNER JOIN FUGetCharValHistDetails(@P6M,482) c482 ON tphh.HhID = c482.RefEntityID AND tphh.ParticFrom BETWEEN '2022-08-01' AND '2023-01-31' AND tphh.PanelID = 1 AND c482.CharValue = 1 -- Recruitment status, filter Hh join in 2022 only
LEFT JOIN FUGetCharValHistDetails(@P6M,745) c745 ON tphh.HhID = c745.RefEntityID --c745 dwelling type
LEFT JOIN FUGetCharValHistDetails(@P6M,744) c744 ON tphh.HhID = c744.RefEntityID --c744 Race of head of hh
LEFT JOIN FUGetCharValHistDetails(@P6M,101) c101 ON tphh.HhID = c101.RefEntityID --c101 No of TV sets
LEFT JOIN FUGetCharValHistDetails(@P6M,712) c712 ON tphh.HhID = c712.RefEntityID --c712 hh size include maid
LEFT JOIN FUGetCharValHistDetails(@P6M,129) c129 ON tphh.HhID = c129.RefEntityID --c129 reception level HH level
LEFT JOIN FUGetCharValHistDetails(@P6M,553) c553 ON tphh.HhID = c553.RefEntityID --mainpanel/indian,malay booster
INNER JOIN FUGetCharValHistDetails(@P6M,447) c447 ON tphh.HhID = c447.RefEntityID --c447 recruitment batch

--------------------------------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- For ES Respondents that refused TAM  wihtin 2022
SELECT 
	thh.HhID,
	c482.TextFull AS [Recruitment Status],
	c482.CharHistFrom AS [Date Of Recruitment Status],
	CASE 
		WHEN c745.CharValue IN (1,2) THEN '1-3 room flats'
		WHEN c745.CharValue IN (3,4) THEN '4-5 room/exec flats'
		WHEN c745.CharValue IN (5,6) THEN 'Condo/Landed properties'
		ELSE 'N/A'
	END AS [Dwelling Type],
	CASE 
		WHEN c744.CharValue = 1 THEN 'Chinese'
		WHEN c744.CharValue = 2 THEN 'Malay'
		WHEN c744.CharValue = 3 THEN 'Indian'
		WHEN c744.CharValue = 4 THEN 'Others'
		ELSE 'N/A'
	END AS [Race (Head of Household)],
	CASE
		WHEN c101.CharValue = 1 THEN '1 TV Set'
		WHEN c101.CharValue >= 2 THEN '2+ TV Sets'
		ELSE 'N/A'
	END AS [No Of TV set(s)],
	CASE
		WHEN c712.CharValue BETWEEN 1 AND 3 THEN '1-3 person(s)'
		WHEN c712.CharValue >= 4 THEN '4+ persons'
		ELSE 'N/A'
	END AS [Household Size Include Maids],
	CASE
		WHEN c129.CharValue IN (1,2,3) THEN 'StarHub and/or Singtel'
		WHEN c129.CharValue IN (4) THEN 'No subscription (only terrestrial)'
		ELSE 'N/A'
	END AS [Reception Level],
	--c553.TextFull AS [Main Panel/IndianMalay Booster]
	c447.TextFull AS [Recruitment Batch],
	c447.CharHistFrom AS [Recruitment Batch Status Date]
FROM tHh thh
INNER JOIN FUGetCharValHistDetails(@2022,482) c482 ON thh.HhID = c482.RefEntityID AND c482.CharValue = 4 
LEFT JOIN FUGetCharValHistDetails(@2022,745) c745 ON thh.HhID = c745.RefEntityID --c745 dwelling type
LEFT JOIN FUGetCharValHistDetails(@2022,744) c744 ON thh.HhID = c744.RefEntityID --c744 Race of head of hh
LEFT JOIN FUGetCharValHistDetails(@2022,101) c101 ON thh.HhID = c101.RefEntityID --c101 No of TV sets
LEFT JOIN FUGetCharValHistDetails(@2022,712) c712 ON thh.HhID = c712.RefEntityID --c712 hh size include maid
LEFT JOIN FUGetCharValHistDetails(@2022,129) c129 ON thh.HhID = c129.RefEntityID --c129 reception level HH level
--LEFT JOIN FUGetCharValHistDetails(@2022,553) c553 ON thh.HhID = c553.RefEntityID --mainpanel/indian,malay booster
INNER JOIN FUGetCharValHistDetails(@2022,447) c447 ON thh.HhID = c447.RefEntityID AND c447.CharHistFrom BETWEEN '2022-01-01' AND '2022-12-31' --c447 recruitment batch

--------------------------------------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------------------------------------
---- For ES Respondents that refused TAM  wihtin 1st Aug 2022 to 31st Jan 2023
SELECT 
	thh.HhID,
	c482.TextFull AS [Recruitment Status],
	c482.CharHistFrom AS [Date Of Recruitment Status],
	CASE 
		WHEN c745.CharValue IN (1,2) THEN '1-3 room flats'
		WHEN c745.CharValue IN (3,4) THEN '4-5 room/exec flats'
		WHEN c745.CharValue IN (5,6) THEN 'Condo/Landed properties'
		ELSE 'N/A'
	END AS [Dwelling Type],
	CASE 
		WHEN c744.CharValue = 1 THEN 'Chinese'
		WHEN c744.CharValue = 2 THEN 'Malay'
		WHEN c744.CharValue = 3 THEN 'Indian'
		WHEN c744.CharValue = 4 THEN 'Others'
		ELSE 'N/A'
	END AS [Race (Head of Household)],
	CASE
		WHEN c101.CharValue = 1 THEN '1 TV Set'
		WHEN c101.CharValue >= 2 THEN '2+ TV Sets'
		ELSE 'N/A'
	END AS [No Of TV set(s)],
	CASE
		WHEN c712.CharValue BETWEEN 1 AND 3 THEN '1-3 person(s)'
		WHEN c712.CharValue >= 4 THEN '4+ persons'
		ELSE 'N/A'
	END AS [Household Size Include Maids],
	CASE
		WHEN c129.CharValue IN (1,2,3) THEN 'StarHub and/or Singtel'
		WHEN c129.CharValue IN (4) THEN 'No subscription (only terrestrial)'
		ELSE 'N/A'
	END AS [Reception Level],
	--c553.TextFull AS [Main Panel/IndianMalay Booster]
	c447.TextFull AS [Recruitment Batch],
	c447.CharHistFrom AS [Recruitment Batch Status Date]
FROM tHh thh
INNER JOIN FUGetCharValHistDetails(@P6M,482) c482 ON thh.HhID = c482.RefEntityID AND c482.CharValue = 4 AND c482.CharHistFrom BETWEEN '2022-08-01' AND '2023-01-31'
LEFT JOIN FUGetCharValHistDetails(@P6M,745) c745 ON thh.HhID = c745.RefEntityID --c745 dwelling type
LEFT JOIN FUGetCharValHistDetails(@P6M,744) c744 ON thh.HhID = c744.RefEntityID --c744 Race of head of hh
LEFT JOIN FUGetCharValHistDetails(@P6M,101) c101 ON thh.HhID = c101.RefEntityID --c101 No of TV sets
LEFT JOIN FUGetCharValHistDetails(@P6M,712) c712 ON thh.HhID = c712.RefEntityID --c712 hh size include maid
LEFT JOIN FUGetCharValHistDetails(@P6M,129) c129 ON thh.HhID = c129.RefEntityID --c129 reception level HH level
--LEFT JOIN FUGetCharValHistDetails(@P6M,553) c553 ON thh.HhID = c553.RefEntityID --mainpanel/indian,malay booster
INNER JOIN FUGetCharValHistDetails(@P6M,447) c447 ON thh.HhID = c447.RefEntityID AND c447.CharHistFrom BETWEEN '2022-08-01' AND '2023-01-31' --c447 recruitment batch
--------------------------------------------------------------------------------------------------------------------------------------------------------------------



