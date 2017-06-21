# SSAS Multidimensional Project for WideWorldImporters

This is the SQL Services Analysis Services (SSASMD) project for the analytics database WideWorldImportersDW. It creates Analysis Services cubes based on the WideWorldImportersDW schema, and can be used to run MDX queries against the WideWorldImporters data.

### Contents

[About this sample](#about-this-sample)<br/>
[Before you begin](#before-you-begin)<br/>
[Running the sample](#run-this-sample)<br/>
[Sample details](#sample-details)<br/>
[Disclaimers](#disclaimers)<br/>
[Related links](#related-links)<br/>


<a name=about-this-sample></a>

## About this sample

<!-- Delete the ones that don't apply -->
1. **Applies to:** SQL Server 2016 (or higher)
1. **Key features:** Analysis Services Multidimensional
1. **Workload:** Analytics
1. **Programming Language:**
1. **Authors:** Robert Cain, Jos de Bruijn
1. **Update history:** 21 June 2017 - initial revision

<a name=before-you-begin></a>

## Before you begin

To run this sample, you need the following prerequisites.

**Software prerequisites:**

1. SQL Server 2016 (or higher) with the database WideWorldImportersDW.
2. Visual Studio 2015.
3. SQL Server 2016 (or higher) Analysis Services.

<a name=run-this-sample></a>

## Running the sample

1. Open the solution file wwi-ssasmd.sln in Visual Studio.

2. Build the solution.

3. Make sure you have permission on the SSAS server. From SQL Server Management Studio:
  a. Connect to the Analysis Services server.
  b. In Object Explorer, right-click on the server and select **Properties** to open the properties dialog.
  c. Click on **Security** to navigate to the security page.
  d. Verify that you are listed among server administrators. If not, click **Add** to add your account to the server administrators.

4. Publish the SSASMD database:
  a. In Solution Explorer, open the project **WWI-SSASMD**, and open the **Data Source** node.
  b. Double-click the data source **WideWorldImportersDW.ds** to open the **Data Source Designer**.
  c. Click **Edit** to update the connection string to point to the server that has the existing WideWorldImportersDW database, and verify that the database name is **WideWorldImportersDW**.
  d. Click **Impersonation Information** -> **Use a specific Windows user name and password**, and fill in you user name and password.
  e. Click **Ok** to close the dialog.
  f. Right-click the **WWI-SSASMD** project and select **Properties** to open the properties dialog.
  g. Click on **Deployment** to open the deployment properties.
  h. Update the target server to point to the Analysis Services server, and click **Ok**.
  i. Right-click the **WWI-SSASMD** project and select **Deploy** to deploy the Analysis Services database.


## Sample details

TBD

<a name=disclaimers></a>

## Disclaimers
The code included in this sample is not intended to be used for production purposes.

<a name=related-links></a>

## Related Links
For more information, see these articles:
- [SQL Server Integration Services documentation](https://msdn.microsoft.com/library/ms141026.aspx)
