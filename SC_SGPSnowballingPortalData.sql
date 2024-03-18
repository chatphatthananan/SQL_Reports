-- =============================================
-- Author:		Sirikorn Chatphatthananan 
-- Create date: 12 April 2022
-- Description:	Snowballing data for Louise,she requested it on 11 April 2022 3:23PM
-- Details: We would like to request for a file for members joining us under ID:22965 =  “SGP_Snowballing_Portal” under “Refer-a-friend”, data file similar to Reprofiling data but adding one more column for age. 
-- =============================================

USE EvoProd
GO

DECLARE @ReferenceDate DATE = GETDATE()

SELECT thm.HhID
	  ,thm.HhMemID
	  ,c691.CharValue AS [RespondentID]
	  ,c60.CharValue AS [Age]
	  ,c265.TextFull AS [Race]
	  ,c1122.TextFull AS [Education (Start 13.9.2018)]
	  ,c303.TextFull AS [Residential status]
	  ,c1194.TextFull AS [Desktop Device Possession]
	  ,c1195.TextFull AS [Laptop Device Possession]
	  ,c1196.TextFull AS [Tablet Device Posession]
	  ,c1197.TextFull AS [Smartphone Device Posession]
	  ,c257.TextFull AS [Marital Status]
	  ,c258.TextFull AS [Child(ren) 0-3 years]
	  ,c259.TextFull AS [Child(ren) 4-9 years]
	  ,c260.TextFull AS [Child(ren) 10-12 years]
	  ,c261.TextFull AS [Child(ren) 13-14 years]
	  ,c262.TextFull AS [Child(ren) 15-19 years]
	  ,c263.TextFull AS [Child(ren) 20+ years]
	  ,c264.TextFull AS [Not a parent]
	  ,c685.CharValue AS [Number of Child(ren) 0-3 years]
	  ,c686.CharValue AS [Number of Child(ren) 4-9 years]
	  ,c687.CharValue AS [Number of Child(ren) 10-12 years]
	  ,c688.CharValue AS [Number of Child(ren) 13-14 years]
	  ,c689.CharValue AS [Number of Child(ren) 15-19 years]
	  ,c690.CharValue AS [Number of Child(ren) 20+ years]
	  ,c268.TextFull AS [Understand English]
	  ,c269.TextFull AS [Understand Mandarin]
	  ,c270.TextFull AS [Understand Malay]
	  ,c271.TextFull AS [Understand Tamil]
	  ,c272.TextFull AS [Understand Hindi]
	  ,c273.TextFull AS [Understand Other Indian Languages]
	  ,c274.TextFull AS [Understand Chinese dialects]
	  ,c275.TextFull AS [Understand Other languages]
	  ,c283.TextFull AS [Speak English]
	  ,c284.TextFull AS [Speak Mandarin]
	  ,c285.TextFull AS [Speak Malay]
	  ,c286.TextFull AS [Speak Tamil]
	  ,c287.TextFull AS [Speak Hindi]
	  ,c288.TextFull AS [Speak Other Indian Languages]
	  ,c289.TextFull AS [Speak Chinese dialects]
	  ,c290.TextFull AS [Speak Other languages]
	  ,c1120.TextFull AS [Most spoken language (Start 13.9.2018)] 
	  ,c1121.TextFull AS [Second most spoken language (Start 13.9.2018)] 
	  ,c302.TextFull AS [Occupation ES]
	  ,c195.TextFull AS [House Flat type]
	  ,c115.TextFull AS [Others - HH has not connected to Internet]

