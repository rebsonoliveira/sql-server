USE sales
GO

exec sp_configure 'allow polybase export', 1;
RECONFIGURE WITH OVERRIDE;
GO

-- Create file format for RCFILE with appropriate properties.
--
IF NOT EXISTS(SELECT * FROM sys.external_file_formats WHERE name = 'RCFILE')
    CREATE EXTERNAL FILE FORMAT rcfile
    WITH (
        FORMAT_TYPE = RCFILE,
        SERDE_METHOD = 'org.apache.hadoop.hive.serde2.columnar.ColumnarSerDe',
        DATA_COMPRESSION = 'org.apache.hadoop.io.compress.DefaultCodec'
    );


-- Create external table over HDFS data source using HADOOP type in
-- SQL Server 2019 big data cluster. The HADOOP data source is existing
-- PolyBase v1 syntax available by specifying location to HDFS namenode in
-- SQL Server big data cluster.
--
IF NOT EXISTS(SELECT * FROM sys.external_tables WHERE name = 'inventory_hdfs_rcfile')
    CREATE EXTERNAL TABLE [inventory_hdfs_rcfile]
    ("inv_date_sk" BIGINT, "inv_item_sk" BIGINT, "inv_warehouse_sk" BIGINT, "inv_quantity_on_hand" BIGINT)
    WITH
    (
        DATA_SOURCE = HadoopData,
        LOCATION = '/inventory_rcfile',
        FILE_FORMAT = rcfile
    );
GO

-- Export SQL Server table to HDFS
--
INSERT INTO inventory_hdfs_rcfile
SELECT "inv_date_sk", "inv_item_sk", "inv_warehouse_sk", "inv_quantity_on_hand"
  FROM inventory;
GO

-- Query the exported data using external table
--
SELECT COUNT(*) FROm inventory_hdfs_rcfile;
GO

-- Cleanup external tables
--
/*
DROP EXTERNAL TABLE inventory_hdfs_rcfile
*/
