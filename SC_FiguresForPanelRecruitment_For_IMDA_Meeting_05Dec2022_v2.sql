-- ================================================================================
-- Author:		Sirikorn Chatphatthananan	
-- Create date: 2022-12-06
-- Description:	Figures For Panel Recruitment
-- Request email title: FW: Figures for Panel Recruitment 
-- Request email date: 2022-12-05 5:54pm
-- Last changed:
-- ================================================================================

USE EvoProd
GO

DECLARE @refdate_2021 date = '2021-01-01'
DECLARE @total_panel_2021 INT = 0
DECLARE @refdate_2022 date = '2022-01-01'
DECLARE @total_panel_2022 INT = 0
DECLARE @today DATE = GETDATE() 

--------------------------------------------------------------------------------------------------------------------------------------
-- To get average panel size for 2021
WHILE (@refdate_2021 <= '2021-12-31')
BEGIN
	SET @total_panel_2021 +=  (SELECT COUNT(*) FROM FUGetInstalledHouseHold(@refdate_2021)) 
	SET @refdate_2021 = DATEADD(DAY, 1, @refdate_2021 )
END
SET @total_panel_2021 = @total_panel_2021 / 365 -- Cut off date until 31st Dec, so only 365 days
SELECT @total_panel_2021 AS [Average Panel Size 2021]
--------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------
-- To get average panel size for 2022
WHILE (@refdate_2022 <= '2022-12-05')
BEGIN
	SET @total_panel_2022 +=  (SELECT COUNT(*) FROM FUGetInstalledHouseHold(@refdate_2022)) 
	SET @refdate_2022 = DATEADD(DAY, 1, @refdate_2022 )
END
SET @total_panel_2022 = @total_panel_2022 / 338 -- Cut off date until 5th Dec, so only 338 days
SELECT @total_panel_2022 [Average Panel Size 2022]
--------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------
-- To get ES Addresses for 2021 and 2022
SELECT COUNT(*) AS [ES Addresses 2021] FROM FUGetCharValHistDetails(@today, 741) WHERE CharValue=16 --2021
SELECT COUNT(*) AS [ES Addresses 2022] FROM FUGetCharValHistDetails(@today, 741) WHERE CharValue=17 --2022
--------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------
-- To get churn number for 2021 and 2022, Churn is uninstalledHh
SELECT COUNT(*) AS [Churn Number 2017] FROM FUGetUninstalledHouseHold(@today) WHERE [Last Uninstallation Date] BETWEEN '2017-01-01' AND '2017-12-31'
SELECT COUNT(*) AS [Churn Number 2018] FROM FUGetUninstalledHouseHold(@today) WHERE [Last Uninstallation Date] BETWEEN '2018-01-01' AND '2018-12-31'
SELECT COUNT(*) AS [Churn Number 2019] FROM FUGetUninstalledHouseHold(@today) WHERE [Last Uninstallation Date] BETWEEN '2019-01-01' AND '2019-12-31'
SELECT COUNT(*) AS [Churn Number 2020] FROM FUGetUninstalledHouseHold(@today) WHERE [Last Uninstallation Date] BETWEEN '2020-01-01' AND '2020-12-31'
SELECT COUNT(*) AS [Churn Number 2021] FROM FUGetUninstalledHouseHold(@today) WHERE [Last Uninstallation Date] BETWEEN '2021-01-01' AND '2021-12-31'
SELECT COUNT(*) AS [Churn Number 2022] FROM FUGetUninstalledHouseHold(@today) WHERE [Last Uninstallation Date] BETWEEN '2022-01-01' AND '2022-12-05'
--------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------
-- To get addresses issued to recruiters
-- 2021
SELECT COUNT(*) AS [Addresses Issued 2021] 
FROM tHh th
INNER JOIN FUGetCharValHistDetails(@today, 447) c447 ON c447.RefEntityID = th.HhID -- Recruitment Batch
INNER JOIN FUGetCharValHistDetails(@today,741) c741 ON c447.RefEntityID = c741.RefEntityID AND c741.CharValue = '16' -- survey version


