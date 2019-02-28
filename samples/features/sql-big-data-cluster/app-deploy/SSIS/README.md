## How to use the SSIS runtime in SQL Server Big Data Cluster

This is a sample SSIS app, which is a cronjob backing up the `DWConfiguration` database on the Master SQL Instance on disk every minute. 

Refer to [installing mssqlctl](https://docs.microsoft.com/en-us/sql/big-data-cluster/deploy-install-mssqlctl?view=sqlallproducts-allversions) document on setting up the mssqlctl and connecting to a Aris cluster.

To see the `back-up-db.dtsx` under the `back-up-db.sln`, Install Visual Studio 2017 if you don't have it already. Download and install [SSDT](https://docs.microsoft.com/en-us/sql/ssdt/download-sql-server-data-tools-ssdt?view=sql-server-2017#ssdt-for-vs-2017-standalone-installer). 
When you open the `back-up-db.sln`, the decryption password can be found in the spec.yaml, i.e. the value after "/De ". 

Install [SSMS](https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms?view=sql-server-2017) if not already.

## How to run

Create the app:
```bash
# drop back-up-db.dtsx and spec.yaml in a folder, e.g. name back-up-db
# edit back-up-db.dtsx, replace the value after "Data Source" in the connection string to "service-master-pool;" if not alread. Then deploy it by:
mssqlctl app create --spec ./back-up-db
```

Check the job:
```bash
watch kubectl -n test get job
```

Once it has completed at least one backup, go to SMSS and restore to see the backup files:

`Right click on database DWConfiguration -> Tasks -> Restore -> Database... -> Select "Device" as Source -> Click on "..." -> Add`

Clean up:
```bash
# delete app
mssqlctl app delete --name back-up-db --version v1
# delete backup files
kubectl -n test exec -it mssql-master-pool-0 -c mssql-server -- /bin/bash -c "rm /var/opt/mssql/data/DWConfiguration_backup*.bak"
```
