# Samples on how to deploy SQL Sever Big Data Cluster

## Pre-requisites
* CTP 2.3 or later
* mssqlctl CLI familiarity

If you are unfamiilar with mssqlctl please refer to - [App Deployment in SQL Server big data cluster](https://docs.microsoft.com/en-us/sql/big-data-cluster/big-data-cluster-create-apps?view=sqlallproducts-allversions). 

* Tip 
**mssqlctl app -h** will display the various commands to manage the app


## Python 
These samples demonstrates how you can deploy a simple Python app into SQL Server big data cluster as container app as web service that is swagger compliant for building your application.


__[addpy](addpy/)__

__[magic8ball](magic8ball/)__


## R 
These samples demonstrates how you can deploy a simple R app into SQL Server big data cluster as container app as web service that is swagger compliant for building your application. 

__[RollDice](RollDice/)__

This sample demonstrates the use of data frames

## MLeap 
__[mleap](mleap/)__

This sample demonstrates how you use a MLeap bundle (a Spark model serialized in this format) and run it outside of Spark. The sample is based on the MLeap sample available here http://mleap-docs.combust.ml/mleap-serving/. We are using the MLeap Serving container that is published in Docker Hub. The MLeap Serving is deployed as container in SQL Server big data cluster as a container app with a web service that takes the Leap Frame as the input.  


## Sql Server Integration Services 
__[SSIS](SSIS/)__

This sample demonstrates how you can run SSIS applications as a containerized application leveraging the cron capability in Kubernetes. This example uses a Data Transformation Services Package File Format (DTSX) file developed using Visual Studio that, when executed, takes a database backup. This will run as a cron job which creates the backups every minute. Please follow the `README.md` for detailed instructions.
