USE master;  
GO  
-- Enable external scripts execution for R/Python/Java:
exec sp_configure 'external scripts enabled', 1;
RECONFIGURE WITH OVERRIDE;
GO

IF DB_ID('sales') IS NULL
	RESTORE DATABASE sales  
		FROM DISK=N'/var/opt/mssql/data/tpcxbb_1gb.bak'
		WITH 
		MOVE N'tpcxbb_1gb' TO N'/var/opt/mssql/data/sales.mdf',   
		MOVE N'tpcxbb_1gb_log' TO N'/var/opt/mssql/data/sales.ldf';  
GO

USE sales;
GO
-- Create default data sources for SQL Big Data Cluster
IF NOT EXISTS(SELECT * FROM sys.external_data_sources WHERE name = 'SqlDataPool')
	CREATE EXTERNAL DATA SOURCE SqlDataPool
	WITH (LOCATION = 'sqldatapool://service-mssql-controller:8080/datapools/default');

IF NOT EXISTS(SELECT * FROM sys.external_data_sources WHERE name = 'SqlStoragePool')
	CREATE EXTERNAL DATA SOURCE SqlStoragePool
	WITH (LOCATION = 'sqlhdfs://service-mssql-controller:8080');
GO

-- Create view used for ML services training stored procedure
CREATE OR ALTER VIEW [dbo].[web_clickstreams_book_clicks]
AS
	SELECT
	  q.clicks_in_category,
	  CASE WHEN cd.cd_education_status IN ('Advanced Degree', 'College', '4 yr Degree', '2 yr Degree') THEN 1 ELSE 0 END AS college_education,
	  CASE WHEN cd.cd_gender = 'M' THEN 1 ELSE 0 END AS male,
	  COALESCE(cd.cd_credit_rating, 'Unknown') as cd_credit_rating,
	  q.clicks_in_1,
	  q.clicks_in_2,
	  q.clicks_in_3,
	  q.clicks_in_4,
	  q.clicks_in_5,
	  q.clicks_in_6,
	  q.clicks_in_7,
	  q.clicks_in_8,
	  q.clicks_in_9
	FROM( 
	  SELECT 
		w.wcs_user_sk,
		SUM( CASE WHEN i.i_category = 'Books' THEN 1 ELSE 0 END) AS clicks_in_category,
		SUM( CASE WHEN i.i_category_id = 1 THEN 1 ELSE 0 END) AS clicks_in_1,
		SUM( CASE WHEN i.i_category_id = 2 THEN 1 ELSE 0 END) AS clicks_in_2,
		SUM( CASE WHEN i.i_category_id = 3 THEN 1 ELSE 0 END) AS clicks_in_3,
		SUM( CASE WHEN i.i_category_id = 4 THEN 1 ELSE 0 END) AS clicks_in_4,
		SUM( CASE WHEN i.i_category_id = 5 THEN 1 ELSE 0 END) AS clicks_in_5,
		SUM( CASE WHEN i.i_category_id = 6 THEN 1 ELSE 0 END) AS clicks_in_6,
		SUM( CASE WHEN i.i_category_id = 7 THEN 1 ELSE 0 END) AS clicks_in_7,
		SUM( CASE WHEN i.i_category_id = 8 THEN 1 ELSE 0 END) AS clicks_in_8,
		SUM( CASE WHEN i.i_category_id = 9 THEN 1 ELSE 0 END) AS clicks_in_9
	  FROM web_clickstreams as w
	  INNER JOIN item as i ON (w.wcs_item_sk = i_item_sk
						 AND w.wcs_user_sk IS NOT NULL)
	  GROUP BY w.wcs_user_sk
	) AS q
	INNER JOIN customer as c ON q.wcs_user_sk = c.c_customer_sk
	INNER JOIN customer_demographics as cd ON c.c_current_cdemo_sk = cd.cd_demo_sk;
GO

-- Create table for storing the machine learning models
IF NOT EXISTS(SELECT * FROM sys.tables WHERE name = 'sales_models')
	CREATE TABLE sales_models (
		model_name varchar(100) NOT NULL PRIMARY KEY,
		model varbinary(max) NOT NULL,
		model_native varbinary(max) NULL,
		created_by nvarchar(300) NOT NULL DEFAULT(SYSTEM_USER),
		create_time datetime2 NOT NULL DEFAULT(SYSDATETIME())
	);
GO
