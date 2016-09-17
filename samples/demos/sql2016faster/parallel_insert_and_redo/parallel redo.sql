use insert_is_faster_in_2016
go
-- Change the target recovery interval to a high really high number to avoid any indirect checkpoints
--
ALTER DATABASE insert_is_faster_in_2016 SET TARGET_RECOVERY_TIME = 50000 minutes
go
-- STEP 1: Test out parallel redo
--
-- Truncate the target table
truncate table parallelinserts
go
-- Insert and delete rows from the table
insert into parallelinserts WITH (TABLOCK) select * from watchinsertsfly
delete from parallelinserts
go

-- Now you need to kill the SQLSERVR.EXE process without a clean shutdown or checkpoint. COME BACK HERE WHEN DONE
-- Restart the SQL Server Service and come back to this point
-- See what tasks are running for a parallel redo. Look for a command = PARALLEL REDO TASK
select * from sys.dm_exec_requests
go
-- Check the ERRORLOG output note the total time it takes to perform redo
-- Look at the XEvent file output to see the parallel redo activity
--
-- STEP 2: Test out redo without parallelism
--
-- Let's do this again but this time use a trace flag to not use parallel redo
--
use insert_is_faster_in_2016
go
-- Truncate the target table
truncate table parallelinserts
go
-- Insert and delete rows from the table
insert into parallelinserts WITH (TABLOCK) select * from watchinsertsfly
delete from parallelinserts
go
-- Now you need to kill the SQLSERVR.EXE process without a clean shutdown or checkpoint. COME BACK HERE WHEN DONE
-- Restart the SQL Server Service with trace flag /T3459 to see the redo activity in the ERRORLOG. Note the differences from before.
-- See what tasks are running for redo
select * from sys.dm_exec_requests
go
-- Check the ERRORLOG output to see redo activity and total time it takes without parallel redo
-- Check the result of the Extended Events Session and notice no parallel redo activity or workers are logged


