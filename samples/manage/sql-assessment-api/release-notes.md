# Release notes for SQL Assessment API

This article provides details about updates, improvements, and bug fixes for the current and previous versions of SQL Assessment API. SQL Assessment API is part of the SQL Server Management Objects (SMO) and the SQL Server PowerShell module. Install one of them or both to start working with the API.

Download: [Download SqlServer module](https://www.powershellgallery.com/packages/SqlServer)
Download: [SMO NuGet Package](https://www.nuget.org/packages/Microsoft.SqlServer.SqlManagementObjects)

You can use GitHub issues to provide feedback to the product team.

## GA - November 2019 - 21.1.18206

Version: SqlServer module 21.1.18206, SqlManagementObjects (SMO) package coming soon  

### What's new

- Added 50 assessment rules (144 rules in total so far)
- Added base math expressions and comparisons to rules conditions
- Added support for RegisteredServer object
- Updated way how rules are stored in the JSON format and also updated the mechanism of applying overrides/customizations
- Updated rules to support SQL on Linux
- Updated the ruleset JSON format and added SCHEMA version
- Updated cmdlets output to improve readability of recommendations

### Bug fixes

- Rules were revised and some were fixed
- Broken order of recommendations
- Error messages are not clear

### Known issues

- Invoke-SqlAssessment may crash with message "Missing data item 'FilterDefinition'" on some databases. If you face this issue, create a customization to disable the RedundantIndexes rule to disable it. See README.md to learn how to disable rules. We'll fix this issue with the next release.

- Assemblies providing methods for CLR probes should be recompiled for each new release of SQL Assessment API.


