USE SGTAMProd
GO

IF OBJECT_ID('tempdb..#tempPIC') IS NOT NULL DROP TABLE #tempPIC

-- temp table for PIC
SELECT a.clientName
	  ,a.clientID
	  ,b.fullName
	  ,b.email
INTO #tempPIC
FROM tClient a
INNER JOIN tClientUser b ON a.clientID = b.clientID
INNER JOIN tClientUserRole c ON b.clientUserID = c.clientUserID
WHERE a.isEvoClient = 1
AND CAST(GETDATE() AS DATE) BETWEEN a.activeFrom AND a.activeUntil
AND c.userRole = '2'
ORDER BY a.clientName, b.fullName

SELECT * FROM #tempPIC
ORDER BY clientName


