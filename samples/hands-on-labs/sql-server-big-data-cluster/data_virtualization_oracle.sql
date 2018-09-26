USE Sales
GO

--Create database scoped credential to connect to Oracle server
--
CREATE DATABASE SCOPED CREDENTIAL [<yourCredentialNameHere>] WITH IDENTITY = 'SYSTEM', SECRET = 'Admin123';
GO

--Create external data source that points to Oracle server
--
CREATE EXTERNAL DATA SOURCE [<yourDataSourceNameHere>]
WITH (LOCATION = 'oracle://APS40-10.oltp.sql.cass.hp.com',CREDENTIAL = [demo_credential]);

--Create external table over inventory table on Oracle server
--
CREATE EXTERNAL TABLE [<yourTableNameHere>]
    ([inv_date] DECIMAL(10,0) NOT NULL,[inv_item] DECIMAL(10,0) NOT NULL,
    [inv_warehouse] DECIMAL(10,0) NOT NULL, [inv_quantity_on_hand] DECIMAL(10,0))
WITH (DATA_SOURCE=[<yourDataSourceNameHere>], LOCATION='xe.HR.INVENTORY');

DROP EXTERNAL TABLE ORACLE_INVENTORY
DROP EXTERNAL DATA SOURCE ORACLE_INVENTORY

-- Query external table with local tables
-- Execution time: ~54 secs
SELECT TOP(100) w.w_warehouse_name, i.inv_item, SUM(i.inv_quantity_on_hand) as total_quantity
  FROM [<yourTableNameHere>]] as i
  JOIN item as it
    ON it.i_item_sk = i.inv_item
  JOIN warehouse as w
    ON w.w_warehouse_sk = i.inv_warehouse
 WHERE it.i_category = 'Books'
 GROUP BY w.w_warehouse_name, i.inv_item;
GO

--Cleanup
--
DROP EXTERNAL TABLE [<yourTableName>];
DROP EXTERNAL DATA SOURCE [<yourDataSourceNameHere>] ;
DROP DATABASE SCOPED CREDENTIAL [<yourCredentialNameHere>];
GO
