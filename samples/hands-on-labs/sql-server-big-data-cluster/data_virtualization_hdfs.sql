--
-- BEFORE RUNNING THIS SCRIPT, UPDATE IT WITH YOUR OWN STRING FOR THE EXTERNAL TABLE NAME (search for "<yourTableName>")
--

PRINT 'STEP 1: Connect to SQL Server Master instance'

USE sales
GO

PRINT 'STEP 2: Create external table over CSV file'
CREATE EXTERNAL TABLE [<yourTableName>]
("wcs_click_date_sk" BIGINT , "wcs_click_time_sk" BIGINT , "wcs_sales_sk" BIGINT , "wcs_item_sk" BIGINT , "wcs_web_page_sk" BIGINT , "wcs_user_sk" BIGINT)
WITH
(
    DATA_SOURCE = SqlStoragePool,
	LOCATION = '/clickstream_data',
    FILE_FORMAT = csv_file
);

-- Join external table with local tables
-- Execution time: ~10 secs
PRINT 'STEP 3: Join external table with high value data in SQL Master'
SELECT TOP (100)
    wcs_user_sk,
    SUM( CASE WHEN i_category = 'Books' THEN 1 ELSE 0 END) AS book_category_clicks,
    SUM( CASE WHEN i_category_id = 1 THEN 1 ELSE 0 END) AS [Home & Kitchen],
    SUM( CASE WHEN i_category_id = 2 THEN 1 ELSE 0 END) AS [Music],
    SUM( CASE WHEN i_category_id = 3 THEN 1 ELSE 0 END) AS [Books],
    SUM( CASE WHEN i_category_id = 4 THEN 1 ELSE 0 END) AS [Clothing & Accessories],
    SUM( CASE WHEN i_category_id = 5 THEN 1 ELSE 0 END) AS [Electronics],
    SUM( CASE WHEN i_category_id = 6 THEN 1 ELSE 0 END) AS [Tools & Home Improvement],
    SUM( CASE WHEN i_category_id = 7 THEN 1 ELSE 0 END) AS [Toys & Games],
    SUM( CASE WHEN i_category_id = 8 THEN 1 ELSE 0 END) AS [Movies & TV],
    SUM( CASE WHEN i_category_id = 9 THEN 1 ELSE 0 END) AS [Sports & Outdoors]
  FROM [dbo].[<yourTableName>]
  INNER JOIN item it ON (wcs_item_sk = i_item_sk
                        AND wcs_user_sk IS NOT NULL)
GROUP BY  wcs_user_sk;

PRINT 'STEP 4: Cleanup...drop external table'
DROP EXTERNAL TABLE [dbo].[<yourTableName>]