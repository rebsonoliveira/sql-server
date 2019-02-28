## About
This is a sample SQL Server Integration Services (SSIS) app, which shows how to run a SSIS package as a scheduled service. This sample creates an app that is called each minute that executes an SSIS package. The SSIS package creates a backup of the `DWConfiguration` database on the master SQL instance to disk. Also, the package cleans any backup files for the `DWConfiguration` database that are older than one hour, making sure that maximum 60 backup files will be on disk at any moment.

Refer to [installing mssqlctl](https://docs.microsoft.com/en-us/sql/big-data-cluster/deploy-install-mssqlctl?view=sqlallproducts-allversions) document on setting up the mssqlctl and connecting to a Aris cluster.

Optional: to see the SSIS package itself, install Visual Studio 2017 if you don't have it already. After that download and install [SSDT](https://docs.microsoft.com/en-us/sql/ssdt/download-sql-server-data-tools-ssdt?view=sql-server-2017#ssdt-for-vs-2017-standalone-installer). 

Install [SSMS](https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-2017) if it is not already installed.

## What is in the `spec.yaml` file

Apart from regular settings, the `spec.yaml` file in this example specifies `options` and `schedule`:

|Setting|Description|
|-|-|
|options|Specifies any command line parameters passed to the execution of the SSIS package|
|schedule|Specifies when the job should run. This follows cron expressions. A value of '*/1 * * * *' means the job runs *every minute*.|

## How to run

### Change the `spec.yaml`
Replace `[SA_PASSWORD]` in the `spec.yaml` file with the password for SQL user `sa`.

### Create the app:
```bash
# drop back-up-db.dtsx and spec.yaml in a folder, e.g. name back-up-db
# edit back-up-db.dtsx, replace the value after "Data Source" in the connection string to "service-master-pool;" if not alread. Then deploy it by:
mssqlctl app create --spec ./back-up-db
```

### Check the job:
```bash
mssqlctl app list
```
Once the app is listed as `Ready` the job should run within a minute.
You can check if the backup is created by running:
```bash
kubectl -n test exec -it mssql-master-pool-0 -c mssql-server -- /bin/bash -c "ls /var/opt/mssql/data/*.DWConfigbak"
```
You should see a backup being created for every run of the job, with a maximum of 60 backups since the SSIS package cleans up backups older than one hour.
You can use any of the `.DWConfigbak` files to restore the database.

### Clean up:
```bash
# delete app
mssqlctl app delete --name back-up-db --version v1
# delete backup files
kubectl -n test exec -it mssql-master-pool-0 -c mssql-server -- /bin/bash -c "rm /var/opt/mssql/data/*.DWConfigbak"
```
