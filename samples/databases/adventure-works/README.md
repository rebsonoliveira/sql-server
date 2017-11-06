# AdventureWorks Readme

The AdventureWorks databases are sample databases that were originally published for SQL Server 2008.  There are two core sample databases. AdventureWorks is the OLTP sample, and AdventureWorksDW is the data warehouse sample. For some versions of SQL Server, there are additional releases that are intended as one-time only.  

Note that AdventureWorks has not seen any significant changes since the 2012 version. The only differences between the various versions of AdventureWorks are the name of the database and the database compatibility level. For a sample database leveraging more recent features of SQL Server, see [WideWorldImporters](../wide-world-importers/).

To install the AdventureWorks databases with the database compatibility level of your SQL Server instance, you can do use either install from a backup file or a script.

## Install from a backup

For the complete set of downloads, see these releases:

- [AdventureWorks for Analysis Services](https://github.com/Microsoft/sql-server-samples/releases/tag/adventureworks-analysis-services)
- [AdventureWorks2016](https://github.com/Microsoft/sql-server-samples/releases/tag/adventureworks2016)
- [AdventureWorks2014](https://github.com/Microsoft/sql-server-samples/releases/tag/adventureworks2014)
- [AdventureWorks2012](https://github.com/Microsoft/sql-server-samples/releases/tag/adventureworks2012)
- [AdventureWorks2008r2](https://github.com/Microsoft/sql-server-samples/releases/tag/adventureworks2008r2)

## Install from a script

To install **AdventureWorks**, copy the data files and scripts for [AdventureWorks](https://github.com/Microsoft/sql-server-samples/tree/master/samples/databases/adventure-works/oltp-install-script) to your local client. Open [instawdb.sql](https://github.com/Microsoft/sql-server-samples/blob/master/samples/databases/adventure-works/oltp-install-script/instawdb.sql) in SQL Server Management Studio and follow the instructions at the top of the file.

To install **AdventureWorksDW**, copy the data files and scripts for [AdventureWorksDW](https://github.com/Microsoft/sql-server-samples/tree/master/samples/databases/adventure-works/data-warehouse-install-script) to your local client. Open [instawdbdw.sql](https://github.com/Microsoft/sql-server-samples/blob/master/samples/databases/adventure-works/oltp-install-script/instawdbdw.sql) in SQL Server Management Studio and follow the instructions at the top of the file.