FROM tHhMem thm
INNER JOIN FUGetCharValHistDetails(@ReferenceDate, 1200) c1200 ON c1200.RefEntityID = thm.HhMemID AND c1200.CharValue='110'
INNER JOIN FUGetCharValHistDetails(@ReferenceDate, 691) c691 ON c691.RefEntityID = thm.HhMemID --c691 is LDMLAMIHhID or RespondentID/AtlasID
LEFT JOIN FUGetCharValHistDetails(@ReferenceDate, 60) c60 ON c60.RefEntityID = thm.HhMemID --c60 is age
LEFT JOIN FUGetCharValHistDetails(@ReferenceDate, 265) c265 ON c265.RefEntityID = thm.HhMemID --c265 is race
LEFT JOIN FUGetCharValHistDetails(@ReferenceDate, 1122) c1122 ON c1122.RefEntityID = thm.HhMemID --c1122 is education start 2018
LEFT JOIN FUGetCharValHistDetails(@ReferenceDate, 303) c303 ON c303.RefEntityID = thm.HhID --c303 residential status
LEFT JOIN FUGetCharValHistDetails(@ReferenceDate, 1194) c1194 ON c1194.RefEntityID = thm.HhMemID --c1194 is Desktop Device Possession
LEFT JOIN FUGetCharValHistDetails(@ReferenceDate, 1195) c1195 ON c1195.RefEntityID = thm.HhMemID --c1195 is Laptop device possession
LEFT JOIN FUGetCharValHistDetails(@ReferenceDate, 1196) c1196 ON c1196.RefEntityID = thm.HhMemID --C1196 is Tblet device posession
LEFT JOIN FUGetCharValHistDetails(@ReferenceDate, 1197) c1197 ON c1197.RefEntityID = thm.HhMemID --c1197 is Phone device possession
LEFT JOIN FUGetCharValHistDetails(@ReferenceDate, 257) c257 ON c257.RefEntityID = thm.HhMemID --c257 Marital status
LEFT JOIN FUGetCharValHistDetails(@ReferenceDate, 258) c258 ON c258.RefEntityID = thm.HhMemID --c258 Child(ren) 0-3 years
LEFT JOIN FUGetCharValHistDetails(@ReferenceDate, 259) c259 ON c259.RefEntityID = thm.HhMemID --c259 is Child(ren) 4-9 years
LEFT JOIN FUGetCharValHistDetails(@ReferenceDate, 260) c260 ON c260.RefEntityID = thm.HhMemID --c260 is children 10-12
LEFT JOIN FUGetCharValHistDetails(@ReferenceDate, 261) c261 ON c261.RefEntityID = thm.HhMemID --c261 is children 13-14
LEFT JOIN FUGetCharValHistDetails(@ReferenceDate, 262) c262 ON c262.RefEntityID = thm.HhMemID --c262 is children 15-19
LEFT JOIN FUGetCharValHistDetails(@ReferenceDate, 263) c263 ON c263.RefEntityID = thm.HhMemID --c263 is children 20+
LEFT JOIN FUGetCharValHistDetails(@ReferenceDate, 264) c264 ON c264.RefEntityID = thm.HhMemID --c264 is Not a parent
LEFT JOIN FUGetCharValHistDetails(@ReferenceDate, 685) c685 ON c685.RefEntityID = thm.HhMemID -- c685 is Number of Child(ren) 0-3 years
LEFT JOIN FUGetCharValHistDetails(@ReferenceDate, 686) c686 ON c686.RefEntityID = thm.HhMemID -- c686 is Number of Child(ren) 4-9 years
LEFT JOIN FUGetCharValHistDetails(@ReferenceDate, 687) c687 ON c687.RefEntityID = thm.HhMemID -- c687 is Number of Child(ren) 10-12 years
LEFT JOIN FUGetCharValHistDetails(@ReferenceDate, 688) c688 ON c688.RefEntityID = thm.HhMemID -- c688 is Number of Child(ren) 13-14 years
LEFT JOIN FUGetCharValHistDetails(@ReferenceDate, 689) c689 ON c689.RefEntityID = thm.HhMemID -- c689 is Number of Child(ren) 15-19 years
LEFT JOIN FUGetCharValHistDetails(@ReferenceDate, 690) c690 ON c690.RefEntityID = thm.HhMemID -- c690 is Number of Child(ren) 20+ years
LEFT JOIN FUGetCharValHistDetails(@ReferenceDate, 268) c268 ON c268.RefEntityID = thm.HhMemID -- understand english
LEFT JOIN FUGetCharValHistDetails(@ReferenceDate, 269) c269 ON c269.RefEntityID = thm.HhMemID -- understand mandarin
LEFT JOIN FUGetCharValHistDetails(@ReferenceDate, 270) c270 ON c270.RefEntityID = thm.HhMemID -- understand malay
LEFT JOIN FUGetCharValHistDetails(@ReferenceDate, 271) c271 ON c271.RefEntityID = thm.HhMemID -- understand tamil
LEFT JOIN FUGetCharValHistDetails(@ReferenceDate, 272) c272 ON c272.RefEntityID = thm.HhMemID -- understand hindi
LEFT JOIN FUGetCharValHistDetails(@ReferenceDate, 273) c273 ON c273.RefEntityID = thm.HhMemID -- understand Other Indian Languages
LEFT JOIN FUGetCharValHistDetails(@ReferenceDate, 274) c274 ON c274.RefEntityID = thm.HhMemID -- Understand Chinese dialects
LEFT JOIN FUGetCharValHistDetails(@ReferenceDate, 275) c275 ON c275.RefEntityID = thm.HhMemID -- Undestand Other languages
LEFT JOIN FUGetCharValHistDetails(@ReferenceDate, 283) c283 ON c283.RefEntityID = thm.HhMemID -- spoken english
LEFT JOIN FUGetCharValHistDetails(@ReferenceDate, 284) c284 ON c284.RefEntityID = thm.HhMemID -- spoken mandarin
LEFT JOIN FUGetCharValHistDetails(@ReferenceDate, 285) c285 ON c285.RefEntityID = thm.HhMemID -- spoken malay
LEFT JOIN FUGetCharValHistDetails(@ReferenceDate, 286) c286 ON c286.RefEntityID = thm.HhMemID -- spoken tamil
LEFT JOIN FUGetCharValHistDetails(@ReferenceDate, 287) c287 ON c287.RefEntityID = thm.HhMemID -- spoken hindi
LEFT JOIN FUGetCharValHistDetails(@ReferenceDate, 288) c288 ON c288.RefEntityID = thm.HhMemID -- spoken other indian languages
LEFT JOIN FUGetCharValHistDetails(@ReferenceDate, 289) c289 ON c289.RefEntityID = thm.HhMemID -- spoken chinese dialects
LEFT JOIN FUGetCharValHistDetails(@ReferenceDate, 290) c290 ON c290.RefEntityID = thm.HhMemID -- spoken other languages
LEFT JOIN FUGetCharValHistDetails(@ReferenceDate, 1120) c1120 ON c1120.RefEntityID = thm.HhMemID -- Most spoken language (Start 13.9.2018)
LEFT JOIN FUGetCharValHistDetails(@ReferenceDate, 1121) c1121 ON c1121.RefEntityID = thm.HhMemID -- Second most spoken language (Start 13.9.2018)
LEFT JOIN FUGetCharValHistDetails(@ReferenceDate, 302) c302 ON c302.RefEntityID = thm.HhMemID --Occupation
LEFT JOIN FUGetCharValHistDetails(@ReferenceDate, 195) c195 ON c195.RefEntityID = thm.HhID --House flat type
LEFT JOIN FUGetCharValHistDetails(@ReferenceDate, 115) c115 ON c115.RefEntityID = thm.HhID --Others - HH has not connected to Internet
