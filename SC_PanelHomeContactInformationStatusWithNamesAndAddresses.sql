-- =============================================
-- Author:		Sirikorn Chatphatthananan
-- Create date: 15 March 2022
-- Description:	Current Panel Home Contact Information Status, with Names and Addresses
-- Last modified: 
-- Notes: Adapted from EY_PanelHomeContactInformationStatus.sql, added Names and Adddresses
--			AiNi only needs the HhId , Names and Addresses
-- =============================================

USE EvoProd

DECLARE @refDate DATE = GETDATE()

IF OBJECT_ID('tempdb..#tmp') IS NOT NULL DROP TABLE #tmp

SELECT th.HhID
	 , thm.HhMemID	 
	 , thm.FirstName
	 , thm.LastName
	 , tad.AddrLine2 AS [Block Number]
	 , tad.AddrLine1 AS Street
	 , tad.AddrLine4 AS [Unit Number]
	 , tad.ZipCode
	 , ISNULL(c60.TextFull, -1) AS Age
	 , ISNULL(hmc.HHMem_Email, '') AS [Email]
	 , hmc.HHMem_MOB AS [Mobile phone number]
	 , CASE WHEN resp.HhMemID = thm.HhMemID AND hmc.HH_Land <> '' THEN hmc.HH_Land ELSE '' END AS [Landline]
	 , CASE WHEN resp.HhMemID = thm.HhMemID THEN 'Yes' ELSE 'No' END AS [Respondent]
	 , CASE WHEN @refDate BETWEEN thm.PartOfHhFrom AND thm.PartOfHhUntil THEN 'Active' ELSE 'Inactive' END AS [Member Status]
INTO #tmp
FROM tHh th
INNER JOIN FUGetInstalledHouseHold(@refDate) inst ON inst.hhid = th.HhID
INNER JOIN tHhMem thm ON thm.HhID = th.HhID
INNER JOIN tAddress tad ON th.AddrID = tad.AddrID
INNER JOIN FUGetCharValHistDetails(@refDate, 251) c251 ON c251.RefEntityID = thm.HhMemID AND c251.CharValue = '1' -- Live-in Member
LEFT JOIN FUGetCharValHistDetails(@refDate, 60) c60 ON c60.RefEntityID = thm.HhMemID	-- Age
LEFT JOIN FUGetRespondent(@refDate) resp ON resp.HhID = th.HhID							-- Respondent
LEFT JOIN FUGetHHMemContact() hmc ON hmc.HHID = th.HhID AND hmc.HhMemID = thm.HhMemID	-- Member Contact Information
WHERE @refDate BETWEEN thm.PartOfHhFrom AND thm.PartOfHhUntil 
OR (resp.HhMemID = thm.HhMemID AND resp.[Member Status] = 'Inactive' AND @refDate NOT BETWEEN thm.PartOfHhFrom AND thm.PartOfHhUntil) -- to retrieve inactive respondent


/*-- clean and categorise Mobile phone number
IF OBJECT_ID('tempdb..#tmpCleaned') IS NOT NULL DROP TABLE #tmpCleaned

SELECT z.*
	 , CASE WHEN (z.Split_MobilePhoneNumber LIKE '8%' OR z.Split_MobilePhoneNumber LIKE '9%') AND LEN(z.Split_MobilePhoneNumber) = 8 THEN 'Mobile' 
			WHEN z.Split_MobilePhoneNumber LIKE '6%' AND LEN(z.Split_MobilePhoneNumber) = 8 THEN 'Landline'
			ELSE '' END AS [Mobile Type]
INTO #tmpCleaned
FROM (
	SELECT a.HhID
		 , a.HhMemID
		 , a.Age
		 , a.Respondent
		 , a.Email
		 , a.[Mobile phone number]
		 , ISNULL(LTRIM(REPLACE(REPLACE(REPLACE(m.[value], '(M)',''), '(O)',''), '(H)','')), '') AS Split_MobilePhoneNumber
	FROM #tmp a
	OUTER APPLY fn_Split(a.[Mobile phone number],',') m -- split mobile phone number
) z

-- raw
SELECT *
FROM #tmpCleaned
*/

