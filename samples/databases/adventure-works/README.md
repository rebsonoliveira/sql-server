# AdventureWorks and AdventureWorksDW Readme

The AdventureWorks databases are sample databases that were originally published for SQL Server 2008.  AdventureWorks is the OLTP sample, and AdventureWorksDW is the data warehouse sample. For some versions of SQL Server, there are additional variations that are one-time only releases. 

The database tables are the same for all releases of SQL Server. However, the database compatibility level and version-specific information is different according to the version of SQL Server. Therefore, if you install AdventureWorks2014 on SQL Server 2016, the database will not be running at the compatibility level for SQL Server 2016. When this happens, new features in SQL Server might not work on the sample database.

To install the AdventureWorks databases with the database compatibility level of your SQL Server instance, you can install from a version-specific backup file or from the install script. 


## Install from a script

The install scripts create the sample database to have the database compatibility of your current version of SQL Server. Each script generates the version-specific information based on your current instance of SQL Server. This means you can use either the AdventureWorks or AdventureWorksDW install script on any version of SQL Server including CTPs, SPs, and interim releases.


### To install AdventureWorks

1. Copy the GitHub data files and scripts for [AdventureWorks](https://github.com/Microsoft/sql-server-samples/tree/master/samples/databases/adventure-works/oltp-install-script) to the C:\Samples\AdventureWorks folder on your local client. 
2. Or, [download AdventureWorks-oltp-install-script.zip](https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorks-oltp-install-script.zip) and extract the zip file to the C:\Samples\AdventureWorks folder.
3. Open C:\Samples\AdventureWorks\instawdb.sql in SQL Server Management Studio and follow the instructions at the top of the file. 

### To install AdventureWorksDW

1. Copy the GitHub data files and scripts for [AdventureWorksDW](https://github.com/Microsoft/sql-server-samples/tree/master/samples/databases/adventure-works/data-warehouse-install-script) to the C:\Samples\AdventureWorksDW folder on your local client. 
2. Or, [download AdventureWorksDW-data-warehouse-install-script.zip](https://github.com/Microsoft/sql-server-samples/releases/download/adventureworks/AdventureWorksDW-data-warehouse-install-script.zip) and extract the zip file to the C:\Samples\AdventureWorksDW folder.
3. Open C:\Samples\AdventureWorksDW\instawdbdw.sql in SQL Server Management Studio and follow the instructions at the top of the file.

When installing from a script, the default database name is AdventureWorks or AdventureWorksDW.  If you want the version added to the name, edit the database name at the beginning of the script.  

## Install from a backup

Download backup files from [AdventureWorks samples databases](https://github.com/Microsoft/sql-server-samples/releases/tag/adventureworks) on GitHub.

You can install AdventureWorks or AdventureWorksDW by restoring a backup file. The backup files are version-specific. You can restore each backup to its respective version of SQL Server, or a later version. 

For example, you can restore AdventureWorks2016 to SQL Server (starting with 2016). Regardless of whether AdventureWorks2016 is restored to SQL Server 2016, 2017, or a later version, the restored database has the database compatibility level of SQL Server 2016.

### To restore a database backup

1. Locate the Backup folder for your SQL Server instance.  The default path for 64-bit SQL Server 2016 is C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup. The MSSQL value is MSSQL14 for SQL Server 2017, MSSQL13 for SQL Server 2016, MSSQL12 for SQL Server 2014, MSSQL11 for SQL Server 2012, and MSSQL10 for SQL Server 2008R2.
2. Download the .bak file from [AdventureWorks release](https://github.com/Microsoft/sql-server-samples/releases/tag/adventureworks) and save it to the Backup folder for your SQL Server instance.
3. Open SQL Server Management Studio and connect to your SQL Server instance.
4. Restore the database using the SQL Server Management Studio user interface. For more information, see [Restore a database backup using SSMS](https://docs.microsoft.com/sql/relational-databases/backup-restore/restore-a-database-backup-using-ssms).
5. Or, run the RESTORE DATABASE command in a new query Window. 
On the Standard toolbar, click the New Query button. 
5. Execute the following code in the query window. Note, the file paths in the scripts are the default paths. You may need to update the paths in the scripts to match your environment.

### Example T-SQL RESTORE DATABASE command

This example restores AdventureWorksDW2016 to SQL Server 2016. Note, the file paths are the default paths. If you use this example, you might need to update the paths in the scripts to match your environment.

```sql

USE [master]

RESTORE DATABASE AdventureWorksDW2016
FROM disk= 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup\AdventureWorksDW2016.bak'
WITH MOVE 'AdventureWorksDW2016_data' 
TO 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\AdventureWorksDW2016.mdf',
MOVE 'AdventureWorksDW2016_Log' 
TO 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\AdventureWorksDW2016.ldf'
,REPLACE

```

