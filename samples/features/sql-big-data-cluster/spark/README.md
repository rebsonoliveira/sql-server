# SQL Server big data clusters

The new built-in notebooks in Azure Data Studio enables data scientists and data engineers to run Python, R, or Scala code against the cluster.

## Instructions to open a notebook from Azure Data Studio

1. Connect to the SQL Server Master instance in a big data cluster

1. Right-click on the server name, select **Manage**, switch to **SQL Server Big Data Cluster** tab, and use open Notebook

## __[dataloading](dataloading/)__
<<<<<<< HEAD

This folder contains samples that show how to load data using Spark.

[PySpark Hello World](dataloading/hello_PySpark.ipynb)

[Scala Hello World ](dataloading/hello_Scala.ipynb)

[SparkR Hello World ](dataloading/hello_sparkR.ipynb)

[DataLoading   - Transforming CSV to Parquet](dataloading/transform-csv-files.ipynb/)

[Data Transfer - Spark to SQL using JDBC ](spark_to_sql/spark_to_sql_jdbc.ipynb/)
=======

This folder contains samples that show how to load data using Spark.

[dataloading/transform-csv-files.ipynb](dataloading/transform-csv-files.ipynb/)
>>>>>>> upstream/master

## Instructions

1. Download and save the notebook file [dataloading/transnform-csv-files.ipynb](dataloading/transform-csv-files.ipynb/) locally.

<<<<<<< HEAD
2. Open the notebook in Azure Data Studio, wait for the “Kernel” and the target context (“Attach to”) to be populated. Set the “Kernel” to **PySpark3** and **Attach to** needs to be the IP address of your big data cluster endpoint.

3. Run each cell in the Notebook sequentially.
=======
1. Open the notebook in Azure Data Studio, wait for the “Kernel” and the target context (“Attach to”) to be populated. Set the “Kernel” to **PySpark3** and **Attach to** needs to be the IP address of your big data cluster endpoint.

1. Run each cell in the Notebook sequentially.
>>>>>>> upstream/master