-- 2022
SELECT COUNT(*) AS [Addresses Issued 2022]  
FROM tHh th
INNER JOIN FUGetCharValHistDetails(@today, 447) c447 ON c447.RefEntityID = th.HhID -- Recruitment Batch
INNER JOIN FUGetCharValHistDetails(@today,741) c741 ON c447.RefEntityID = c741.RefEntityID AND c741.CharValue = '17' -- survey version

--------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------
-- To get addresses contacted
-- 2021
SELECT COUNT(*) AS [Addresses Contacted 2021]  
FROM tHh th
INNER JOIN FUGetCharValHistDetails(@today, 447) c447 ON c447.RefEntityID = th.HhID -- Recruitment Batch
INNER JOIN FUGetCharValHistDetails(@today,741) c741 ON c447.RefEntityID = c741.RefEntityID AND c741.CharValue = '16' -- survey version
INNER JOIN FUGetCharValHistDetails(@today, 482) c482 ON c482.RefEntityID = th.HhID AND c482.CharValue IN (1,2,3,4,5,6,8,9,10,11,12,13,14,15) -- recruitment statuses for "address contacted"

-- 2022
SELECT COUNT(*) AS [Addresses Contacted 2022]  
FROM tHh th
INNER JOIN FUGetCharValHistDetails(@today, 447) c447 ON c447.RefEntityID = th.HhID -- Recruitment Batch
INNER JOIN FUGetCharValHistDetails(@today,741) c741 ON c447.RefEntityID = c741.RefEntityID AND c741.CharValue = '17' -- survey version
INNER JOIN FUGetCharValHistDetails(@today, 482) c482 ON c482.RefEntityID = th.HhID AND c482.CharValue IN (1,2,3,4,5,6,8,9,10,11,12,13,14,15) -- recruitment statuses for "address contacted"
-------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------
-- To get successful recruited , base is addresses contacted
-- 2021
SELECT COUNT(*) AS [Addresses Successfully Recruited 2021]   
FROM tHh th
INNER JOIN FUGetCharValHistDetails(@today, 447) c447 ON c447.RefEntityID = th.HhID -- Recruitment Batch
INNER JOIN FUGetCharValHistDetails(@today,741) c741 ON c447.RefEntityID = c741.RefEntityID AND c741.CharValue = '16' -- survey version
INNER JOIN FUGetCharValHistDetails(@today, 482) c482 ON c482.RefEntityID = th.HhID AND c482.CharValue IN (1) -- recruitment statuses for "address contacted"

-- 2022
SELECT COUNT(*) AS [Addresses Successfully Recruited 2022]   
FROM tHh th
INNER JOIN FUGetCharValHistDetails(@today, 447) c447 ON c447.RefEntityID = th.HhID -- Recruitment Batch
INNER JOIN FUGetCharValHistDetails(@today,741) c741 ON c447.RefEntityID = c741.RefEntityID AND c741.CharValue = '17' -- survey version
INNER JOIN FUGetCharValHistDetails(@today, 482) c482 ON c482.RefEntityID = th.HhID AND c482.CharValue IN (1) -- recruitment statuses for "address contacted"
-------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------
-- To get successful installed , base is successfully recruited
-- 2021
SELECT COUNT(*) AS [Successfully Installed 2021] 
FROM tHh th
INNER JOIN FUGetCharValHistDetails(@today, 447) c447 ON c447.RefEntityID = th.HhID -- Recruitment Batch
INNER JOIN FUGetCharValHistDetails(@today,741) c741 ON c447.RefEntityID = c741.RefEntityID AND c741.CharValue = '16' -- survey version
INNER JOIN FUGetCharValHistDetails(@today, 482) c482 ON c482.RefEntityID = th.HhID AND c482.CharValue IN (1) -- recruitment statuses for "address contacted"

INNER JOIN tPanelHh tph ON c447.RefEntityID = tph.HhID
AND tph.PanelID = '1'

