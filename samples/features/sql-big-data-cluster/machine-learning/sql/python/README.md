# SQL Server Machine Learning Services

SQL Server 2016 added capability to run R script from T-SQL. SQL Server 2017 added support for running Python scripts from T-SQL. SQL Server 2019 adds support for running Java code from T-SQL.

[book-click-prediction-py.sql](book-click-prediction-py.sql/)

**Applies to:** SQL Server 2017+, SQL Server 2019, SQL Server 2019 big data cluster

In this example, we are building a machine learning model using Python. The script uses a logistic regression algorithm from revoscalepy package in Microsoft ML Server. Based on existing users' click pattern online and their interest in other categories and demographics, we are training a machine learning model. This model will then be used to predict if the visitor is interested in a given item category using the T-SQL PREDICT function.

[book-click-prediction-partitioned-py.sql](book-click-prediction-partitioned-py.sql/)

**Applies to:** SQL Server 2019, SQL Server 2019 big data cluster

In this example, we are leveraging the new partitioning support (SQL Server 2019) in sp_execute_external_script to partition the input data and run the Python script per partition. So we will modify the training script to train model per group of users based on credit rating. The Python script will produce N models for the same input data set.

[book-click-prediction-mml-py.sql](book-click-prediction-mml-py.sql/)

**Applies to:** SQL Server 2017+, SQL Server 2019 big data cluster

In this example, we are building a machine learning model using Python. The script uses a logistic regression algorithm from microsoftml package to train and score the model.

[book-click-prediction-sklearn-py.sql](book-click-prediction-sklearn-py.sql/)

**Applies to:** SQL Server 2017+, SQL Server 2019 big data cluster

In this example, we are building a machine learning model using Python. The script uses a logistic regression algorithm from sklearn package. In SQL Server 2017 or SQL Server 2019, you need to install ***sklearn*** package before running the SQL script.

## Instructions

1. Connect to SQL Server or SQL Server Master instance.

1. Execute the SQL script.
