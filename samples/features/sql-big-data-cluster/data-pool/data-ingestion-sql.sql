USE sales
GO

-- Create external table in a data pool in SQL Server 2019 big data cluster.
-- The SqlDataPool data source is a special data source that is available in 
-- any new database in SQL Master instance. This is used to reference the
-- data pool in a SQL Server 2019 big data cluster.
--
CREATE EXTERNAL TABLE [web_clickstreams_dp]
("wcs_click_date_sk" BIGINT , "wcs_click_time_sk" BIGINT , "wcs_sales_sk" BIGINT , "wcs_item_sk" BIGINT , "wcs_web_page_sk" BIGINT , "wcs_user_sk" BIGINT)
WITH
(
    DATA_SOURCE = SqlDataPool,
	DISTRIBUTION = ROUND_ROBIN
);
GO
-- Currently the create external table operation is asynchronous and there is no
-- way to determine completion of the operation. To prevent failures of the insert
-- into the external table, wait for few minutes.
WAITFOR DELAY '00:02:00';
GO
-- Insert results of a SELECT statement into the external table created on the data pool
--
DECLARE @db_name SYSNAME = 'sales'
DECLARE @schema_name SYSNAME = 'dbo'
DECLARE @table_name SYSNAME = 'web_clickstreams_dp'
DECLARE @query SYSNAME = 'SELECT TOP(1000) * FROM sales.dbo.web_clickstreams WHERE wcs_user_sk IS NOT NULL'

EXEC model..sp_data_pool_table_insert_data @db_name, @schema_name, @table_name, @query
GO

-- Query data inserted from sp_data_pool_table_insert_data
--
SELECT count(*) FROM [dbo].[web_clickstreams_dp]
SELECT TOP 10 * FROM [dbo].[web_clickstreams_dp]

-- Join external table with local tables
--
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
  FROM [dbo].[web_clickstreams_dp]
  INNER JOIN item it ON (wcs_item_sk = i_item_sk
                        AND wcs_user_sk IS NOT NULL)
GROUP BY  wcs_user_sk;
GO

DROP EXTERNAL TABLE [dbo].[web_clickstreams_dp];
GO