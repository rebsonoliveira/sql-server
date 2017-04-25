# Forcing last good plan
This code sample demonstrates how automatic tuning
feature in SQL Server 2017 (or higher) can identify and automatically fix performance problems in your workload.

### Contents

[About this sample](#about-this-sample)<br/>
[Before you begin](#before-you-begin)<br/>
[Run this sample](#run-this-sample)<br/>
[Sample details](#sample-details)<br/>
[Disclaimers](#disclaimers)<br/>
[Related links](#related-links)<br/>

<a name=about-this-sample></a>

## About this sample 
1. **Applies to:** SQL Server 2017 (or higher) Enterprise / Developer / Evaluation Edition
2. **Key features:**
    - Automatic tuning / forcing last good plan
    - Query Store
3. **Workload:** Single analytic query executed on WideWorldImporters database
4. **Programming Language:** .NET C#, T-SQL, JavaScript
5. **Author:** Jovan Popovic [jovanpop-msft]

There are two scenarios that can be used in demo:
 - Level 300: T-SQL Sample that simulates workload using T-SQL commands and shows results using dynamic management views.
 - Level 200: ASP.NET Sample that simulates workload using AJAX requests sent to web server and shows results in the web page. 

<a name=before-you-begin></a>

## Before you begin

To run this sample, you need the following prerequisites.

**Software prerequisites:**

1. SQL Server 2017 CTP2.0 (or higher)
2. ASP.NET Core 1.0.1 installed (only if you want to use ASP.NET sample). Optionally Visual Studio Code or Visual Studio 2015 U3 (or higher)

<a name=run-this-sample></a>

## Run this sample

### Setup code
1. Clone this repository using Git for Windows (http://www.git-scm.com/), or download the zip file.
2. Download the WideWorldImporters database and restore it on your server.
3. Execute setup.sql script on your WideWorldImporters database that will add necessary stored procedures and indexes.

### Configure ASP.NET sample (Only for ASP.NET Sample)
1. Open appsettings.json file in the root of the folder and change server, database, username, and password in the connection string.
2. From the project root folder open command prompt and run `dotnet update`, `dotnet build`, and `dotnet run`. These commands will update NuGet packages, build project, and run web app. As an alternative,
open project using Visual Studio 2015 U3, or Visual Studio Code, compile and run sample.

<a name=sample-details></a>

This sample demonstrates how SQL Server 2017 analyzes workload, keep track about the last good
plan that successfully executed the query, and reverts new plan if it is worse that the previous.

### T-SQL Sample
Open demo-full.sql and follow the comments in the code.
#### Part I - regression detection
 - Execute query `EXEC dbo.report 7` 30-300 times. SQL Database will collect statistics about the query. Number of queries that should be executed to might vary depending on performance of your server.
 - Execute query `EXEC dbo.regression` to cause the regression.
 - Execute query `EXEC dbo.report 7` 20 times and verify that the execution is slower.
 - Query `sys.dm_db_tuning_recommendations` and verify that regression is detected and that
 correction script is in the view
 - Open Query Store UI in SSMS (e.g. "Top Resource Consuming Queries") and find the query. Verify that there are two plans - one faster with **Hash Aggregate** and another slower with **Stream Aggregate**

![Last good plan](../../../../media/features/automatic-tuning/flgp-query-store-ui-last-good-plan.png "Last good plan")
Fig. 1. Optimal plan with "Hash Aggregate".

![Regressed plan](../../../../media/features/automatic-tuning/flgp-query-store-ui-regressed-plan.png "Regressed plan")
Fig. 2. Regressed plan with "Stream Aggregate".

 - Take the script from the `sys.dm_db_tuning_recommendations` view and force the recommended plan.
 - Execute query `EXEC dbo.report 7` 20 times and verify that the execution is faster. Open Query Store UI in SSMS (e.g. "Top Resource Consuming Queries"), find the query, verify that the plan is forced and that the regression is fixed.

#### Part II - Automatic tuning
 - Reset the database state by executing `EXEC dbo.initialize`, and enable automatic tuning on database.
 - Execute query `EXEC dbo.report 7` 30-300 times.
 - Execute query `EXEC dbo.regression` to cause the regression.
 - Execute query `EXEC dbo.report 7` 20 times and verify that the execution is slower.
 - Query `sys.dm_db_tuning_recommendations` and verify that regression is detected and that
 recommendation is in **Verifying** state.
 - Open Query Store views (e.g. "Top Resource Consuming Queries") and find the query. Verify that there are two plans - one with **Hash Aggregate** and another with **Stream Aggregate**. Better plan should be forced, and you should see that the forced plan has better performance than regressed plan.

### ASP.NET Core Sample

This code sample contains a simple web page that periodically sends HTTP request to the Web server. Web server executes T-SQL query against the database, returns query result and calculates elapsed time.
Web page collects response from the web server, calculates expected throughput based on the
last 10 T-SQL request durations, and displays how many requests per second can be executed.

![Web app](../../../../media/features/automatic-tuning/flgp-web-ui.png "Demo web app")
Fig. 3. Number of requests per seconds.

In default state, automatic tuning is turned OFF on the database. You can press **Regression**
button to cause SQL plan choice regression in database layer. On the user interface will be shown decreased number of requests per seconds that can be served.

![Web app](../../../../media/features/automatic-tuning/flgp-web-ui-regression.png "Demo web app")
Fig. 4. Number of requests per seconds after regression.

If you refresh the page, the database state will be cleaned (i.e. query store and plan cache will be cleaned). You can turn on automatic tuning, wait some time to SQL Database analyze the workload and cause the regression again. You will notice that there is a regression that will be automatically corrected after some time. Pressing the **Regression** button again will not cause any regression.

<a name=disclaimers></a>

## Disclaimers
The code included in this sample is not intended to be a set of best practices on how to build scalable enterprise grade applications. This is beyond the scope of this quick start sample.

<a name=related-links></a>

## Related Links

- [Automatic tuning in SQL Server 2017 CTP2.0+] (https://docs.microsoft.com/sql/relational-databases/automatic-tuning/automatic-tuning)
- [Monitoring Performance By Using the Query Store] (https://docs.microsoft.com/en-us/sql/relational-databases/performance/monitoring-performance-by-using-the-query-store)

