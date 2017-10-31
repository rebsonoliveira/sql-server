/*
To install the pretrained model in SQL Server, open an elevated CMD promtp:
1. Navigate to the SQL Server installation path: 
C:\<SQL SERVER Installation path>\Microsoft SQL Server\140\Setup Bootstrap\SQL2017\x64
2. Run the following command: 
RSetup.exe /install /component MLM /<version>/language 1033 /destdir <SQL_DB_instance_folder>\PYTHON_SERVICES\Lib\site-packages\microsoftml\mxLibs
Example:
RSetup.exe /install /component MLM /version 9.2.0.24 /language 1033 /destdir "C:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\PYTHON_SERVICES\Lib\site-packages\microsoftml\mxLibs"
The models will be downloaded and extracted.
*/


USE [tpcxbb_1gb]
GO

--******************************************************************************************************************
-- STEP 1 Stored procedure that uses a pretrained model to determine sentiment of a text, such as a product review
--******************************************************************************************************************
CREATE OR ALTER PROCEDURE [dbo].[get_sentiment] 
(@text NVARCHAR(MAX))
AS
BEGIN
	DECLARE	@script nvarchar(max);
	
	--The Python script we want to execute
	SET @script = N'
import pandas as p
from microsoftml import rx_featurize, get_sentiment

analyze_this = text

# Create the data
text_to_analyze = p.DataFrame(data=dict(Text=[analyze_this]))

# Get the sentiment scores
sentiment_scores = rx_featurize(data=text_to_analyze,ml_transforms=[get_sentiment(cols=dict(scores="Text"))])

# Lets translate the score to something more meaningful
sentiment_scores["Sentiment"] = sentiment_scores.scores.apply(lambda score: "Positive" if score > 0.6 else "Negative")
';
	
	EXECUTE sp_execute_external_script
				@language = N'Python'
				, @script = @script
				, @output_data_1_name = N'sentiment_scores'
				, @params = N'@text nvarchar(max)'
				, @text = @text
				WITH RESULT SETS (("Text" NVARCHAR(MAX),"Score" FLOAT, "Sentiment" NVARCHAR(30)));			

END
				  
GO

--******************************************************************************************************************
-- STEP 2 Execute the stored procedure to get sentiment of your own text
--******************************************************************************************************************
EXECUTE [dbo].[get_sentiment] N'ENTER YOUR OWN TEXT HERE';
GO
