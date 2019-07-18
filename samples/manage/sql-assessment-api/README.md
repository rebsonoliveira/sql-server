# SQL Assessment API samples

Contains samples for customizing SQL Assessment API. Learn more about API and how run it with your own customization here <link to the SQL Assessment docs page>.

## DisablingBuiltInChecks_sample.json

Contains two parts. First shows how you can disable a specified check by its ID. The second disables all the checks with the "TraceFlag" tag.

## MakingCustomChecks_sample.json

Demonstrates how to make a custom rule set containing two checks. The sample contains two schemas: `checks` and `probes`. `Checks` is for check (or rule) definitions. Usually, checks or rules are best practices or a company's internal policies that should be applied to SQL Server. Here's one of the checks from this sample with comments on each property:

```
{
  "target": {                                           //Object to describe which SQL Server object this check is applied.
    "type": "Database",                                     //This check targets at Database object.
    "version": "[12.0,)",                                   //Applies to SQL Server 2014 and higher.
                                                            //Another example: "[12.0,13.0)" reads as "any SQL Server with version >= 12.0 and < 13.0.
    "platform": "Windows",                                  //Applies to SQL Server on Windows.
    "name": { "not": "/^(master|msdb)$/" }                  //Applies to any database but master and msdb.
  },
  "id": "CustomCheck1",                                 //Check ID.
  "tags": [ "InternalBestPracticeSet", "Performance" ], //Tags combine checks in different subsets.
  "displayName": "Query Store should be on",            //Short name for check.
  "description": "The SQL Server Query Store feature provides you with insight on query plan choice and performance. It simplifies performance troubleshooting by helping you quickly find performance differences caused by query plan changes. /n Query Store automatically captures a history of queries, plans, and runtime statistics, and retains these for your review. It separates data by time windows so you can see database usage patterns and understand when query plan changes happened on the server.",
                                                        //Some more detailed explanation of the best practice or policy.
  "message": "Turn Query Store option on to improve query performance troubleshooting.",
                                                        //Usually, it's for recommendation what the user should do if the check fires up
  "helpLink": "https://docs.microsoft.com/sql/relational-databases/performance/monitoring-performance-by-using-the-query-store",
                                                        //Reference material
  "probes": [ "DatabaseConfiguration" ],                //List of probes that are used to get the required data for this check.
                                                        //Probes will be explained below.
  "condition": "@is_query_store_on"                     //Check will pass if condition is true. Otherwise, the check fires up.
}
```

`Probes`, in fact, describe how and where get required data to perform a check. For this, you can use T-SQL queries as well as methods from assemblies. The probe below uses a T-SQL query.
```
"probes":{
  "DatabaseConfiguration": [
    {
    "type": "SQL",
    "target": {
      "type": "Database",
      "version": "(,12.0)",
      "platform": "Windows"
    },
    "implementation": {
      "query": "SELECT db.[is_auto_create_stats_on] AS is_auto_create_stats_on, db.[is_auto_update_stats_on] AS is_auto_update_stats_on, 0 AS is_query_store_on FROM sys.databases AS db WHERE db.[name]='@DatabaseName'"
    }
    },
    {
    "type": "SQL",
    "target": {
      "type": "Database",
      "version": "[12.0,)",
      "platform": "Windows"
    },
    "implementation": {
      "query": "SELECT db.[is_auto_create_stats_on] AS is_auto_create_stats_on, db.[is_auto_update_stats_on] AS is_auto_update_stats_on, db.[is_query_store_on] AS is_query_store_on FROM sys.databases AS db WHERE db.[name]='@DatabaseName'"
    }
    }
  ]
}
```
