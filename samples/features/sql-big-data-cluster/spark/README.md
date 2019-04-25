# SQL Server big data clusters

SQL Server Big Data cluster bundles Spark and HDFS together with SQL server. Azure Data Studio IDE provides built in notebooks that enables data scientists and data engineers to run Spark notebooks and job in Python, R, or Scala code against the Big Data Cluster. This folder contains spark sample notebook on using Spark in SQL server Big data cluster

## Folder contents

[PySpark Hello World](dataloading/hello_PySpark.ipynb)

[Scala Hello World ](dataloading/hello_Scala.ipynb)

[SparkR Hello World ](dataloading/hello_sparkR.ipynb)

[DataLoading   - Transforming CSV to Parquet](dataloading/transform-csv-files.ipynb/)

[Data Transfer - Spark to SQL using Spark JDBC connector](data-virtualization/spark_to_sql_jdbc.ipynb/)

[Data Transfer - Spark to SQL using MSSQL Spark connector](spark_to_sql/mssql_spark_connector.ipynb/)

## Instructions on how to run in Azure Data Studio

[data-loading/transform-csv-files.ipynb](dataloading/transform-csv-files.ipynb/)

2. From Azure Data Studio Connect to the SQL Server Master instance in a big data cluster. 

3. Right-click on the server name, select **Manage**, switch to **SQL Server Big Data Cluster** tab, and open the notebook in Azure Data Studio.  Wait for the “Kernel” and the target context (“Attach to”) to be populated. If required set the relevant “Kernel” ( e.g **PySpark3** )  and **Attach to** needs to be the IP address of your big data cluster endpoint.

4. Run each cell in the Notebook sequentially.
