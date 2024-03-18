-- =============================================
-- Author:		Sirikorn Chatphatthananan 
-- Create date: 25 January 2022
-- Description:	AES 2021 Other races Homes
-- Last changed:
-- =============================================

/*
Adapted from "D:\05. Data Production\SQL\EY_AES2021IndianHomes.sql"
- Total others homes with at least 1 TV
- Total contacted others homes
- Total left to be recruited others homes
*/
USE EvoProd
GO

IF OBJECT_ID('tempdb..#tmpIndianHomes') IS NOT NULL DROP TABLE #tmpIndianHomes

	DECLARE @refDate DATE = GETDATE()
	--DECLARE @refDate DATE = '2022-01-20'

	-- Final	
	SELECT th.HhID
		 , c744.TextFull												AS [Household Race]
		 , ISNULL(c129.CharValue
					, CASE WHEN ISNULL(c102.CharValue, 2) = '1' AND ISNULL(c105.CharValue, 2) = '2' THEN 1				   
						   WHEN ISNULL(c102.CharValue, 2) = '2' AND ISNULL(c105.CharValue, 2) = '1' THEN 2
						   WHEN ISNULL(c102.CharValue, 2) = '1' AND ISNULL(c105.CharValue, 2) = '1' THEN 3
						   WHEN ISNULL(c102.CharValue, 2) = '2' AND ISNULL(c105.CharValue, 2) = '2' THEN 4
						   END) AS [Reception Level Code]
		 , c101.CharValue												AS [No of TV Sets]
		 , CASE WHEN c195.CharValue IN ('2','3','4')	THEN 1
						WHEN c195.CharValue = '5'				THEN 2
						WHEN c195.CharValue = '6'				THEN 3
						WHEN c195.CharValue IN ('7','8','9')	THEN 4
						WHEN c195.CharValue IN ('10','11','12') THEN 5
						WHEN c195.CharValue IN ('1','13')		THEN 6
						END AS [Dwelling Type Code]
		 , c712z.CharValue												AS [Household Size]
		 , ISNULL(c447.CharValue, 'NA')									AS [Recruitment Batch]
		 , ISNULL(c482.TextFull, 'Not Visited Yet/Open')				AS [Recruitment Status]
		 , ISNULL(c472.TextFull, 'NA')									AS [Recruiter]
		 , c741.TextFull												AS [Survey Version]		
		 , CASE WHEN (c482.CharValue NOT IN ('1','3','4','11','12','13','14','15') OR c482.CharValue IS NULL) 
						AND c101.CharValue <> '0' AND rbatch.HhID IS NULL THEN 'Available'
				ELSE 'Not Available' END AS [Type]
		 , CASE WHEN rbatch.HhID IS NOT NULL THEN 'Yes' ELSE 'No' END AS [Active Recruitment Batch]
	INTO #tmpOthersHomes
	FROM tHh th
	INNER JOIN FUGetCharValHistDetails(@refDate, 741) c741 ON c741.RefEntityID = th.HhID AND c741.CharValue NOT IN ('4','5','6') -- Survey Version
	INNER JOIN (
		SELECT thm.HHID
				, c265.CharValue
				, c265.TextFull
				, c253.CharHistFrom
				, ROW_NUMBER() OVER (PARTITION BY thm.HhID ORDER BY c253.CharHistFrom) AS RN
		FROM tHhMem thm
		INNER JOIN dbo.FUGetCharValHistDetails (@refDate, 253) c253 ON thm.HHMemID = c253.RefEntityID AND c253.CharValue = '1' -- Head of Household
		INNER JOIN dbo.FUGetCharValHistDetails (@refDate, 265) c265 ON thm.HHMemID = c265.RefEntityID -- Race
		WHERE thm.HHID >= 10000
	) c744 ON c744.HhID = th.HhID AND c744.RN = 1
	LEFT JOIN FUGetCharValHistDetails(@refDate, 129) c129 ON c129.RefEntityID = th.HhID -- Reception Level
	LEFT JOIN FUGetCharValHistDetails(@refDate, 102) c102 ON c102.RefEntityID = th.HhID -- Starhub subscription
	LEFT JOIN FUGetCharValHistDetails(@refDate, 105) c105 ON c105.RefEntityID = th.HhID	-- Singtel subscription
	LEFT JOIN FUGetCharValHistDetails(@refDate, 101) c101 ON c101.RefEntityID = th.HhID -- No of TV Sets
	LEFT JOIN dbo.FUGetCharValHistDetails(@refDate, 195) c195 ON th.HhID = c195.RefEntityID
	LEFT JOIN (
		SELECT th.HhID
			 , CASE WHEN c712.CharValue = '0'  THEN CAST(ISNULL(c198.CharValue, 0) AS INT) + CAST(ISNULL(c199.CharValue, 0) AS INT) 
					WHEN c741.CharValue < 12 THEN c712.CharValue					
					ELSE CAST(ISNULL(c198.CharValue, 0) AS INT) + CAST(ISNULL(c199.CharValue, 0) AS INT) 
					END AS CharValue
		FROM tHh th
		INNER JOIN FUGetCharValHistDetails(@refDate, 741) c741 ON c741.RefEntityID = th.HhID AND c741.CharValue NOT IN ('4','5','6') -- Survey Version
		INNER JOIN FUGetCharValHistDetails(@refDate, 712) c712 ON c712.RefEntityID = th.HhID -- Household Size include maids (Start 8.12.2016)		
		LEFT JOIN FUGetCharValHistDetails(@refDate, 198) c198 ON c198.RefEntityID = th.HhID -- HH Size Family only 
		LEFT JOIN FUGetCharValHistDetails(@refDate, 199) c199 ON c199.RefEntityID = th.HhID	-- HH Size Live-in maids only				
	) c712z  ON c712z.HhID  = th.HhID -- Household Size
	LEFT JOIN FUGetCharValHistDetails(@refDate, 447) c447 ON c447.RefEntityID = th.HhID -- Recruitment Selection
	LEFT JOIN FUGetCharValHistDetails(@refDate, 482) c482 ON c482.RefEntityID = th.HhID -- Recruitment Status
	LEFT JOIN FUGetCharValHistDetails(@refDate, 472) c472 ON c472.RefEntityID = th.HhID -- Recruiter
	LEFT JOIN FUGetActiveRecruitmentBatch(@refDate) rbatch ON rbatch.HhID = th.HhID -- Active Recruitment Batch	
	WHERE th.HhID >= 10000
	AND c741.CharValue = '16' -- this is to indicate from which year is the recruitment batch from, 16 is 2021 Q1
	--AND c744.CharValue = '3'
	AND c744.CharValue = '4'
	--AND (c482.CharValue NOT IN ('1','3','4','11','12','13','14','15') OR c482.CharValue IS NULL) AND c101.CharValue <> '0'
	--AND rbatch.HhID IS NULL

	SELECT a.HhID
	 , a.[Household Race]
	 , CASE WHEN a.[Reception Level Code] = '4' THEN 'No subscription (only terrestrial)'
			WHEN a.[Reception Level Code] <> '4' THEN 'StarHub and/or Singtel'
			END AS [Reception Level]
	 , CASE WHEN a.[No of TV Sets] = '1' THEN '1 TV Set'
			WHEN a.[No of TV Sets] > 1 THEN '2+ TV Sets'
			ELSE '0 TV Set' END AS [TV Sets]
	 , CASE WHEN a.[Dwelling Type Code] IN ('1','2') THEN '1-3 room flats'
			WHEN a.[Dwelling Type Code] IN ('3','4') THEN '4-5 room/exec flats'
			WHEN a.[Dwelling Type Code] IN ('5','6') THEN 'Condo/Landed properties'
			END AS [Dwelling Type]
	 , CASE WHEN a.[Household Size] BETWEEN 1 AND 3 THEN '1-3 Persons'
			WHEN a.[Household Size] >= 4 THEN '4+ Persons'
			END AS [HH Size]
	 , a.[Recruitment Batch]
	 , a.[Recruitment Status]
	 , a.Recruiter
	 , a.[Survey Version]
	 , a.Type
	 , a.[Active Recruitment Batch]
	FROM #tmpOthersHomes a


	-- TOTAL
	SELECT COUNT(*) AS [TOTAL] FROM #tmpOthersHomes

	-- TOTAL WITH 0 TV SET
	SELECT COUNT(*) AS [0 TV SET] FROM #tmpOthersHomes WHERE [No of TV Sets] = 0

	-- TOTAL (EXCLUDE THOSE 0 TV SET)
	SELECT COUNT(*) AS [TOTAL WITH >=1 TV] FROM #tmpOthersHomes WHERE [No of TV Sets] <> 0

	-- Contacted
	SELECT COUNT(*) AS [CONTACTED] FROM #tmpOthersHomes WHERE [No of TV Sets] <> 0 AND [Recruitment Batch] NOT IN ('NA')

	-- LEFT FOR FURTHER RECRUITMENT
	SELECT COUNT(*) AS [LEFT FOR FURTHER RECRUITMENT] FROM #tmpOthersHomes WHERE [No of TV Sets] <> 0 AND [Recruitment Batch] IN ('NA')



