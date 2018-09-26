USE master;  
GO  

RESTORE DATABASE sales  
   FROM DISK=N'/var/opt/mssql/data/tpcxbb_1gb_latest_sql17.bak'
   WITH 
   MOVE N'tpcxbb_1gb_test' TO N'/var/opt/mssql/data/sales.mdf',   
   MOVE N'tpcxbb_1gb_test_log' TO N'/var/opt/mssql/data/sales.ldf';  
GO

USE sales;
GO
CREATE MASTER KEY ENCRYPTION BY PASSWORD = 'Orland0!gnite';

CREATE EXTERNAL DATA SOURCE SqlDataPool
WITH (LOCATION = 'sqldatapool://service-mssql-controller:8080/datapools/default');

CREATE EXTERNAL DATA SOURCE SqlStoragePool
WITH (LOCATION = 'sqlhdfs://service-mssql-controller:8080');

CREATE EXTERNAL FILE FORMAT csv_file
WITH (
    FORMAT_TYPE = DELIMITEDTEXT,
    FORMAT_OPTIONS(
        FIELD_TERMINATOR = ',',
        STRING_DELIMITER = '"',
        FIRST_ROW = 2,
        USE_TYPE_DEFAULT = TRUE)
);

CREATE EXTERNAL FILE FORMAT parquet_file
WITH (  
    FORMAT_TYPE = PARQUET
);

GO
CREATE   VIEW [dbo].[web_clickstreams_book_clicks]
AS
	SELECT
	  q.clicks_in_category,
	  CASE WHEN cd.cd_education_status IN ('Advanced Degree', 'College', '4 yr Degree', '2 yr Degree') THEN 1 ELSE 0 END AS college_education,
	  CASE WHEN cd.cd_gender = 'M' THEN 1 ELSE 0 END AS male,
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

CREATE TABLE sales_models (
	model_name varchar(100) primary key clustered,
	model varbinary(max),
	model_native varbinary(max),
	create_time datetime2 DEFAULT(SYSDATETIME())
);
GO

CREATE OR ALTER PROCEDURE [dbo].[train_book_category_visitor]
(@model_name varchar(100))
AS
BEGIN
	DECLARE @start_time datetime2 = SYSDATETIME()
		, @model varbinary(max)
		, @model_native varbinary(max)
		, @input_query nvarchar(max)
		, @train_script nvarchar(max)
		
-- Set the input query for training. We will use 80% of the data.
	SET @input_query = N'
SELECT TOP(80) PERCENT SIGN(q.clicks_in_category) AS book_category
		, q.college_education
		, q.male
		, q.clicks_in_1
		, q.clicks_in_2
		, q.clicks_in_3
		, q.clicks_in_4
		, q.clicks_in_5
		, q.clicks_in_6
		, q.clicks_in_7
		, q.clicks_in_8
		, q.clicks_in_9
	FROM web_clickstreams_book_clicks as q
';
	-- Training R script that uses rxLogit function from RevoScaleR package (Microsoft R Server) to generate model to predict book_category click(s).
		SET @train_script = N'
# build classification model to predict book_category
	logitObj <- rxLogit(book_category ~ college_education + male +
						clicks_in_1 + clicks_in_2 + clicks_in_3 + clicks_in_4 + clicks_in_5 +
						clicks_in_6 + clicks_in_7 + clicks_in_8 + clicks_in_9 , data = indata)

# First, serialize a model and put it into a database table
modelbin <- as.raw(serialize(logitObj, NULL));

model_native <- rxSerializeModel(logitObj, realtimeScoringOnly = TRUE)
';

	-- Generate sales model using R scirpt with the book clicks stats for each user
	EXECUTE sp_execute_external_script
		  @language = N'R'
		, @script = @train_script
		, @input_data_1 = @input_query
		, @input_data_1_name = N'indata'
		, @params = N'@input_query nvarchar(max), @modelbin varbinary(max) OUTPUT,  @model_native varbinary(max) OUTPUT'
		, @input_query = @input_query
		, @modelbin = @model OUTPUT
		, @model_native = @model_native OUTPUT;

	-- Save the trained models to predict user clicks on book category in the website
	DELETE FROM sales_models WHERE model_name = @model_name;
	INSERT INTO sales_models (model_name, model, model_native) VALUES(@model_name, @model,  @model_native);
END;
GO
