-- NOTE: Be sure the configuration option 'max degree of parallelism' is set to 0
--
use insert_is_faster_in_2016
go
-- STEP 1: Run an INSERT..SELECT with a serial plan by not including TABLOCK hint
-- This is similar to the performance of the query prior to SQL Server 2016
-- First truncate the target table
truncate table parallelinserts
go
-- First insert without TABLOCK so it is serial
-- NOTE: Select the button in SSMS for "Include Actual Execution Plan"
-- Use the dmv.sql script included with this demo folder to observe the status of the request 
insert into parallelinserts select * from watchinsertsfly
go
-- What did the plan Execution Plan look like for the Table Insert operator?
-- Hover over the Table Insert operator and see what the value is for "Number of Executions". Should be 1
-- How long did this take to run? On the demo machine where this was created this took 1 minute+ to run

-- STEP 2: Now let's run the same INSERT..SELECT using the TABLOCK hint\
-- Be sure to keep the "Include Actual Executiuon Plan
-- Truncate the table again
--
truncate table parallelinserts
go
-- Run the INSERT
-- Use the dmv.sql script include with this demo folder to observe the status of this request
-- Notice you only see a CXPACKET wait. Use the 2nd query in dmv.sql to observe any "true" waits
insert into parallelinserts WITH (TABLOCK) select * from watchinsertsfly
go
-- What did the plan Execution Plan look like for the Table Insert operator?
-- Hover over the Table Insert operator and see what the value is for "Number of Executions". Should be > 1 (equal to maxdop for your server or # logical CPUs)
-- How long did this take to run? On the demo machine where this was created it took about 20-30 seconds

-- ADDITIONAL DEMOS using MAXDOP hints
-- Use the following to observe the performance using other MAXDOP hints
-- These demos were created on a computer with 8 logical CPUs so you can use various
-- MAXDOP hints per the number of CPUs on your machine lower than the one used above
-- Find the threshold where a higher parallelism doesn't help or may even hinder performance

-- Truncate the target table
truncate table parallelinserts
go
-- Try this again with TABLOCK but go only MAXDOP = 2
--
insert into parallelinserts WITH (TABLOCK) select * from watchinsertsfly OPTION (MAXDOP 2)
go
-- Truncate the target table
truncate table parallelinserts
go
-- Try this again with TABLOCK but go only MAXDOP = 4
--
insert into parallelinserts WITH (TABLOCK) select * from watchinsertsfly OPTION (MAXDOP 4)
go

-- TEMPDB demo
-- Use of INSERT..SELECT doesn't require TABLOCK for temp tables
-- 
-- Build an empty table
--
select * into #x from watchinsertsfly where 1 = 2
go
-- Run the INSERT...SELECT
insert into #x select * from watchinsertsfly
go