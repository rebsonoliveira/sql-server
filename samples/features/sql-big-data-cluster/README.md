# SQL Server big data clusters

## Pre-requisites
1. Kubernetes cluster configuration & Kubectl command-line utility
2. Curl utility
3. Sqlcmd and bcp utility (Installation instructions [here for Linux](https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-setup-tools?view=sql-server-ver15) and [here for Windows](https://www.microsoft.com/en-us/download/details.aspx?id=53591))
4. Azure Data Studio or SQL Server Management Studio
5. SQL Server 2019 big data cluster

Installation instructions for SQL Server 2019 big data cluster can be found [here](https://docs.microsoft.com/en-us/sql/big-data-cluster/deployment-guidance?view=sql-server-2017).

## Samples Setup

**Before you begin**, run the CMD script called [bootstrap-sample-db.cmd](bootstrap-sample-db.cmd) or the shell script [bootstrap-sample-db.sh](bootstrap-sample-db.sh) depending on your platform. This script does the following operations:

1. Downloads the tpcx-bb 1GB sample database
1. Restores the database on the SQL Master instance
1. Executes the bootstrap-sample-db.SQL script
1. Exports the web_clickstreams, inventory, customer & product_reviews tables to files
1. Uploads the web_clickstreams CSV file to the HDFS inside the SQL Server 2019 big data cluster

__[data-pool](data-pool/)__

SQL Server 2019 big data cluster contains a data pool which consists of many SQL Server instances to store data & query in a scale-out manner.

### Data ingestion using Spark
The sample script [data-pool/data-ingestion-spark.sql](data-pool/data-ingestion-spark.sql) shows how to perform data ingestion from Spark into data pool table(s).

### Data ingestion using sql
The sample script [data-pool/data-ingestion-sql.sql](data-pool/data-ingestion-sql.sql) shows how to perform data ingestion from T-SQL into data pool table(s).

__[data-virtualization](data-virtualization/)__

SQL Server 2019 or SQL Server 2019 big data cluster can use PolyBase external tables to connect to other data sources.

### External table over Storage Pool
SQL Server 2019 big data cluster contains a storage pool consisting of HDFS, Spark and SQL Server instances. The [data-virtualization/storage-pool](data-virtualization/storage-pool) folder contains samples that demonstrate how to query data in HDFS inside SQL Server 2019 big data cluster.

### External table over Oracle
SQL Server 2019 uses new ODBC connectors to enable connectivity to SQL Server, Oracle, Teradata, MongoDB and generic ODBC data sources.

The [data-virtualization/oracle](data-virtualization/oracle) folder contains samples that demonstrate how to query data in Oracle using external tables.

__[deployment](deployment/)__

The [deployment](deployment) folder contains the scripts for deploying a Kubernetes cluster for SQL Server 2019 big data cluster.

__[machine-learning](machine-learning/)__

SQL Server 2016 added support executing R scripts from T-SQL. SQL Server 2017 added support for executing Python scripts from T-SQL. SQL Server 2019 adds support for executing Java code from T-SQL. SQL Server 2019 big data cluster adds support for executing Spark code inside the big data cluster.

### SQL Server Machine Learning Services
The [machine-learning\sql](machine-learning\sql) folder contains the sample SQL scripts that show how to invoke R, Python, and Java code from T-SQL.

### Spark Machine Learning
The [machine-learning\spark](machine-learning\spark) folder contains the Spark samples.
