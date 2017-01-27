-- Before we start, we need to restore the DB for this tutorial.
-- Step1: Download the compressed backup file
-- Save the file on a location where SQL Server can access it. For example: C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup\
-- In a new query window in SSMS, execute the following restore statement, but REMEMBER TO CHANGE THE FILE PATHS
-- to match the directories of your installation!
USE master;
GO
RESTORE DATABASE Tpcx1b
   FROM DISK = 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\Backup\Tpcx1b.bak'
   WITH
                MOVE 'Tpcx1b' TO 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\Tpcx1b.mdf'
                ,MOVE 'Tpcx1b_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL13.MSSQLSERVER\MSSQL\DATA\Tpcx1b.ldf';
GO