-- Active UserInfo and ClientInfo as of present/today
-- Inactive UserInfo as past 3 months from present/today

--==============--
USE SGTAMProd
--==============--
GO
--===================================================================================================================================================================================--
													--===========================--
													-- Temp table Client Info --

SELECT ROW_NUMBER() OVER(ORDER BY a.activeUntil DESC,ct.refValName,a.ClientName) AS rowNum,
	(SELECT ISNULL(CONVERT(VARCHAR,MAX(z.apptDtTime),105),'')  
	FROM tInstAppt z WHERE z.clientID = a.clientID) AS LastVisit,
		a.ClientName,
		a.clientID,
		ct.refValName AS ClientType,
		CASE WHEN a.activeUntil<=CAST(GETDATE() AS DATE) THEN 'Inactive' ELSE 'Active' END AS ClientStatus,
		sw.refValName AS SoftwareRequired,
		a.locationCountry AS Location,
		(SELECT COUNT(z.clientUserID) FROM tClientUser z INNER JOIN tClientUserRole y ON z.clientUserID = y.clientUserID AND y.userRole = '4'
			WHERE z.clientID = a.clientID AND z.softwareInst IN ('both','evoRep') AND CAST(GETDATE() AS DATE) BETWEEN z.activeFrom AND z.activeUntil) AS [Total # of Users (Reporting)],
		(SELECT COUNT(z.clientUserID) FROM tClientUser z INNER JOIN tClientUserRole y ON z.clientUserID = y.clientUserID AND y.userRole = '4'
			WHERE z.clientID = a.clientID AND z.softwareInst IN ('both','evoAdv') AND CAST(GETDATE() AS DATE) BETWEEN z.activeFrom AND z.activeUntil) AS [Total # of Users (Advertising)],
		ISNULL(pe.refValName,'') AS PELocation,
		ISNULL(dnx.refValName,'') AS DNXLocation,
		ISNULL(bd.refValName,'-') AS BackdataVer,
		ISNULL(repv.refValName,'-') AS EvoReportingVer,
		ISNULL(adVv.refValName,'-') AS EvoAdvertisingVer,
		repPro.NumbLic AS [Concurrent User (EvoRep)],
		advPro.NumbLic AS [Concurrent User (EvoAdv)],
		ISNULL(CONVERT(VARCHAR,repPro.ValidUntil,105),'')  AS [Lic Expiry Date],
		ISNULL(CONVERT(VARCHAR,a.evoSoftwareUninst,105),'') AS [Uninstallation Date],
		ln.TextFull AS [License Used],
		ISNULL(cps.refValName,'-') AS [Using CPS],
		ISNULL(a.cpsUserName,'') AS [CPS Username],
		ISNULL(a.cpsPassword,'') AS [CPS Password]
	INTO #tempClientInformation
	FROM tClient a
	INNER JOIN sRefVal ct ON ct.refType = 'clientType' AND a.clientType = ct.refValID
	INNER JOIN sRefVal sw ON sw.refType = 'evoProduct' AND a.evoSoftwareInst = sw.refValID
	INNER JOIN sRefVal loc ON loc.refType = 'country' AND a.locationCountry = loc.refValID
	LEFT OUTER JOIN sRefVal pe ON pe.refType = 'DNXPELocation' AND a.PELocation= pe.refValID
	LEFT OUTER JOIN sRefVal dnx ON dnx.refType = 'DNXPELocation' AND a.DNXLocation= dnx.refValID
	LEFT OUTER JOIN sRefVal bd ON bd.refType = 'backDataVer' AND a.backdataVer= bd.refValID
	LEFT OUTER JOIN sRefVal repV ON repV.refType = 'evoRepVer' AND a.evoRepVer= repV.refValID
	LEFT OUTER JOIN sRefVal advV ON advV.refType = 'evoAdvVer' AND a.evoAdsVer= advV.refValID
	LEFT OUTER JOIN EvoProd.dbo.tOpFac repLic ON repLic.OpFacID = a.opFacID AND repLic.OpFacID NOT IN (1,2,49,50)
	LEFT OUTER JOIN EvoProd.dbo.tOFProduct repPro ON repLic.OpFacID = repPro.OpFacID AND repPro.ProductID = 12	--Reporting
	LEFT OUTER JOIN EvoProd.dbo.tText ln ON repLic.TextID = ln.TextID AND ln.CultureCode = 'en-US'
	LEFT OUTER JOIN EvoProd.dbo.tOpFac advLic ON advLic.OpFacID = a.opFacID AND advLic.OpFacID NOT IN (1,2,49,50)
	LEFT OUTER JOIN EvoProd.dbo.tOFProduct advPro ON advLic.OpFacID = advPro.OpFacID AND advPro.ProductID = 10	--Advertising
	LEFT OUTER JOIN sRefVal cps ON cps.refType = 'isCPSDeploy' AND a.isCPSDeploy= cps.refValID
	WHERE a.isEvoClient = 1 AND CAST(GETDATE() AS DATE) BETWEEN a.activeFrom AND a.activeUntil
	order by  a.activeUntil DESC,ct.refValName,a.ClientName

ALTER TABLE #tempClientInformation ALTER COLUMN [Concurrent User (EvoAdv)] VARCHAR(50)
ALTER TABLE #tempClientInformation ALTER COLUMN [Concurrent User (EvoRep)] VARCHAR(50)

UPDATE #tempClientInformation 
SET [Concurrent User (EvoAdv)] = CASE WHEN clientID IN (29, 51) THEN 'Use TechEdge' 
									  WHEN clientID = 45 THEN CONCAT('Up to ', [Concurrent User (EvoAdv)]) ELSE [Concurrent User (EvoAdv)]
END

UPDATE #tempClientInformation 
SET [Concurrent User (EvoRep)] = CASE WHEN clientID IN (29, 51) THEN 'Use TechEdge' 
									  WHEN clientID = 45 THEN CONCAT('Up to ', [Concurrent User (EvoRep)]) ELSE [Concurrent User (EvoRep)]
END

SELECT ClientName AS [Client Name]
, CASE WHEN SoftwareRequired = 'Evo Rep' THEN 'Evogenius Reporting'
     WHEN SoftwareRequired = 'Both' THEN 'Evogenius Reporting & Advertising'
	   WHEN SoftwareRequired = 'Not Required (Use TechEdge Data)' THEN 'Evogenius is not required, use TechEdge' END AS [Software Installed]
, [Concurrent User (EvoAdv)] AS [No. of concurrent licenses set in Evogenius Advertising]
, [Concurrent User (EvoRep)] AS [No. of concurrent licenses set in Evogenius Reporting]
, CASE WHEN PELocation = 'Network' THEN 'Server'
	   WHEN PELocation = 'Local' THEN 'Local PC'
	   WHEN PELocation = 'Both' THEN 'Both' 
	   WHEN PELocation = '' THEN 'Not Applicable'  END AS [Evogenius location]
FROM #tempClientInformation
ORDER BY [Client Name]
--===================================================================================================================================================================================--

--===================================================================================================================================================================================--
															--===========================--
															-- Temp table Client User --

SELECT a.ClientName,ct.refValName AS ClientType,sw.refValName AS SoftwareRequired,
	b.fullName,ISNULL(b.email,'') AS Email,ISNULL(b.team,'') AS Team,ISNULL(b.position,'') AS Position, 
	(CASE WHEN EXISTS(SELECT z.clientUserRoleID FROM tClientUserRole z WHERE z.clientUserID = b.clientUserID AND z.userRole = '1') THEN 'Yes' ELSE 'No' END) AS getDNXEmail,
	(CASE WHEN EXISTS(SELECT z.clientUserRoleID FROM tClientUserRole z WHERE z.clientUserID = b.clientUserID AND z.userRole = '2') THEN 'Yes' ELSE 'No' END) AS isClientPIC,
	(CASE WHEN EXISTS(SELECT z.clientUserRoleID FROM tClientUserRole z WHERE z.clientUserID = b.clientUserID AND z.userRole = '3') THEN 'Yes' ELSE 'No' END) AS isITAdmin,
	(CASE WHEN EXISTS(SELECT z.clientUserRoleID FROM tClientUserRole z WHERE z.clientUserID = b.clientUserID AND z.userRole = '4') THEN 'Yes' ELSE 'No' END) AS isEvoUser,
	ISNULL(b.remarks,'') AS InternalRemarks,
	ISNULL(b.externalRemarks, '') AS Remarks
	INTO #tempClientUser
	FROM tClient a
	INNER JOIN tClientUser b ON a.clientID = b.clientID
	INNER JOIN sRefVal ct ON ct.refType = 'clientType' AND a.clientType = ct.refValID
	INNER JOIN sRefVal sw ON sw.refType = 'evoProduct' AND a.evoSoftwareInst = sw.refValID
	INNER JOIN sRefVal loc ON loc.refType = 'country' AND a.locationCountry = loc.refValID
	WHERE a.isEvoClient = 1 AND CAST(GETDATE() AS DATE) BETWEEN a.activeFrom AND a.activeUntil
	AND b.clientUserID IN (SELECT z.clientUserID FROM tClientUserRole z WHERE z.userRole = '4')
	ORDER BY a.clientType, a.clientName,b.fullName

SELECT ClientName AS [Client's name]
, fullName AS [User's name]
, Email
, CASE WHEN Remarks = '' THEN '-' ELSE Remarks END AS Remarks
FROM #tempClientUser
ORDER BY [Client's name], [User's name]

--===================================================================================================================================================================================--

--===================================================================================================================================================================================--
															--==================================--
															-- Temp table inactive Client User --

SELECT a.ClientName,ct.refValName AS ClientType, sw.refValName AS SoftwareRequired,b.lastUpdDt,
	b.fullName,ISNULL(b.email,'') AS Email,ISNULL(b.team,'') AS Team,ISNULL(b.position,'') AS Position, 
	(CASE WHEN EXISTS(SELECT z.clientUserRoleID FROM tClientUserRole z WHERE z.clientUserID = b.clientUserID AND z.userRole = '1') THEN 'Yes' ELSE 'No' END) AS getDNXEmail,
	(CASE WHEN EXISTS(SELECT z.clientUserRoleID FROM tClientUserRole z WHERE z.clientUserID = b.clientUserID AND z.userRole = '2') THEN 'Yes' ELSE 'No' END) AS isClientPIC,
	(CASE WHEN EXISTS(SELECT z.clientUserRoleID FROM tClientUserRole z WHERE z.clientUserID = b.clientUserID AND z.userRole = '3') THEN 'Yes' ELSE 'No' END) AS isITAdmin,
	(CASE WHEN EXISTS(SELECT z.clientUserRoleID FROM tClientUserRole z WHERE z.clientUserID = b.clientUserID AND z.userRole = '4') THEN 'Yes' ELSE 'No' END) AS isEvoUser,
	ISNULL(b.remarks,'') AS InternalRemarks,
	ISNULL(b.externalRemarks, '') AS Remarks
	INTO #tempInactiveClientUser
	FROM tClient a
	INNER JOIN tClientUser b ON a.clientID = b.clientID
	INNER JOIN sRefVal ct ON ct.refType = 'clientType' AND a.clientType = ct.refValID
	INNER JOIN sRefVal sw ON sw.refType = 'evoProduct' AND a.evoSoftwareInst = sw.refValID
	INNER JOIN sRefVal loc ON loc.refType = 'country' AND a.locationCountry = loc.refValID
	WHERE 
	a.isEvoClient = 1 
	AND CAST(GETDATE() AS DATE) BETWEEN a.activeFrom AND a.activeUntil
	AND b.clientUserID IN (SELECT z.clientUserID FROM tClientUserRole z WHERE z.userRole = '99')
	--AND b.lastUpdDt between '2021-08-24' AND '2021-11-24'
	AND b.lastUpdDt >=	DATEADD(M,-3,GETDATE()) -- only filter from today back to past 3 months	
	ORDER BY a.clientType, a.clientName,b.fullName

SELECT ClientName AS [Client's name]
, fullName AS [User's name]
, Email
, CASE WHEN Remarks = '' THEN '-' ELSE Remarks END AS Remarks
FROM #tempInactiveClientUser
ORDER BY [Client's name], [User's name]
--===================================================================================================================================================================================--