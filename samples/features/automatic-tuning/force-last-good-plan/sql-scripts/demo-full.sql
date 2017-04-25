/********************************************************
*	SETUP - clear everything
********************************************************/
EXEC [dbo].[initialize]


/********************************************************
*	PART I
*	Plan regression identification.
********************************************************/

-- 1. Start workload - execute procedure 30 times:
begin
declare @packagetypeid int = 7;
exec dbo.report @packagetypeid
end
go 300
-- Queries should be fast
-- Optionally, include "Actual execution plan" in SSMS and show the plan (it should have Hash Aggregate)


-- 2. Execute procedure that causes plan regression
-- Optionally, include "Actual execution plan" in SSMS and show the plan (it should have Stream Aggregate)
exec dbo.regression


-- 3. Start workload again - verify that is slower.
begin
declare @packagetypeid int = 7;
exec dbo.report @packagetypeid
end
go 20
-- Optionally, include "Actual execution plan" in SSMS and show the plan (it should have Stream Aggregate)

-- 4. Find recommendation recommended by database:
SELECT planForceDetails.query_id, reason, score,
      JSON_VALUE(details, '$.implementationDetails.script') script,
      planForceDetails.[new plan_id], planForceDetails.[recommended plan_id]
FROM sys.dm_db_tuning_recommendations
  CROSS APPLY OPENJSON (Details, '$.planForceDetails')
    WITH (  [query_id] int '$.queryId',
            [new plan_id] int '$.regressedPlanId',
            [recommended plan_id] int '$.forcedPlanId'
          ) as planForceDetails;

-- Note: User can apply script and force the recommended plan to correct the error.
<<Insert T-SQL from the script column here and execute the script>>
-- e.g.: exec sp_query_store_force_plan @query_id = 3, @plan_id = 1

-- 5. Start workload again - verify that is faster.
begin
declare @packagetypeid int = 7;
exec dbo.report @packagetypeid
end
go 20
-- Optionally, include "Actual execution plan" in SSMS and show the plan (it should have Hash Aggregate again)


-- In part II will be shown better approach - automatic tuning.

/********************************************************
*	PART II
*	Automatic tuning
********************************************************/

/********************************************************
*	RESET - clear everything
********************************************************/
EXEC [dbo].[initialize]

-- Enable automatic tuning on the database:
ALTER DATABASE current
SET AUTOMATIC_TUNING ( FORCE_LAST_GOOD_PLAN = ON);

-- Verify that actual state on FLGP is ON:
SELECT name, desired_state_desc, actual_state_desc, reason_desc
FROM sys.database_automatic_tuning_options;


-- 1. Start workload - execute procedure 20 times like in the phase I
begin
declare @packagetypeid int = 7;
exec dbo.report @packagetypeid
end
go 300

-- 2. Execute the procedure that causes plan regression
exec dbo.regression

-- 3. Start workload again - verify that it is slower.
begin
declare @packagetypeid int = 7;
exec dbo.report @packagetypeid
end
go 20

-- 4. Find recommendation that returns query perf regression
-- and check is it in Verifying state:
SELECT reason, score,
	JSON_VALUE(state, '$.currentValue') state,
	JSON_VALUE(state, '$.reason') state_transition_reason,
    JSON_VALUE(details, '$.implementationDetails.script') script,
    planForceDetails.*
FROM sys.dm_db_tuning_recommendations
  CROSS APPLY OPENJSON (Details, '$.planForceDetails')
    WITH (  [query_id] int '$.queryId',
            [new plan_id] int '$.regressedPlanId',
            [recommended plan_id] int '$.forcedPlanId'
          ) as planForceDetails;

		  
-- 5. Wait until recommendation is applied and start workload again - verify that it is faster.
begin
declare @packagetypeid int = 7;
exec dbo.report @packagetypeid
end
go 30

-- Open Query Store/"Top Resource Consuming Queries" dialog in SSMS and show that better plan is forced.