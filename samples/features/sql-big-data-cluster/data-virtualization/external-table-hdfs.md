# Query data in HDFS from SQL Server master

In SQL Server 2019 big data clusters, the SQL Server engine has gained the ability to natively read HDFS files, such as CSV and parquet files, by using SQL Server instances collocated on each of the HDFS data nodes to filter and aggregate data locally in parallel across all of the HDFS data nodes.

In this example, you are going to create an external table in the SQL Server Master instance that points to data in HDFS within the SQL Server Big data cluster. Then you will join the data in the external table with high value data in SQL Master instance.

## Instructions

1. Connect to SQL Server Master instance.

1. Execute the [external-table-hdfs.sql](external-table-hdfs.sql).