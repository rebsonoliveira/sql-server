USE sales
GO

-- Inspect top 100 rows
--
SELECT TOP(100) * FROM web_clickstreams_hdfs_book_clicks;
GO

-- Create the training stored procedure
CREATE OR ALTER PROCEDURE [dbo].[train_book_category_visitor_r]
(@model_name varchar(100))
AS
BEGIN
	DECLARE @model varbinary(max)
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
	FROM web_clickstreams_hdfs_book_clicks as q
';
	-- Training script that uses rxLogit function from RevoScaleR package (Microsoft ML Server) to generate model to predict book_category click(s).
	SET @train_script = N'
# build classification model to predict book_category
logitObj <- rxLogit(book_category ~ college_education + male +
						clicks_in_1 + clicks_in_2 + clicks_in_3 + clicks_in_4 + clicks_in_5 +
						clicks_in_6 + clicks_in_7 + clicks_in_8 + clicks_in_9 , data = indata)

# First, serialize a model and put it into a database table
modelbin <- as.raw(serialize(logitObj, NULL));

model_native <- rxSerializeModel(logitObj, realtimeScoringOnly = TRUE)
';

	-- Generate sales model using R script with the book clicks stats for each user
	EXECUTE sp_execute_external_script
		  @language = N'R'
		, @script = @train_script
		, @input_data_1 = @input_query
		, @input_data_1_name = N'indata'
		, @params = N'@modelbin varbinary(max) OUTPUT,  @model_native varbinary(max) OUTPUT'
		, @modelbin = @model OUTPUT
		, @model_native = @model_native OUTPUT;

	-- Save the trained models to predict user clicks on book category in the website
	DELETE FROM sales_models WHERE model_name = @model_name;
	INSERT INTO sales_models (model_name, model, model_native) VALUES(@model_name, @model,  @model_native);
END;
GO

-- Step #1
-- Train the book category prediction model:
DECLARE @model_name varchar(100) = 'category_model (R)';
EXECUTE dbo.train_book_category_visitor_r @model_name;
SELECT * FROM sales_models WHERE model_name = @model_name;
GO

-- Step #2
-- Predict the book category clicks for new users based on their pattern of 
-- visiting various categories in the web site
DECLARE @sales_model varbinary(max) = (SELECT model_native FROM sales_models WHERE model_name = 'category_model (R)');
SELECT TOP(100)
      w.wcs_user_sk
	, p.book_category_Pred as book_click_prediction
	, w.college_education as [College Education]
	, w.clicks_in_1 AS [Home & Kitchen]
	, w.clicks_in_2 AS [Music]
	, w.clicks_in_3 AS [Books]
	, w.clicks_in_4 AS [Clothing & Accessories]
	, w.clicks_in_5 AS [Electronics]
	, w.clicks_in_6 AS [Tools & Home Improvement]
	, w.clicks_in_7 AS [Toys & Games]
	, w.clicks_in_8 AS [Movies & TV]
	, w.clicks_in_9 AS [Sports & Outdoors]
  FROM PREDICT(MODEL = @sales_model, DATA  = web_clickstreams_hdfs_book_clicks as w) WITH ("book_category_Pred" float) as p
 WHERE p.book_category_Pred <> SIGN(w.clicks_in_category);
GO