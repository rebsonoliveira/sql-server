--
-- BEFORE RUNNING THIS SCRIPT, UPDATE IT WITH YOUR OWN STRING FOR THE EXTERNAL TABLE NAME (search for "<yourTableNameHere>")
--
USE Sales
GO

PRINT 'STEP 1: Create external table'
CREATE EXTERNAL TABLE [<yourTableNameHere>]
("wcs_click_date_sk" BIGINT , "wcs_click_time_sk" BIGINT , "wcs_sales_sk" BIGINT , "wcs_item_sk" BIGINT , "wcs_web_page_sk" BIGINT , "wcs_user_sk" BIGINT)
WITH
(
    DATA_SOURCE = SqlDataPool,
	DISTRIBUTION = ROUND_ROBIN
)

PRINT 'STEP 2: Populate external table using Spark job'
-- This object is used for starting spark streaming session using spark-submit
--
-- The arguments to jar file are
-- 1: server name - sql server to connect to read the table schema
-- 2: port number
-- 3: username - sql server username for master instance
-- 4: password - sql server password for master instance
-- 5: database name
-- 6: external table name
-- 7: Source directory for streaming. This must be a full URI - such as "hdfs:///clickstream_data"
-- 8: Input format. This can be "csv", "parquet", "json".
-- 9: enable checkpoint: true or false
--
-- Submit spark job with below parameters. You can use the Spark submit experience from Azure Data Studio (right click on server name-> Submit Spark Job):
-- ARGUMENTS:
---- job name: <yourJobName>
---- switch from "Local" to "HDFS"
---- Main class: "FileStreaming" 
---- Path to jar: /jar/mssql-spark-lib-assembly-1.0.jar
---- Arguments (UPDATE WITH THE NAME OF YOUR EXTERNAL TABLE): 
---- mssql-master-pool-0.service-master-pool 1433 sa Orland0!gnite sales yourTableNameHere hdfs:///clickstream_data csv false 

PRINT 'STEP 3: Check data in external table'
SELECT count(*) FROM [dbo].[<yourTableNameHere>]
SELECT TOP 10 * FROM [dbo].[<yourTableNameHere>]
GO

PRINT 'STEP 4: Cleanup...drop external table'

DROP EXTERNAL TABLE [dbo].[<yourTableNameHere>]