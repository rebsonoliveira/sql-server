# SQL Server 2019 Feature Notebooks
In this folder, you will find various notebooks that you can use in [Azure Data Studio](https://docs.microsoft.com/sql/azure-data-studio/what-is) to guide you through the new features of SQL Server 2019.

The [What's New](https://docs.microsoft.com/en-us/sql/sql-server/what-s-new-in-sql-server-ver15?view=sql-server-ver15) article covers all the *NEW* features in SQL Server 2019.

## Notebook List
### Intelligent Query Processing
*  **[Scalar_UDF_Inlining.ipynb](https://github.com/microsoft/sql-server-samples/blob/master/samples/features/intelligent-query-processing/notebooks/Scalar_UDF_Inlining.ipynb)** - This notebook demonstrates the benefits of Scalar UDF Inlining along with how to find out which UDFs in your database can be inlined.
* **[IQP_tablevariabledeferred.ipynb](https://github.com/microsoft/sqlworkshops/blob/master/sql2019lab/01_IntelligentPerformance/iqp/iqp_tablevariabledeferred.ipynb)** - In this example, you will learn about the new cardinality estimation for table variables called deferred compilation.
* **[Batch_Mode_on_Rowstore.ipynb](https://github.com/microsoft/sql-server-samples/blob/master/samples/features/intelligent-query-processing/notebooks/Batch_Mode_on_Rowstore.ipynb)** - In this notebook, you will learn about how Batch Mode for Rowstore can help execute queries faster on SQL Server 2019.

### Security 
* **[TDE_on_Standard.ipynb](https://github.com/microsoft/sql-server-samples/blob/master/samples/features/security/tde-sql2019-standard/TDE_on_Standard.ipynb)** - This notebook demonstrates the ability to enable TDE on SQL Server 2019 Standard Edition along with Encryption Scan SUSPEND and RESUME.
* **[TDE_on_Standard_EKM.ipynb](https://github.com/microsoft/sql-server-samples/blob/master/samples/features/security/tde-sql2019-standard/TDE_on_Standard_EKM.ipynb)** - This notebook demonstrates the ability to enable TDE on a SQL Server 2019 Standard Edition using EKM and Azure Key Vault.

### In-Memory Database
* **[MemoryOptimizedTempDBMetadata-TSQL.ipynb](https://github.com/microsoft/sql-server-samples/blob/master/samples/features/in-memory-database/memory-optimized-tempdb-metadata/MemoryOptimizedTempDBMetadata-TSQL.ipynb)** - This is a T-SQL notebook which shows the benefits of Memory Optimized Tempdb metadata.
* **[MemoryOptmizedTempDBMetadata-Python.ipynb](https://github.com/microsoft/sql-server-samples/blob/master/samples/features/in-memory-database/memory-optimized-tempdb-metadata/MemoryOptmizedTempDBMetadata-Python.ipynb)** - This is a Python notebook which shows the benefits of Memory Optimized Tempdb metadata.

### Availability
* **[Basic_ADR.ipynb](https://github.com/microsoft/sqlworkshops/blob/master/sql2019workshop/sql2019wks/04_Availability/adr/basic_adr.ipynb)** - In this notebook, you will see how fast rollback can now be with Accelerated Database Recovery. You will also see that a long active transaction does not affect the ability to truncate the transaction log.
* **[Recovery_ADR.ipynb](https://github.com/microsoft/sqlworkshops/blob/master/sql2019workshop/sql2019wks/04_Availability/adr/recovery_adr.ipynb)** - In this example, you will see how Accelerated Database Recovery will speed up recovery.



