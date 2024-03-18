USE EvoProd

--sp_getcharinfo 0,'race'

--sp_getcharinfo 744

SELECT hh.HhID AS HHID, 
CASE WHEN p.ParticUntil >= '2050-12-31' THEN 'Active' ELSE 'Inactive' END AS HHStatus
, p.ParticFrom AS PanelStartDt 
, CASE WHEN p.ParticUntil >= '2050-12-31' THEN CAST(NULLIF('','') as DATE) ELSE p.ParticUntil END AS PanelEndDt 
, CASE WHEN ra.CharValue = '4' THEN 'Others' END AS Race 
, CASE WHEN p.ParticUntil = '2050-12-31' THEN DATEDIFF(day,p.ParticFrom, GETDATE()) ELSE DATEDIFF(day,p.ParticFrom, p.ParticUntil) END AS DaysInPanel
FROM tHh hh
INNER JOIN tPanelHh p ON hh.HhID = p.HhID
INNER JOIN FUGetCharValHistDetails('2021-11-17',744) ra ON ra.RefEntityID = p.HhID
WHERE ra.CharValue = '4'
AND p.ParticFrom >= '2016-01-01'
AND hh.HhID IN (SELECT id.HhID FROM tInstDom id INNER JOIN tInst inst ON id.InstDomID = inst.InstDomID)
ORDER BY HhID

--SELECT GETDATE()

--SELECT hh.HhID AS HHID, 
--CASE WHEN p.ParticUntil >= '2050-12-31' THEN 'Active' ELSE 'Inactive' END AS HHStatus
--, p.ParticFrom AS PanelStartDt 
--, CASE WHEN p.ParticUntil >= '2050-12-31' THEN DATEDIFF(day,p.ParticFrom, GETDATE()) ELSE DATEDIFF(day,p.ParticFrom, p.ParticUntil) END AS DaysInPanel
--, CASE WHEN p.ParticUntil >= '2050-12-31' THEN NULL ELSE p.ParticUntil END AS PanelEndDt 
--, CASE WHEN ra.CharValue = '4' THEN 'Others' END AS Race 
--FROM tHh hh
--INNER JOIN tPanelHh p ON hh.HhID = p.HhID
--INNER JOIN FUGetCharValHistDetails('2021-11-17',744) ra ON ra.RefEntityID = p.HhID
--WHERE ra.CharValue = '4'
--AND p.ParticFrom >= '2016-01-01'
--AND hh.HhID IN (SELECT id.HhID FROM tInstDom id INNER JOIN tInst inst ON id.InstDomID = inst.InstDomID)
--ORDER BY HhID
-- Columns needed = HHID, PanelStartDt, PanelEndDt,Race, DayinPanel(this table self calculation)

--only other race
--active and Inactive since 1 jan 2016
--Other race stay panel period