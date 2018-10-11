# Query data in Oracle from SQL Server master

Create external table over an Oracle database
by leveraging SQL Server Polybase technology. SQL Server Big Data clusters can query external data sources without importing the data in SQL Server. SQL Server 2019 introduces new connectors to data sources like Oracle, MongoDB and Teradata. In this example, you are going to create an external table in SQL Server Master instance over the inventory table that sits on an Oracle server.

**Before you begin**, you need to have an Oracle instance and credentials. Execute the SQL script [inventory-ora.sql](inventory-ora.sql/) in Oracle to create the table and import the "inventory.csv" file created by the bootstrap sample database.

## Instructions

1. Connect to SQL Server Master instance.

1. Execute the SQL [external-table-oracle.sql](external-table-oracle.sql/).
