# SQL Server big data clusters

The new built-in notebooks in Azure Data Studio enables data scientists and data engineers to run Python, R, Scala, or Spark SQL code against the cluster.

## Instructions to open a notebook from Azure Data Studio and execute the commands

1. Connect to the SQL Server Master instance in a big data cluster

1. Right-click on the server name, select **Manage**, switch to **SQL Server Big Data Cluster** tab, and use open Notebook.

1. Open the notebook in Azure Data Studio, wait for the “Kernel” and the target context (“Attach to”) to be populated.

1. Run each cell in the Notebook sequentially.

## __[data-loading](data-loading/)__

This folder contains samples that show how to load data using Spark and query them using SQL statements.

[data-loading/transform-csv-files.ipynb](dataloading/transform-csv-files.ipynb/)

This samnple notebook shows how to transform CSV files in HDFS to parquet files.

[dataloading/spark-sql.ipynb](dataloading/spark-sql.ipynb/)

This samnple notebook shows how to query hive tables created from Spark.

## __[data-virtualization](data-virtualization/)__

This folder contains samples that show how to integrate Spark with other data sources.
