-- ==================================================================================================
-- Author:		<James>
-- Create date: <2023-08-18>
-- Description:	<Total Accumulated Incentive for each Hh that installed router>
--Remarks:
--HweeSuen want to know the total accumulated incentive for each Hh that has router installed. This can be filtered by the column ‘Reason' which has a keyword = 'router’
--She wants the record starting from 01 May 2023
--If everything satisfies her demand, she will request to include this same report into the trial and final report in future.

-- Last changed:<2023-08-22> HweeSuen requested to have extra two columns indicating their last active and inactive CharHistFrom date, this information can get from EPM Gfk Router, making use of partion feature on the c1257

-- Last changed:<2023-11-01> HweeSuen requested to have cut-off date for router incentive as well, as this round she only want to have incentive records up until 31 October only, so will add cutoff date. Also add special handling for the 2pid household 50709 to have LastActiveFromDate on 19 June 2023
-- ==================================================================================================


USE EvoProd

GO

DECLARE @RouterIncentiveStartFromDate DATE
DECLARE @RouterIncentiveCutOffDate DATE

SET @RouterIncentiveStartFromDate = '2023-05-01'
SET @RouterIncentiveCutOffDate = '2023-10-31'

--=====================================================================================================
-- Router Incentive Records for all HHIDs
SELECT  
	RefEntityID AS [HhID],
	PaymentType,
	Amount,
	[Date], 
	Reason,
	SubmitedByUser
FROM tIncentiveEarningsHistory
WHERE Reason LIKE '%router%'
AND CAST([Date] AS Date) BETWEEN @RouterIncentiveStartFromDate AND @RouterIncentiveCutOffDate
ORDER BY RefEntityID,[Date]


-- To retrieve accumulated incentive for each distinct hhid
;WITH router_incentive_only AS (
	
	SELECT 
		RefEntityID AS [HhID],
		PaymentType,
		Amount,
		[Date], 
		Reason,
		SubmitedByUser
	FROM tIncentiveEarningsHistory
	WHERE Reason LIKE '%router%'
	AND CAST([Date] AS Date) BETWEEN @RouterIncentiveStartFromDate AND @RouterIncentiveCutOffDate

),
--# This part is to get accumulated incentive for each hhid
router_incentive_only_total AS (

	SELECT 
		[HhID]
		,SUM(Amount) AS [Total Accumulated Incentive] 
	FROM router_incentive_only
	GROUP BY HhID
),
--# This part is to get the history of values of CharID 1257 which is the router installed and uninstalled active/inactive dates
charHistCharID1257 AS (
	SELECT * FROM tCharValHist
	WHERE CharID = '1257'
),
--# This part is to get the latest CharHistFrom  because a HhID can become inactive more than once, this is for CharValue=2 
charHistCharID1257_partitioned_2_rn1 AS (

	select  *,
			ROW_NUMBER() OVER (PARTITION BY RefEntityID ORDER BY CharHistFrom DESC) AS rn
	FROM charHistCharID1257
	WHERE CharValue = 2

),
--# This part is to get the second latest CharHistFrom  because a HhID can become inactive more than once, this is for CharValue=2 
charHistCharID1257_partitioned_2_rn2 AS (

	select  *,
			ROW_NUMBER() OVER (PARTITION BY RefEntityID ORDER BY CharHistFrom DESC) AS rn
	FROM charHistCharID1257	
	WHERE CharValue = 2

),
--# This part is to get the latest CharHistFrom  because a HhID can become active more than once, this is for CharValue=1
charHistCharID1257_partitioned_1_rn1 AS (

	select  *,
			ROW_NUMBER() OVER (PARTITION BY RefEntityID ORDER BY CharHistFrom DESC) AS rn
	FROM charHistCharID1257	
	WHERE CharValue = 1

),
--# This part is to get the second latest CharHistFrom  because a HhID can become active more than once, this is for CharValue=1
charHistCharID1257_partitioned_1_rn2 AS (

	select  *,
			ROW_NUMBER() OVER (PARTITION BY RefEntityID ORDER BY CharHistFrom DESC) AS rn
	FROM charHistCharID1257	
	WHERE CharValue = 1

),
--# This part left join the accumulated incentive for each distinct hh with both the 
combined_routerIncentiveOnlyTotal_charHistCharID1257Partitioned AS (
	
	SELECT  a.HhID,
			a.[Total Accumulated Incentive],
			
			--for inactive rank1
			b1.RefEntityID AS HhID_2_rn1,
			b1.CharValue AS CharValue_2_rn1,
			CAST(b1.CharHistFrom AS date) AS CharHistFrom_2_rn1,
			CAST(b1.CharHistUntil AS date) AS CharHistUntil_2_rn1,

			--for inactive rank2 (if use CharHistFrom then this is not really needed, unless use and also partition by CharHistUntil)
			b2.RefEntityID AS HhID_2_rn2,
			b2.CharValue AS CharValue_2_rn2,
			CAST(b2.CharHistFrom AS date) AS CharHistFrom_2_rn2,
			CAST(b2.CharHistUntil AS date) AS CharHistUntil_2_rn2,

			--for active rank1
			c1.RefEntityID AS HhID_1_rn1,
			c1.CharValue AS CharValue_1_rn1,
			CAST(c1.CharHistFrom AS date) AS CharHistFrom_1_rn1,
			CAST(c1.CharHistUntil AS date) AS CharHistUntil_1_rn1,

			--for active rank2 (if use CharHistFrom then this is not really needed, unless use and also partition by CharHistUntil)
			c2.RefEntityID AS HhID_1_rn2,
			c2.CharValue AS CharValue_1_rn2,
			CAST(c2.CharHistFrom AS date) AS CharHistFrom_1_rn2,
			CAST(c2.CharHistUntil AS date) AS CharHistUntil_1_rn2
		   
	FROM router_incentive_only_total a
	LEFT JOIN charHistCharID1257_partitioned_2_rn1 b1 ON a.HhID = b1.RefEntityID AND b1.rn=1
	LEFT JOIN charHistCharID1257_partitioned_2_rn2 b2 ON a.HhID = b2.RefEntityID AND b2.rn=2
	LEFT JOIN charHistCharID1257_partitioned_1_rn1 c1 ON a.HhID = c1.RefEntityID AND c1.rn=1
	LEFT JOIN charHistCharID1257_partitioned_1_rn2 c2 ON a.HhID = c2.RefEntityID AND c2.rn=2

)
select  HhID,
		[Total Accumulated Incentive],
		CASE
			WHEN CharHistFrom_1_rn1 IS NULL AND HhID = 50709 THEN '2023-06-19'
			ELSE CharHistFrom_1_rn1 -- Use CharHistFrom_1_rn1 as the default value
		END AS [LastActiveFromDate],
		CharHistFrom_2_rn1 AS [LastInactiveFromDate]
FROM combined_routerIncentiveOnlyTotal_charHistCharID1257Partitioned
ORDER BY HhID







