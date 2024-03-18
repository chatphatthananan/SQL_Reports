USE SGTAMProd
GO

IF OBJECT_ID('tempdb..#tempActive') IS NOT NULL DROP TABLE #tempActive

-- temp table for active users
SELECT a.clientName, b.fullName, b.email, b.team, b.position
INTO #tempActive
FROM tClient a
INNER JOIN tClientUser b ON a.clientID = b.clientID
INNER JOIN tClientUserRole c ON b.clientUserID = c.clientUserID
WHERE a.isEvoClient = 1
AND CAST(GETDATE() AS DATE) BETWEEN a.activeFrom AND a.activeUntil
AND c.userRole = '4'

SELECT * FROM #tempActive
ORDER BY clientName, fullName