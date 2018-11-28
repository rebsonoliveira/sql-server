# SQL Server big data clusters

The new built-in notebooks in Azure Data Studio enables data scientists and data engineers to run Python, R, or Scala code against the cluster.

## Instructions

1. Download and save the notebook file [spark-sql.ipynb](spark-sql.ipynb/) locally.

1. Open the notebook file in Azure Data Studio (right click on the SQL Server big data cluster  server name-> **Manage**-> Open Notebook.

1. Wait for the “Kernel” and the target context (“Attach to”) to be populated. Set the “Kernel” to **PySpark3** and “Attach to” needs to be the IP address of your big data cluster endpoint.

1. Run each cell in the Notebook sequentially using Azure Data Studio.