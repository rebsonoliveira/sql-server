USE sales
GO

-- Create the training stored procedure
CREATE OR ALTER PROCEDURE [dbo].[train_book_category_visitor_python_mml]
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
	FROM web_clickstreams_book_clicks as q
';
	-- Training R script that uses rxLogit function from RevoScaleR package (Microsoft R Server) to generate model to predict book_category click(s).
		SET @train_script = N'
# build classification model to predict book_category
from microsoftml import rx_logistic_regression
from revoscalepy import rx_serialize_model
import pickle

logitObj = rx_logistic_regression(formula = """
	book_category ~ college_education + male +
	clicks_in_1 + clicks_in_2 + clicks_in_3 + clicks_in_4 + clicks_in_5 +
	clicks_in_6 + clicks_in_7 + clicks_in_8 + clicks_in_9
""", data = indata);

model = pickle.dumps(logitObj)
';

	-- Generate sales model using R scirpt with the book clicks stats for each user
	EXECUTE sp_execute_external_script
		  @language = N'Python'
		, @script = @train_script
		, @input_data_1 = @input_query
		, @input_data_1_name = N'indata'
		, @params = N'@input_query nvarchar(max), @model varbinary(max) OUTPUT'
		, @input_query = @input_query
		, @model = @model OUTPUT;

	-- Save the trained models to predict user clicks on book category in the website
	DELETE FROM sales_models WHERE model_name = @model_name;
	INSERT INTO sales_models (model_name, model) VALUES(@model_name, @model);
END;
GO

-- Step #1
-- Train the book category prediction model:
DECLARE @model_name varchar(100) = 'category_model (Python MML)';
EXECUTE dbo.train_book_category_visitor_python_mml @model_name;
SELECT * FROM sales_models WHERE model_name = @model_name;
GO

-- Step #2a
-- Predict the book category clicks for new users based on their pattern of 
-- visiting various categories in the web site
CREATE OR ALTER PROCEDURE [dbo].[predict_book_category_visitor_python_mml]
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
	FROM web_clickstreams_book_clicks as q
';

	-- Scoring script that uses sklearn logistic regression model to predict book_category click(s)
	SET @predict_script = N'
from microsoftml import rx_predict
import pandas as pd
import pickle

logit_model = pickle.loads(model)

feature_cols = ["college_education", "male", "clicks_in_1", "clicks_in_2","clicks_in_3","clicks_in_4","clicks_in_5","clicks_in_6","clicks_in_7","clicks_in_8","clicks_in_9"]

predictions = rx_predict(logit_model, indata[feature_cols])

predictions_df = pd.DataFrame(predictions, columns = ["PredictedLabel"])
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
DECLARE @model_name varchar(100) = 'category_model (Python MML)';
EXECUTE dbo.predict_book_category_visitor_python_mml @model_name, 1 /* Score only on 1 PERCENT for testing purpose. */;
GO
