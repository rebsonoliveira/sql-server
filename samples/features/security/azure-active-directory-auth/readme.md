# Token Authentication sample for Azure Active Directory

### Contents

[About this sample](#about-this-sample)<br/>
[Run this sample](#run-this-sample)<br/>
[Sample details](#sample-details)<br/>




## About this sample

The Token project contains a simple console application that connects to Azure SQL database using a self-signed certificate. 

**Software prerequisites:**


1. The `makecert.exe` utility, which is included in the Windows SDK 
	+ It is sometimes included in Visual Studio installations (depending on the selections made during installation). A search of your machine for `makecert.exe` would provide verification that the Windows SDK was installed. 
	+ If the Windows SDK was not installed, you may [download it here](http://msdn.microsoft.com/en-US/windows/desktop/aa904949)
	+ You can learn more about the `makecert.exe` [utility here](https://msdn.microsoft.com/library/windows/desktop/aa386968.aspx) 

**Other Prerequisites** 

TODO: Other Prerequisites

<a name=run-this-sample></a>
## Run this sample

1.	Create an application account in Azure AD for your service.
	- Sign in to the Azure management portal.
	- Click on Azure Active Directory in the left hand navigation
	- Click the directory tenant where you wish to register the sample application. This must be the same directory that is associated with your database (the server hosting your database).
	- Click the Applications tab
	- In the drawer, click Add.
	- Click "Add an application my organization is developing".
	- Enter mytokentest as a friendly name for the application, select "Web Application and/or Web API", and click next.
	- Assuming this application is a daemon/service and not a web application, it doesn't have a sign-in URL or app ID URI. For these two fields, enter http://mytokentest
	- While still in the Azure portal, click the Configure tab of your application.
	- Find the Client ID value and copy it aside, you will need this later when configuring your application ( i.e.  a4bbfe26-dbaa-4fec-8ef5-223d229f647d  /see the snapshot below/)

![active directory portal Client ID image](img/azure-active-directory-application-portal.png)

2. Logon to your Azure SQL Server’s user database as an Azure AD admin and using a T-SQL command
provision a contained database user for your application principal:
```sql
CREATE USER [mytokentest] FROM EXTERNAL PROVIDER
```
	- [See this link](https://azure.microsoft.com/en-us/documentation/articles/sql-database-aad-authentication/) for more details on how to create an Azure Ad admin and a contained database user.

3. On the machine you are going to run the project on, generate and install a self-signed certificate. 
	- To complete this step, you will need to use `Makecert.exe` 
	- Open a command prompt window
	- Navigate to a folder where you want to generate a certificate file ( such as the folder where the demo files are) and change the following command for your environment 
	```
	<Windows SDK Path>\makecert.exe -r -pe -n "CN=Cert_name" -ss My -len 2048 Cert_name.cer
	```
	for example, like so: 
	```
	c:/"Program Files (x86)/Windows Kits/8.1/bin/x64"/makecert -r -pe -n "CN=mytokentestCert" -ss My -len 2048 mytokentestCert.cer
	```
4. Add the certificate as a key for the application you created in Azure AD. 
	TODO: Finish Instructions