-- 2022
SELECT COUNT(*) AS [Successfully Installed 2022] 
FROM tHh th
INNER JOIN FUGetCharValHistDetails(@today, 447) c447 ON c447.RefEntityID = th.HhID -- Recruitment Batch
INNER JOIN FUGetCharValHistDetails(@today,741) c741 ON c447.RefEntityID = c741.RefEntityID AND c741.CharValue = '17' -- survey version
INNER JOIN FUGetCharValHistDetails(@today, 482) c482 ON c482.RefEntityID = th.HhID AND c482.CharValue IN (1) -- recruitment statuses for "address contacted"

INNER JOIN tPanelHh tph ON c447.RefEntityID = tph.HhID
AND tph.PanelID = '1'
-------------------------------------------------------------------------------------------------------------------------------------

--------------------------------------------------------------------------------------------------------------------------------------
-- To get reason for leaving/uninstallation, select HH from success recruited which are not in succesfully installed and left join the reason for leaving
-- 2021
SELECT th.HhID, c218.TextFull AS [Reason For Leaving 2021]
FROM tHh th
INNER JOIN FUGetCharValHistDetails(@today, 447) c447 ON c447.RefEntityID = th.HhID -- Recruitment Batch
INNER JOIN FUGetCharValHistDetails(@today,741) c741 ON c447.RefEntityID = c741.RefEntityID AND c741.CharValue = '16' -- survey version
INNER JOIN FUGetCharValHistDetails(@today, 482) c482 ON c482.RefEntityID = th.HhID AND c482.CharValue IN (1) -- recruitment statuses for "address contacted"

LEFT JOIN FUGetCharValHistDetails(@today,218) c218 ON c218.RefEntityID = th.HhID -- reason for leaving

WHERE th.HhID NOT IN (
						
						SELECT th.HhID 
						FROM tHh th
						INNER JOIN FUGetCharValHistDetails(@today, 447) c447 ON c447.RefEntityID = th.HhID -- Recruitment Batch
						INNER JOIN FUGetCharValHistDetails(@today,741) c741 ON c447.RefEntityID = c741.RefEntityID AND c741.CharValue = '16' -- survey version
						INNER JOIN FUGetCharValHistDetails(@today, 482) c482 ON c482.RefEntityID = th.HhID AND c482.CharValue IN (1) -- recruitment statuses for "address contacted"
						
						INNER JOIN tPanelHh tph ON c447.RefEntityID = tph.HhID
						AND tph.PanelID = '1'
)


-- 2022
SELECT th.HhID, c218.TextFull AS [Reason For Leaving 2022]
FROM tHh th
INNER JOIN FUGetCharValHistDetails(@today, 447) c447 ON c447.RefEntityID = th.HhID -- Recruitment Batch
INNER JOIN FUGetCharValHistDetails(@today,741) c741 ON c447.RefEntityID = c741.RefEntityID AND c741.CharValue = '17' -- survey version
INNER JOIN FUGetCharValHistDetails(@today, 482) c482 ON c482.RefEntityID = th.HhID AND c482.CharValue IN (1) -- recruitment statuses for "address contacted"

LEFT JOIN FUGetCharValHistDetails(@today,218) c218 ON c218.RefEntityID = th.HhID -- reason for leaving

WHERE th.HhID NOT IN (
						
						SELECT th.HhID 
						FROM tHh th
						INNER JOIN FUGetCharValHistDetails(@today, 447) c447 ON c447.RefEntityID = th.HhID -- Recruitment Batch
						INNER JOIN FUGetCharValHistDetails(@today,741) c741 ON c447.RefEntityID = c741.RefEntityID AND c741.CharValue = '17' -- survey version
						INNER JOIN FUGetCharValHistDetails(@today, 482) c482 ON c482.RefEntityID = th.HhID AND c482.CharValue IN (1) -- recruitment statuses for "address contacted"
						
						INNER JOIN tPanelHh tph ON c447.RefEntityID = tph.HhID
						AND tph.PanelID = '1'
)

