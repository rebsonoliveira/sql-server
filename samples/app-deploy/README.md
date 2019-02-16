# App deploy Samples CTP 2.3
## Samples on how to deploy SQL Sever Big Data Cluster


## Python 
These sample demonstrates how you can deploy a simple Python app into SQL Server Big Data Cluster as container app as web service that is swagger compliant for building your application.

__[addpy](addpy/)__

This sample demonstrates how to deploy a Python script that takes integers as input and outputs an integer.

__[magic8ball](magic8ball/)__

This sample demonstrates how to deploy a Python script that takes a string as input and outputs a string.



## R 
These sample demonstrates how you can deploy a simple R app into SQL Server Big Data Cluster as container app as web service that is swagger compliant for building your application. 

__[RollDice](RollDice/)__

This sample demonstrates the use of data framess

## MLeap 
__[hello-mleap](hello-mleap/)__

This sample demonstrates how you use a MLeap bundle ( a Spark model serialized in this format) and run it outside of Spark. The sample is based on the MLeap sample availble here http://mleap-docs.combust.ml/mleap-serving/. We are using the MLeap Serving container that is published in docker hub. The MLeap Serving is deployed as container in SQL Server Big Data Cluster as container app as web service that takes the Leap Frame as the input.  


## Sql Server Integration Services 
__[SSIS](SSIS/)__

This sample demonstrates SSIS application can be run as a containerized application and use the cron capability in Kubernets as a scheduler. This example takes Data Transformation Services Package File Format (DTSX) developed using Visual Studio that takes a database backup and copies it over to the SQL Server instance for restoring. This will run as a cron job pushing the backups every minute. Please follow the README.md for detailed instructions. 
