USE sales
GO

-- Inspect top 100 rows
--
SELECT TOP(100) * FROM web_clickstreams_hdfs_book_clicks;
GO

-- Step #1a
-- Create the training stored procedure
CREATE OR ALTER PROCEDURE [dbo].[train_book_category_visitor_sklearn_python]
(@model_name varchar(100))
AS
BEGIN
	DECLARE @model varbinary(max)
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
	-- Python script that uses logistic regression function from sklearn package to generate model to predict book_category click(s).
	SET @train_script = N'
model = bytes()

# build classification model to predict book_category
import pickle
from sklearn.linear_model import LogisticRegression

# 1. instantiate model
logreg = LogisticRegression( solver="lbfgs")

# 2. fit and finalize the model
feature_cols = ["college_education", "male", "clicks_in_1", "clicks_in_2","clicks_in_3","clicks_in_4","clicks_in_5","clicks_in_6","clicks_in_7","clicks_in_8","clicks_in_9"]
logit_model = logreg.fit(indata[feature_cols], indata["book_category"])

model = pickle.dumps(logit_model)
';

	-- Generate sales model using Python script with the book clicks stats for each user
	EXECUTE sp_execute_external_script
		  @language = N'Python'
		, @script = @train_script
		, @input_data_1 = @input_query
		, @input_data_1_name = N'indata'
		, @params = N'@model varbinary(max) OUTPUT'
		, @model = @model OUTPUT;

	-- Save the trained model to predict user clicks on book category in the website
	DELETE FROM sales_models WHERE model_name = @model_name;
	INSERT INTO sales_models (model_name, model) VALUES(@model_name, @model);
END;
GO


-- Step #1b
-- Train the book category prediction model:
DECLARE @model_name varchar(100) = 'category_model - sklearn (Python)';
EXECUTE dbo.train_book_category_visitor_sklearn_python @model_name;
SELECT * FROM sales_models WHERE model_name = @model_name;
GO

-- Step #2a
-- Predict the book category clicks for new users based on their pattern of 
-- visiting various categories in the web site
CREATE OR ALTER PROCEDURE [dbo].[predict_book_category_visitor_sklearn_python]
(@model_name varchar(100), @top_percent int = 20)
AS
BEGIN
	DECLARE @model varbinary(max) = (SELECT model FROM sales_models WHERE model_name = @model_name)
		, @input_query nvarchar(max)
		, @predict_script nvarchar(max);

	-- Set the input query for scoring. We will use 20% of the data by default
	SET @input_query = N'
SELECT TOP(@top_count_value) PERCENT SIGN(q.clicks_in_category) AS book_category
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

	-- Scoring script that uses sklearn logistic regression model to predict book_category click(s)
	SET @predict_script = N'
import pandas as pd
import pickle

logit_model = pickle.loads(model)

feature_cols = ["college_education", "male", "clicks_in_1", "clicks_in_2","clicks_in_3","clicks_in_4","clicks_in_5","clicks_in_6","clicks_in_7","clicks_in_8","clicks_in_9"]

predictions = logit_model.predict(indata[feature_cols])

predictions_df = pd.DataFrame(predictions, columns = ["book_category_prediction"])
outdata = pd.concat([predictions_df, indata], axis = 1, copy = False)
';

	-- Predict the book category click based on the sklearn model
	EXECUTE sp_execute_external_script
		  @language = N'Python'
		, @script = @predict_script
		, @input_data_1 = @input_query
		, @input_data_1_name = N'indata'
		, @output_data_1_name = N'outdata'
		, @params = N'@model varbinary(max), @top_count_value int'
		, @model = @model
        , @top_count_value = @top_percent
	WITH RESULT SETS ((book_category_prediction bit, book_category_actual bit, college_education varchar(30), male bit,
						clicks_in_1 int, clicks_in_2 int, clicks_in_3 int, clicks_in_4 int, clicks_in_5 int,
						clicks_in_6 int, clicks_in_7 int, clicks_in_8 int, clicks_in_9 int));
END
GO

-- Step #2b
-- Predict the book category clicks for new users based on their pattern of 
-- visiting various categories in the web site
DECLARE @model_name varchar(100) = 'category_model - sklearn (Python)';
EXECUTE dbo.predict_book_category_visitor_sklearn_python @model_name, 1 /* Score only on 1 PERCENT for testing purpose. */;
GO
