USE EvoProd

GO


SELECT  td.panel_person_id,
		ta.RespondentPanelStatusCode,
		td.days_last_active,
		td.panel_household_id,
		tm.tags,
		ta.FirstName,
		ta.LastName,
		ta.EmailAddress,
		ta.MobilePhoneNumber,
		td.device_type,
		td.os_type,
		td.manufacturer,
		td.model,
		td.activationCode AS [AccessCode],
		td.last_logfile_sent,
		td.last_activity_date
FROM SGTAMProd.dbo.tWakoopaDevice td
LEFT JOIN SGTAMProd.dbo.tWakoopaMember tm ON td.panel_household_id = tm.panel_household_id -- just to get the tags column
LEFT JOIN SGTAMProd.dbo.tAtlasNewRegistration ta ON td.panel_household_id = ta.RespondentID
WHERE td.ReferenceDate = cast(getdate() as date) 
AND tm.ReferenceDate = cast(getdate() as date)
AND td.days_last_active > 7
AND td.os_type = 'Android'
AND td.panel_person_id = 1
AND ta.RespondentPanelStatusCode = 10
ORDER BY td.panel_household_id, td.days_last_active