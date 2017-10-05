# AdventureWorks Readme

These instructions install AdventureWorks from the source scripts in this Git repo. The repo contains source files for the AdventureWorks databases for SQL Server 2008R2, 2012, and 2014. 

For the complete set of downloads and install options, see these releases:

- [AdventureWorks for Analysis Services](https://github.com/Microsoft/sql-server-samples/releases/tag/adventureworks-analysis-services)
- [AdventureWorks2014](https://github.com/Microsoft/sql-server-samples/releases/tag/adventureworks2014)
- [AdventureWorks2012](https://github.com/Microsoft/sql-server-samples/releases/tag/adventureworks2012)
- [AdventureWorks2008r2](https://github.com/Microsoft/sql-server-samples/releases/tag/adventureworks2008r2)


## 2014 install instructions

These versions of AdventureWorks install on SQL Server 2014 or later.

### Prerequisites
The installs require that full-text search is enabled.  If this is not installed, you can re-run setup and add the feature.

### Determine path variables

Determine the path to your SQL Server installation folder. The instructions refer to this as **{SQL Server Path}**. These are the default paths:

- SQL Server 2014 64-bit: C:\Program Files\Microsoft SQL Server\120\
- SQL Server 2014 32-bit: C:\Program Files (x86)\Microsoft SQL Server\120\ 

Determine the path to the DATA folder for your SQL Server instance. The instructions refer to this as **{DATA path}**. These are the default paths:

- SQL Server 2014 64-bit: C:\Program Files\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA
- SQL Server 2014 32-bit: C:\Program Files (x86)\Microsoft SQL Server\MSSQL12.MSSQLSERVER\MSSQL\DATA


### Install AdventureWorks2014

This is the OLTP version.

1. Create the folder {SQL Server Path}\Tools\Samples\AdventureWorks2014.
2. Copy the files from the [2014-oltp](https://github.com/Microsoft/sql-server-samples/tree/master/samples/databases/adventure-works/2014-oltp) git folder to {SQL Server Path}\Tools\Samples\AdventureWorks2014.	 
3. Open SQL Server Management Studio (SSMS).
4. In SSMS, open the file {SQL Server Path}\Tools\Samples\AdventureWorks2014\instawdb.sql. 
4. In the script, change the :setvar SqlSamplesDatabasePath variable to your {DATA path}.
5. In the script, change the :setvar SqlSamplesSourceDataPath variable to {SQL Server Path}\Tools\Samples\AdventureWorks2014. 
5. On the Query menu, click SQLCMD Mode. 
6. On the Standard toolbar, click the Execute button to run the script. 


### Install AdventureWorksDW2014

This is the data warehouse version.

1. Create the folder {SQL Server Path}\Tools\Samples\AdventureWorksDW2014.
2. Copy the files from the [2014-dw](https://github.com/Microsoft/sql-server-samples/tree/master/samples/databases/adventure-works/2014-dw) git folder to {SQL Server Path}\Tools\Samples\AdventureWorksDW2014.	 
3. Open SQL Server Management Studio (SSMS).
4. In SSMS, open the file {SQL Server Path}\Tools\Samples\AdventureWorksDW2014\instawdbdw.sql. 
4. In the script, change the :setvar SqlSamplesDatabasePath variable to your {DATA path}.
5. In the script, change the :setvar SqlSamplesSourceDataPath variable to {SQL Server Path}\Tools\Samples\AdventureWorksDW2014. 
5. On the Query menu, click SQLCMD Mode. 
6. On the Standard toolbar, click the Execute button to run the script. 

