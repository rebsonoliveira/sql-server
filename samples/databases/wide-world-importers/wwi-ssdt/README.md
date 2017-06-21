# WideWorldImporters OLTP Database

The Visual Studio SQL Server Data Tools project in this folder is used to construct the WideWorldImporters database from scratch on SQL Server or Azure SQL Database. It is possible to vary the data size.

A pre-created version of the database is available for download as part of the latest release of the sample: [wide-world-importers-release](http://go.microsoft.com/fwlink/?LinkID=800630).

### Contents

[About this sample](#about-this-sample)<br/>
[Before you begin](#before-you-begin)<br/>
[Run this sample](#run-this-sample)<br/>
[Disclaimers](#disclaimers)<br/>


<a name=about-this-sample></a>

## About this sample

<!-- Delete the ones that don't apply -->
1. **Applies to:** SQL Server 2016 (or higher), Azure SQL Database [testing and modified instructions are TBD]
1. **Key features:** Core database features
1. **Workload:** OLTP
1. **Programming Language:** Transact-SQL
1. **Authors:** Greg Low, Denzil Ribeiro, Jos de Bruijn, Robert Cain

The instructions below are for creating the sample database from scratch.

A pre-created version of the database is available for download as part of the latest release of the sample: [wide-world-importers-release](http://go.microsoft.com/fwlink/?LinkID=800630).

<a name=before-you-begin></a>

## Before you begin

To run this sample, you need the following prerequisites.

**Software prerequisites:**

1. SQL Server 2016 SP1 (or higher) or an Azure SQL Database. Also works with SQL Server 2016 RTM, for Evaluation, Developer, and Enterprise edition.
2. Visual Studio 2015 Update (or higher) with SQL Server Data Tools (SSDT). We recommend you update to the latest available of SSDT from the Visual Studio Extensions and Updates feed.


<a name=run-this-sample></a>

## Run this sample

The below steps reconstruct the WideWorldImporters database.

Note that each time the database is created from scratch, the data in many tables will be different as a degree of randomization is used throughout the code.

<!-- Step by step instructions. Here's a few examples -->

### Publishing to SQL Server

1. Open the solution **wwi-ssdt.sln** in Visual Studio. Skip this step if you have already opened the solution **wwi-sample.sln** in the root of this sample.

2. Build the solution.

3. Publish the WideWorldImporters database:
    a. In the Solution Explorer, right-click the **WideWorldImporters** project, and select **Publish** to bring up the **Publish Database** dialog.
    b. Click **Edit** to modify the **Target Database Connection** to point to your SQL Server 2016 (or later) instance.
    c. Edit the **Database Name** to say "WideWorldImporters".
    d. Click **Publish**.
    e. Wait for publication to finish. You can monitor progress in the **Data Tools Operations** page in Visual Studio. In testing this took around 3 minutes.

4. (Optional) Data population: After step 3, the database contains data for January 2013. This step populates data from February 2013 up to the current data.
    a. Open SQL Server Management Studio, and connect to the WideWorldImporters database that was published in the previous step.
    b. Execute the following script. This may take a while to complete - populating data from Feb 2013 to Jun 2016 took about 40 minutes in one test.

```
    EXEC DataLoadSimulation.PopulateDataToCurrentDate
    @AverageNumberOfCustomerOrdersPerDay = 60,
    @SaturdayPercentageOfNormalWorkDay = 25,
    @SundayPercentageOfNormalWorkDay = 0,
    @IsSilentMode = 0,
    @AreDatesPrinted = 1;
```

        To customize the period for data generation, leverage the stored procedure `DataLoadSimulation.DailyProcessToCreateHistory`.
<br/><br/>The referenced stored procedure removes the temporal nature of the tables, and implements a series of triggers. It then emulates typical activities that would occur during each day. Finally, it removes the triggers and re-establishes the temporal tables. You can see the progress of the simulation in the Messages tab in SSMS as the query executes. (AreDatesPrinted controls whether dates are printed to the messages window as data is generated. IsSilentMode controls whether detailed output is printed. IsSilentMode = 1 produces just date output if AreDatesPrinted = 1.).
Note that a different outcome is produced each time it is run as it uses many random values.
StartDate and EndDate cover the period for generation. Other code populates the 2012 period when expanding the columnstore tables so do not populate back into 2012 or earlier with this procedure. The EndDate must also be at or before the current date as temporal tables do not allow future dates.
You can configure the amount of data produced by modifying the number of orders per day. The default is 60 orders and produces a reasonable OLTP database size of around 93MB compressed. You are also able to configure how busy Saturday and Sunday are compared to normal Monday to Friday working days, as a percentage. The suggested values are 50% for Saturday and 0% for Sunday.

### Publishing to Azure SQL Database

TBD

<a name=disclaimers></a>

## Disclaimers
The code included in this sample is not intended to be used for production purposes.