-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Reason for leaving , 2017 - 2020, Churn Number for those period Left join Reason for leaving

SELECT FU.HHID, c218.TextFull AS [Reason For Leaving 2017] FROM FUGetUninstalledHouseHold(@today) FU
LEFT JOIN FUGetCharValHistDetails(@today,218) c218 ON c218.RefEntityID = FU.HHID
WHERE [Last Uninstallation Date] BETWEEN '2017-01-01' AND '2017-12-31'

SELECT FU.HHID, c218.TextFull AS [Reason For Leaving 2018] FROM FUGetUninstalledHouseHold(@today) FU
LEFT JOIN FUGetCharValHistDetails(@today,218) c218 ON c218.RefEntityID = FU.HHID
WHERE [Last Uninstallation Date] BETWEEN '2018-01-01' AND '2018-12-31'

SELECT FU.HHID, c218.TextFull AS [Reason For Leaving 2019] FROM FUGetUninstalledHouseHold(@today) FU
LEFT JOIN FUGetCharValHistDetails(@today,218) c218 ON c218.RefEntityID = FU.HHID
WHERE [Last Uninstallation Date] BETWEEN '2019-01-01' AND '2019-12-31'

SELECT FU.HHID, c218.TextFull AS [Reason For Leaving 2020] FROM FUGetUninstalledHouseHold(@today) FU
LEFT JOIN FUGetCharValHistDetails(@today,218) c218 ON c218.RefEntityID = FU.HHID
WHERE [Last Uninstallation Date] BETWEEN '2020-01-01' AND '2020-12-31'

--SELECT FU.HHID, c218.TextFull AS [Reason For Leaving 2021] FROM FUGetUninstalledHouseHold(@today) FU
--LEFT JOIN FUGetCharValHistDetails(@today,218) c218 ON c218.RefEntityID = FU.HHID
--WHERE [Last Uninstallation Date] BETWEEN '2021-01-01' AND '2021-12-31'

--SELECT FU.HHID, c218.TextFull AS [Reason For Leaving 2022] FROM FUGetUninstalledHouseHold(@today) FU
--LEFT JOIN FUGetCharValHistDetails(@today,218) c218 ON c218.RefEntityID = FU.HHID
--WHERE [Last Uninstallation Date] BETWEEN '2022-01-01' AND '2022-12-05'

-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------


--------------------------------------------------------------------------------------------------------------------------------------
-- To get reason for unsuccessful recruitment
-- 2021
--SELECT COUNT(*) AS [Addresses Contacted 2021]  
SELECT th.HhID, c482.TextFull AS [Recruitment Statuses 2021]
FROM tHh th
INNER JOIN FUGetCharValHistDetails(@today, 447) c447 ON c447.RefEntityID = th.HhID -- Recruitment Batch
INNER JOIN FUGetCharValHistDetails(@today,741) c741 ON c447.RefEntityID = c741.RefEntityID AND c741.CharValue = '16' -- survey version
INNER JOIN FUGetCharValHistDetails(@today, 482) c482 ON c482.RefEntityID = th.HhID AND c482.CharValue IN (2,3,4,5,6,8,9,10,11,12,13,14,15) -- recruitment statuses for "address contacted"

-- 2022
--SELECT COUNT(*) AS [Addresses Contacted 2022] 
SELECT th.HhID, c482.TextFull AS [Recruitment Statuses 2022]
FROM tHh th
INNER JOIN FUGetCharValHistDetails(@today, 447) c447 ON c447.RefEntityID = th.HhID -- Recruitment Batch
INNER JOIN FUGetCharValHistDetails(@today,741) c741 ON c447.RefEntityID = c741.RefEntityID AND c741.CharValue = '17' -- survey version
INNER JOIN FUGetCharValHistDetails(@today, 482) c482 ON c482.RefEntityID = th.HhID AND c482.CharValue IN (2,3,4,5,6,8,9,10,11,12,13,14,15) -- recruitment statuses for "address contacted"
-------------------------------------------------------------------------------------------------------------------