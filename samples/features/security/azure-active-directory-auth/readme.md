# Sample name

### Contents

[About this sample](#about-this-sample)<br/>
[Before you begin](#before-you-begin)<br/>
[Run this sample](#run-this-sample)<br/>
[Sample details](#sample-details)<br/>
[Disclaimers](#disclaimers)<br/>
[Related links](#related-links)<br/>

<a name=about-this-sample></a>
## About this sample

<!-- Delete the ones that don't apply -->
- **Applies to:** Azure SQL Database, Azure SQL Data Warehouse 
- **Key features:** Azure Active Directory Authentication 
- **Programming Language:** C#
- **Authors:** Mirek Sztajno [mireks-msft]

## About this sample

<a name=before-you-begin></a>

## Before you begin

To run this sample, you need the following prerequisites:

**Software prerequisites:**

1. Visual Studio 2015 (or higher) with the latest SSDT installed (using .Net Framework 4.6 or higher)
	+ .Net Framework 4.6 must be set as the target framework for the Visual Studio project. To do this, double-click on Properties in Solution Explorer, then click the Application tab and check that the Target framework is set to .Net Framework 4.6
	+ To install .Net Framework 4.6, see https://msdn.microsoft.com/library/5a4x27ek.aspx
2. Active Directory Authentication Library for SQL Server (ADALSQL.DLL)
	+ ADALSQL.DLL enables applications to authenticate to Microsoft Azure SQL Database using Azure Active Directory. The ADALSQL.DLL is not installed with Visual Studio so download the DLL at http://www.microsoft.com/en-us/download/details.aspx?id=48742
	+ ADALSQL.DLL is automatically downloaded with Visual Studio 2015 Update 2, SQL Server Management Studio, and the newest version of SQL Server Data tools 

**Azure prerequisites:**
1. Azure Active Directory (AD) 
2. Permission to create an Azure SQL Database
3. ??? 

**Other Prerequisites** 

1. For Azure Active Directory integrated authentication, a Computer joined to a domain that is federated with Azure Active Directory.
2. A contained database user representing your Azure AD principal (or one of the groups you belong to) must exist in the database and must have at least the CONNECT permission. 

<a name=run-this-sample></a>

## Run this sample

<!-- Place sample links here --> 

[Integrated Demo] (/integrated)

[Password Demo] (/password)

<a name=sample-details></a>

## Sample details

This demo provides a tool for exploring Azure Active Directory authentication to Azure SQL DB or Azure SQL DW.

Azure Active Directory authentication with Azure SQL Database V12 supports the following authentication methods:
- User/password authentication  
- Integrated authentication 
- Application token authentication [Demo coming soon!]

<a name=disclaimers></a>

## Disclaimers
The code included in this sample is only intended to provide a method to demonstrate sucessful authentication to Azure SQL Database or Azure SQL Data Warehouse via Azure Active Directory authentication methods.  

<a name=related-links></a>
## Related Links
<!-- Links to more articles. Remember to delete "en-us" from the link path. -->

<!-- For more information, see these articles: --> 
