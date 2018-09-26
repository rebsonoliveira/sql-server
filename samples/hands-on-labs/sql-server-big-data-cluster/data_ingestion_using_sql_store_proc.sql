--
-- BEFORE RUNNING THIS SCRIPT, UPDATE IT WITH YOUR OWN STRING FOR THE EXTERNAL TABLE NAME (search for "<yourTableNameHere>")
--

PRINT 'STEP 1: Connect to SQL Server Master instance'

USE Sales
GO

PRINT 'STEP 2: Create external table'
CREATE EXTERNAL TABLE [<yourTableNameHere>]]
("wcs_click_date_sk" BIGINT , "wcs_click_time_sk" BIGINT , "wcs_sales_sk" BIGINT , "wcs_item_sk" BIGINT , "wcs_web_page_sk" BIGINT , "wcs_user_sk" BIGINT)
WITH
(
    DATA_SOURCE = SqlDataPool,
	DISTRIBUTION = ROUND_ROBIN
)

PRINT 'STEP 3: Populate external table using sql stored proc'
DECLARE @db_name SYSNAME = 'sales'
DECLARE @schema_name SYSNAME = 'dbo'
DECLARE @table_name SYSNAME = '<yourTableNameHere>'  --UPDATE WITH THE NAME OF YOUR EXTERNAL TABLE
DECLARE @query SYSNAME = 'SELECT TOP(1000) * FROM sales.dbo.web_clickstreams'

EXEC model..sp_data_pool_table_insert_data @db_name, @schema_name, @table_name, @query

PRINT 'STEP 4: Check data in external table'
SELECT count(*) FROM [dbo].[<yourTableNameHere>]
SELECT TOP 10 * FROM [dbo].[<yourTableNameHere>]

SELECT 
    wcs_user_sk,
    SUM( CASE WHEN i_category = 'Books' THEN 1 ELSE 0 END) AS clicks_in_category,
    SUM( CASE WHEN i_category_id = 1 THEN 1 ELSE 0 END) AS clicks_in_1,
    SUM( CASE WHEN i_category_id = 2 THEN 1 ELSE 0 END) AS clicks_in_2,
    SUM( CASE WHEN i_category_id = 3 THEN 1 ELSE 0 END) AS clicks_in_3,
    SUM( CASE WHEN i_category_id = 4 THEN 1 ELSE 0 END) AS clicks_in_4,
    SUM( CASE WHEN i_category_id = 5 THEN 1 ELSE 0 END) AS clicks_in_5,
    SUM( CASE WHEN i_category_id = 6 THEN 1 ELSE 0 END) AS clicks_in_6,
    SUM( CASE WHEN i_category_id = 7 THEN 1 ELSE 0 END) AS clicks_in_7,
    SUM( CASE WHEN i_category_id = 8 THEN 1 ELSE 0 END) AS clicks_in_8,
    SUM( CASE WHEN i_category_id = 9 THEN 1 ELSE 0 END) AS clicks_in_9
  FROM [dbo].[<yourTableNameHere>]
  INNER JOIN item it ON (wcs_item_sk = i_item_sk
                        AND wcs_user_sk IS NOT NULL)
GROUP BY  wcs_user_sk;
GO

PRINT 'STEP 5: Cleanup...drop external table'

DROP EXTERNAL TABLE [dbo].[<yourTableNameHere>]