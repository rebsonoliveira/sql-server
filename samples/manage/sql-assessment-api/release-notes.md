# Release notes for SQL Assessment API

This article provides details about updates, improvements, and bug fixes for the current and previous versions of SQL Assessment API.

## SQL Assessment GA <version-number>

Download: [Download SSMS 18.3.1](download-sql-server-management-studio-ssms.md)  
Build number: 15.0.18183.0  
Release date: October 30, 2019

SSMS 18.3.1 is the latest general availability (GA) release of SSMS. If you need a previous version of SSMS, see [previous SSMS releases](release-notes-ssms.md#previous-ssms-releases).

18.3.1 is an update to 18.2 with the following new items and bug fixes.

## What's new in 18.3.1

| New item | Details |
|---------------------|------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Data Classification | Add Data Classification information to column properties UI (*Information Type*, *Information Type ID*, *Sensitivity Label*, and *Sensitivity Label ID* are not exposed in the SSMS UI). |
| Intellisense/Editor | Updated support for features recently added to SQL Server 2019 (for example, "ALTER SERVER CONFIGURATION"). |
| Integration Services | Add a new selection menu item `Tools > Migrate to Azure > Configure Azure-enabled DTExec` that will invoke SSIS package executions on Azure-SSIS Integration Runtime as Execute SSIS Package activities in ADF pipelines. |
| SMO/Scripting | Added support for Support scripting of Azure SQL DW unique constraint. |
| SMO/Scripting | Data Classification </br> - Added support for SQL version 10 (SQL 2008) and higher. </br> - Added new sensitivity attribute 'rank' for SQL version 15 (SQL 2019) and higher and Azure SQL DB. |
| SMO/Scripting | [SQL Assessment API](../sql-assessment-api/sql-assessment-api-overview.md) - Added versioning to ruleset format. |
| SMO/Scripting | [SQL Assessment API](../sql-assessment-api/sql-assessment-api-overview.md) - Added new checks. |
| SMO/Scripting | [SQL Assessment API](../sql-assessment-api/sql-assessment-api-overview.md) - Added support for Azure SQL Database Managed Instance. |
| SMO/Scripting | [SQL Assessment API](../sql-assessment-api/sql-assessment-api-overview.md) - Updated default view of cmdlets to display results as a table. |

## Bug fixes in 18.3.1

### Known issues (18.3.1)

- Database Diagram created from SSMS running on machine A cannot be modified from machine B (SSMS crashes). See [UserVoice](https://feedback.azure.com/forums/908035/suggestions/37992649) for more details.

- There are redraw issues when switching between multiple query windows. See [UserVoice](https://feedback.azure.com/forums/908035/suggestions/37474042) for more details. A workaround for this issue is to disable hardware acceleration under Tools > Options.

You can reference [UserVoice](https://feedback.azure.com/forums/908035-sql-server) for other known issues and to provide feedback to the product team.
