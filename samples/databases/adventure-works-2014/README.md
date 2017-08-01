# AdventureWorks2014 Sample Databases for SQL Server

AdventureWorks2014 is a sample database for SQL Server. It works with SQL Server 2014 and later versions. 

**Latest release**: [AdventureWorks2014 release](https://github.com/Microsoft/sql-server-samples/releases/tag/adventureworks2014)

**Feedback on the sample**: send to [sqlserversamples@microsoft.com](mailto:sqlserversamples@microsoft.com)

### Contents

[About this sample](#about-this-sample)<br/>
[Before you begin](#before-you-begin)<br/>
[Disclaimers](#disclaimers)<br/>
[Related links](#related-links)<br/>


<a name=about-this-sample></a>

## About this sample

<!-- Delete the ones that don't apply -->
1. **Applies to:** SQL Server 2014 (or higher)
1. **Key features:** Core database features
1. **Workload:** OLTP
1. **Programming Language:** T-SQL, C#
1. **Update history:**
	31 July 2017 - Initial migration from Codeplex



<a name=before-you-begin></a>

## Before you being

To run this sample, you need the following prerequisites:

### Software prerequisites

1. SQL Server 2014 (or later)
2. [SQL Server Management Studio](https://docs.microsoft.com/sql/ssms/download-sql-server-management-studio-ssms) 


<a name=run-this-sample></a>

## Install AdventureWorks2014 database from a backup

The Adventure Works 2014 OLTP database can be installed by restoring a database backup. 

1.	Download the Adventure Works 2014 Full Database Backup.zip.
2.	From File Download, click Save. Once it is saved, open the folder.
3.	Extract the AdventureWorks2014.bak file to a location on your local server. Note: The default 64-bit path is C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Backup. Use C:\Program Files (x86)\... for 32-bit SQL Server 2014.
4.	From SQL Server Management Studio connect to the 2014 instance.
5.	On the Standard toolbar, click the New Query button. 
6.	Execute the following code in the query window:
Note: The file paths in the scripts are the default paths. You may need to update the paths in the scripts to match your environment.

```sql
USE [master]

RESTORE DATABASE AdventureWorks2014
FROM disk= 'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Backup\AdventureWorks2014.bak'
WITH 
MOVE 'AdventureWorks2014_data' TO 'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\AdventureWorks2014.mdf',
MOVE 'AdventureWorks2014_Log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\AdventureWorks2014.ldf'
,REPLACE
```
As an alternative to steps 5 and 6, you can restore the database using the SQL Server Management Studio user interface. For more detailed information, see Restore a Database Backup (SQL Server Management Studio)  . 

## Install AdventureWorksDW2014 from a database backup

To install AdventureWorksDW2014 from a database backup:

1.	Download [adventure-works-2014-full-database-backup.zip](https://github.com/Microsoft/sql-server-samples/releases/tag/adventureworks2014).
2.	Extract the AdventureWorks2014.bak file to a location on your local server. Note: The default 64-bit path is C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Backup. Use C:\Program Files (x86)\... for 32-bit SQL Server 2014.
3.	From SQL Server Management Studio connect to the 2014 instance.
4.	On the Standard toolbar, click the New Query button. 
5.	Execute the following code in the query window: Note: The file paths in the scripts are the default paths. You may need to update the paths in the scripts to match your environment.

```sql
USE [master]

RESTORE DATABASE AdventureWorksDW2014
FROM disk= 'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\Backup\AdventureWorksDW2014.bak'
WITH MOVE 'AdventureWorksDW2014_data' TO 'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\AdventureWorksDW2014.mdf',
MOVE 'AdventureWorksDW2014_Log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA\AdventureWorksDW2014.ldf'
,REPLACE
```

As an alternative to steps 5 and 6, you can restore the database SQL Server Management Studio user interface. For more detailed information, see [Restore a Database Backup using SSMS](https://docs.microsoft.com/sql/relational-databases/backup-restore/restore-a-database-backup-using-ssms). 


<a name=disclaimers></a>

## Disclaimers
The code included in this sample is not intended to be used for production purposes.

<a name=related-links></a>

## Related Links
<!-- Links to more articles. Remember to delete "en-us" from the link path. -->
For more information, see these articles:
- [SQL Server 2014 product page](https://msdn.microsoft.com/library/dn197878(v=sql.10).aspx) 
- [SQL Documentation](https://docs.microsoft.com/en-us/sql/#pivot=main&panel=databases)