-- raw
SELECT HhID, FirstName, LastName, [Block Number], Street, [Unit Number], ZipCode
FROM #tmp
WHERE Respondent = 'Yes'
ORDER BY HhID, HhMemID



-- Total no. of Live HH //Installed
SELECT 'Total no. of Live HH' AS Category
	 , COUNT(*) AS Total
FROM (
	SELECT HhID
	FROM #tmp
	GROUP BY HhID
) a

UNION ALL

-- main contact don't have mobile number, at least one other HH member have a valid mobile number.
SELECT 'main contact dont have mobile number, at least one other HH member have a valid mobile number' AS Category
	 , COUNT(*) AS Total
FROM (
	SELECT a.*
		 , (SELECT COUNT(*) FROM #tmp z WHERE z.HhID = a.HhID AND z.Respondent = 'No' AND z.[Mobile phone number] <> '') AS NonMCHasMobileCount
	FROM #tmp a
	WHERE a.HhID NOT IN (
		-- exclude main contact with mobile number
		SELECT HhID
		FROM #tmp a
		WHERE a.Respondent = 'Yes' AND a.[Mobile phone number] = ''
	)
	AND a.Respondent = 'Yes'
) a
WHERE NonMCHasMobileCount <> 0

UNION ALL

-- main contact don't have email, , at least one other HH member have a valid email.
SELECT 'main contact dont have email, , at least one other HH member have a valid email' AS Category
	 , COUNT(*) AS Total
FROM (
	SELECT a.*
		 , (SELECT COUNT(*) FROM #tmp z WHERE z.HhID = a.HhID AND z.Respondent = 'No' AND z.Email <> '') AS NonMCHasEmailCount
	FROM #tmp a
	WHERE a.HhID NOT IN (
		-- exclude main contact with email
		SELECT HhID
		FROM #tmp a
		WHERE a.Respondent = 'Yes' AND a.Email <> ''
	)
	AND a.Respondent = 'Yes'
) a
WHERE NonMCHasEmailCount <> 0

UNION ALL

-- main contact don't have both mobile number and email (some hh might appear on two tables above as other members have valid mobile and email)
SELECT 'main contact dont have both mobile number and email' AS Category
	 , COUNT(*) AS Total
FROM #tmp a
WHERE a.HhID NOT IN (
	SELECT HhID
	FROM #tmp a
	WHERE (a.Email <> ''
	OR a.[Mobile phone number] <> '')
	AND a.Respondent = 'Yes'
)
AND a.Respondent = 'Yes'
AND a.HhID NOT IN (
	SELECT HhID
	FROM (
		SELECT a.*
			 , (SELECT COUNT(*) FROM #tmp z WHERE z.HhID = a.HhID AND z.Respondent = 'No' AND z.[Mobile phone number] <> '') AS NonMCHasMobileCount
		FROM #tmp a
		WHERE a.HhID NOT IN (
			-- exclude main contact with mobile number
			SELECT HhID
			FROM #tmp a
			WHERE a.Respondent = 'Yes' AND a.[Mobile phone number] <> ''
		)
		AND a.Respondent = 'Yes'
	) a
	WHERE NonMCHasMobileCount <> 0

	UNION ALL

	SELECT HhID
	FROM (
		SELECT a.*
			 , (SELECT COUNT(*) FROM #tmp z WHERE z.HhID = a.HhID AND z.Respondent = 'No' AND z.Email <> '') AS NonMCHasEmailCount
		FROM #tmp a
		WHERE a.HhID NOT IN (
			-- exclude main contact with email
			SELECT HhID
			FROM #tmp a
			WHERE a.Respondent = 'Yes' AND a.Email <> ''
		)
		AND a.Respondent = 'Yes'
	) a
	WHERE NonMCHasEmailCount <> 0
)

UNION ALL

-- HH (all members) don't have mobile number and email ; only residence phone number.
SELECT 'HH (all members) dont have mobile number and email ; only residence phone number' AS Category
	 , COUNT(*) AS Total
FROM #tmp a
WHERE a.HhID NOT IN (
	SELECT HhID
	FROM #tmp a
	WHERE a.Email <> ''
	OR a.[Mobile phone number] <> ''
)
AND a.Landline <> ''