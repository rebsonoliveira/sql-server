# ASP.NET Session State with SQL Server 2016 
We are excited to offer two new SQL Server scripts (with and without retry-logic) to be used with the ASP.NET Session State provider! 

The scripts take advantage of memory optimized tables and natively compiled stored procedures to create the necessary database objects that the ASP.NET session state provider requires when SQL Server is used as a storage option for session data. These scripts are based on work from early adopters that modified their SQL Server objects to take advantage of In-Memory OLTP for ASP.NET session state, with great success. To learn more, read the bwin.party case study [Gaming site can scale to 250,000 requests per second and improve player experience](https://www.microsoft.com/danmark/cases/Microsoft-SQL-Server-2014/bwin.party/Gaming-Site-Can-Scale-to-250-000-Requests-Per-Second-and-Improve-Player-Experience/710000003117). 

**This is the recommended way to implement ASP.NET session state with SQL Server 2016**.


### Contents

[About this sample](#about-this-sample)<br/>
[Before you begin](#before-you-begin)<br/>
[Install scripts](#install-scripts)<br/>
[Disclaimers](#disclaimers)<br/>
[Related links](#related-links)<br/>

<a name=about-this-sample></a>

## About this sample

1. **Applies to:** SQL Server 2016 (or higher) Enterprise / Developer / Evaluation Edition, Azure SQL Database (Premium)
2. **Key features:**
	- ASP.NET Session State Provider
	- Memory Optimized Tables
	- Natively Compiled Stored Procedures
4. **Programming Language:** T-SQL
5. **Authors:** Perry Skountrianos [perrysk-msft]

<a name=before-you-begin></a>

## Before you begin

**Software prerequisites:**

1. SQL Server 2016 (or higher) Enterprise / Developer / Evaluation Edition or Azure SQL Database (Premium)
2. .NET Framework 2.0 or higher

<a name=install-scripts></a>

## Install Scripts
There are two versions of the SQL Server T-SQL script:

-   aspstate_sql2016\_no\_retry\_logic.sql:  [Link]()
-   aspstate_sql2016\_with\_retry\_logic.sql:  [Link]()

Based on your workload characteristics and the way your application handles session state you have to decide if retry logic is needed or not. [This](https://msdn.microsoft.com/en-us/library/mt668435.aspx) article explains the logic used to detect conflict and implement retry logic in the script. Currently, the two memory-optimized tables:  **dbo.ASPStateTempApplications** and **dbo.ASPStateTempSessions** in both of the scripts are created with **DURABILITY = SCHEMA_ONLY** meaning that in a case of a SQL Server restart or a reconfiguration occurs in an Azure SQL Database, the table schema persists, but data in the table is lost. If durability of both schema and data is required tthe script needs to be altered and the two tables above need to be created with: **DURABILITY=SCHEMA\_AND\_DATA**.[This](https://msdn.microsoft.com/en-us/library/dn553122.aspx) article explains the two durability options for memory-optimized tables

Note: Although both of these scripts have been tested, we always recommend executing your own testing and validation to understand how these scripts behave in your specific environment.    

Follow the steps below to configure SQL Server 2016 In-Memory OLTP to store ASP.NET Session State:
 
1. Follow [this](https://support.microsoft.com/en-us/kb/317604) link to configure SQL Server to Store ASP.NET Session State  
2. Open the script in SQL Server Management Studio ([Download Link](https://support.microsoft.com/en-us/kb/317604))
3. Connect to the SQL Server that you want to use.  
4. Execute (F5)
 
The script should execute with no errors and should create the **ASPState** database with the following objects:

Tables:
-
- dbo.ASPStateTempApplications
- dbo.ASPStateTempSessions

Stored Procedures
-
- dbo.TempGetStateItemExclusive3
- dbo.TempInsertStateItemShort
- dbo.TempUpdateStateItemLong
- dbo.TempUpdateStateItemLongNullShort
- dbo.TempUpdateStateItemShort
- dbo.CreateTempTables
- dbo.DeleteExpiredSessions
- dbo.GetHashCode
- dbo.GetMajorVersion
- dbo.TempGetAppID
- dbo.TempGetStateItem
- dbo.TempGetStateItem2
- dbo.TempGetStateItem3
- dbo.TempGetStateItemExclusive
- dbo.TempGetStateItemExclusive2
- dbo.TempGetVersion
- dbo.TempInsertStateItemLong
- dbo.TempInsertUninitializedItem
- dbo.TempReleaseStateItemExclusive
- dbo.TempRemoveStateItem
- dbo.TempResetTimeout
- dbo.TempUpdateStateItemShortNullLong

<a name=sample-details></a>

## Disclaimers
The code included in this sample is not intended to be a set of best practices on how to build scalable enterprise grade applications. This is beyond the scope of this quick start sample.

<a name=related-links></a>

## Related Links
<!-- Links to more articles. Remember to delete "en-us" from the link path. -->

For more information, see these articles:

- [In-Memory OLTP (In-Memory Optimization)](https://msdn.microsoft.com/en-us/library/dn133186.aspx)
- [OLTP and database management](https://www.microsoft.com/en-us/server-cloud/solutions/oltp-database-management.aspx)
- [Session State Provider](https://msdn.microsoft.com/en-us/library/aa478952.aspx)
- [Implementing a Session-State Store Provider](https://msdn.microsoft.com/en-us/library/ms178587.aspx)
