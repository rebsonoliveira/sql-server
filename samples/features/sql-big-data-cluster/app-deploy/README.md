# App deploy Samples 
## Samples on how to deploy SQL Sever Big Data Cluster

## Pre-requisites
**CTP 2.3 or later
**mssqlctl CLI familiarity

Getting started - [App Deployment in SQL Server Big Data Cluster](https://docs.microsoft.com/en-us/sql/big-data-cluster/big-data-cluster-create-apps?view=sqlallproducts-allversions). 
**Tip** For an interactive help try mssqlctl app -h for a list of commands and how to use them.


## Python 
These samples demonstrates how you can deploy a simple Python app into SQL Server Big Data Cluster as container app as web service that is swagger compliant for building your application.


__[addpy](addpy/)__

__[magic8ball](magic8ball/)__


## R 
These sample demonstrates how you can deploy a simple R app into SQL Server Big Data Cluster as container app as web service that is swagger compliant for building your application. 

__[RollDice](RollDice/)__

This sample demonstrates the use of data framess

## MLeap 
__[hello-mleap](hello-mleap/)__

This sample demonstrates how you use a MLeap bundle ( a Spark model serialized in this format) and run it outside of Spark. The sample is based on the MLeap sample availble here http://mleap-docs.combust.ml/mleap-serving/. We are using the MLeap Serving container that is published in docker hub. The MLeap Serving is deployed as container in SQL Server Big Data Cluster as container app as web service that takes the Leap Frame as the input.  


## Sql Server Integration Services 
__[SSIS](SSIS/)__

This sample demonstrates how you run SSIS application as a containerized application leveraging the cron capability in Kubernets. This example takes Data Transformation Services Package File Format (DTSX) picksa database backup and copies it over to the SQL Server instance for restoring. This will run as a cron job creating the backups every minute. Please follow the README.md for detailed instructions. 
