# SQL Server Machine Learning Services on SQL Master instance

[book-click-prediction-r.sql](book-click-prediction-r.sql/)

In this example, we are building a machine learning model using R and a logistic regression algorithm for a recommendation engine on an online store. Based on existing users' click pattern online and their interest in other categories and demographics, we are training a machine learning model. This model will then be used to predict if the visitor is interested in a given item category using the T-SQL PREDICT function.

[book-click-prediction-py.sql](book-click-prediction-py.sql/)

In this example, we are building a machine learning model using Python and a logistic regression algorithm for a recommendation engine on an online store. Based on existing users' click pattern online and their interest in other categories and demographics, we are training a machine learning model. This model will then be used to predict if the visitor is interested in a given item category using the T-SQL PREDICT function.

[book-click-prediction-partitioned-r.sql](book-click-prediction-partitioned-r.sql/)

In this example, we are leveraging the new partitioning support (SQL Server 2019) in sp_execute_external_script to partition the input data and run the R script per partition. So we will modify the training script to train model per group of users based on credit rating. The R script will produce N models for the same input data set.

[book-click-prediction-partitioned-py.sql](book-click-prediction-partitioned-py.sql/)

In this example, we are leveraging the new partitioning support (SQL Server 2019) in sp_execute_external_script to partition the input data and run the Python script per partition. So we will modify the training script to train model per group of users based on credit rating. The Python script will produce N models for the same input data set.

### Instructions

1. Connect to SQL Server Master instance.

1. Execute the SQL script.
