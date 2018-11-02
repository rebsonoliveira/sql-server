# Data virtualization in SQL Server 2019

**Applies to: SQL Server 2019 on Windows or Linux, SQL Server 2019 big data cluster**

SQL Server 2019 introduces new ODBC connectors to data sources like SQL Server, Oracle, MongoDB and Teradata. These connectors can be used from stand-alone SQL Server 2019 on Windows or Linux and SQL Server 2019 big data cluster.

## Query data in Oracle from SQL Server master

In this example, you are going to create an external table in SQL Server Master instance over the inventory table that sits on an Oracle server.

**Before you begin**, you need to have an Oracle instance and credentials. Follow the instruction in the [setup\README.md](setup\README.md).

### Instructions

1. Connect to SQL Server Master instance.

1. Execute the SQL [inventory-oracle.sql](inventory-oracle.sql/).
