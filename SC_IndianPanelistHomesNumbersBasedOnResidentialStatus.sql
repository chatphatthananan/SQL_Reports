-- ================================================================================
-- Author:		Sirikorn Chatphatthananan	
-- Create date: 2022-03-10
-- Description:	Active indian panelists based on their residential status, on some of the dates requested
-- Request email title: FW: SG-TAM Indian resident Universe Proposal: Stabilizing the Indian panel
-- Request email date: 2022-03-09 3:52pm
-- Last changed:
-- ================================================================================
USE EvoProd
GO

IF OBJECT_ID('tempdb..#tempIndHh') IS NOT NULL DROP TABLE #tempIndHh

DECLARE @ReferenceDate DATE = GETDATE()
--DECLARE @d1j DATE = '2022-01-01'
--DECLARE @d10j DATE = '2022-01-10'
--DECLARE @d20j DATE = '2022-01-20'
--DECLARE @d30j DATE = '2022-01-30'
--DECLARE @d10f DATE = '2022-02-10'
--DECLARE @d20f DATE = '2022-02-20'
--DECLARE @d1m DATE = '2022-03-01'
--DECLARE @d8m DATE = '2022-03-08'

SELECT instHh.HhID, 
       CASE WHEN HeadRes.TextFull IN ('Singapore Citizen','Permanent Resident (PR)') THEN 'Resident' ELSE 'Non-Resident' END AS [Residential Status],
	   c744.TextFull AS [Race of Household's Head]
	  --, c741.TextFull AS [Survey Version]
FROM FUGetInstalledHouseHold(@ReferenceDate) instHh
INNER JOIN FUGetCharValHistDetails(@ReferenceDate,744) c744 ON instHh.HhID = c744.RefEntityID -- race of Hh head
--INNER JOIN FUGetCharValHistDetails(@ReferenceDate,741) c741 ON instHh.HhID = c741.RefEntityID AND c741.CharValue = 16  -- Survey version 
INNER JOIN
(
	SELECT instHh.HhID, c303.TextFull FROM
	FUGetInstalledHouseHold(@ReferenceDate) instHh -- installed Hh
	INNER JOIN tHhMem thm ON thm.HhID = instHh.HhID -- tHhMem contains both HhID and HhMemId
	INNER JOIN FUGetCharValHistDetails(@ReferenceDate,253) c253 ON thm.HhMemID = c253.RefEntityID AND c253.CharValue = 1 -- head of household
	INNER JOIN FUGetCharValHistDetails(@ReferenceDate,303) c303 ON thm.HhMemID = c303.RefEntityID -- residential status
) AS HeadRes ON instHh.HhID = HeadRes.HhID
WHERE c744.TextFull = 'Indian' 

