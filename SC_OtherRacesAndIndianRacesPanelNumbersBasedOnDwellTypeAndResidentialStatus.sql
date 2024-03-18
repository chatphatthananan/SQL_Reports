-- =============================================
-- Author:		Sirikorn
-- Create date: 09 March 2022
-- Description:	Active/installed homes for indian and other races respectively, filtered based on their residential status and also Dwelling Type
-- Last changed:
-- =============================================
USE EvoProd
GO

DECLARE @ReferenceDate AS date

SET @ReferenceDate = GETDATE()

SELECT instHh.HhID,
		CASE WHEN c745.CharValue IN ('1','2') THEN '1-3 rooms'
		WHEN c745.CharValue IN ('3','4') THEN '4-5 rooms'
		WHEN c745.CharValue IN ('5') THEN 'Condominiums and Other Appartments'
		WHEN c745.CharValue IN ('6') THEN 'Landed Properties and Others'
		END AS [Dwelling Type Category]
	--, c745.TextFull AS [C745-Dwelling Type (Start 8.12.2016)]
	, c744.TextFull AS [C744-Household Race]
	, CASE WHEN mem303.TextFull IN ('Singapore Citizen', 'Permanent Resident (PR)') THEN 'R'
		ELSE 'NR'
		END AS [C303-Residential status]
FROM FUGetInstalledHouseHold(@ReferenceDate) instHh
INNER JOIN FUGetCharValHistDetails(@ReferenceDate, 745) c745 ON instHh.HhID = c745.RefEntityID -- dwelling type
INNER JOIN FUGetCharValHistDetails(@ReferenceDate, 744) c744 ON instHh.HhID = c744.RefEntityID -- race of household head
INNER JOIN
(
	SELECT mem.HhID
		, c303.TextFull
	FROM FUGetInstalledHouseHold(@ReferenceDate) instHh
	INNER JOIN tHhMem mem ON instHh.HhID = mem.HhID
	INNER JOIN FUGetCharValHistDetails(@ReferenceDate, 253) c253 ON mem.HhMemID = c253.RefEntityID AND c253.CharValue = '1'
	INNER JOIN FUGetCharValHistDetails(@ReferenceDate, 303) c303 ON mem.HhMemID = c303.RefEntityID
)AS mem303 ON instHh.HhID = mem303.HhID
WHERE c744.TextFull IN ('others')
--WHERE c744.TextFull IN ('Indian')


