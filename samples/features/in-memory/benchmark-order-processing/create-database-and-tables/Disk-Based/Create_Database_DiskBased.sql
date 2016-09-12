USE master
GO

--  create main database files; for large-scale workloads, add additional containers to the DiskBased_fg filegroup
CREATE DATABASE DiskBasedDB
ON PRIMARY
(   NAME        = DiskBasedDB_root,
    FILENAME    = 'D:\Data\DiskBasedDB_root.mdf',
    SIZE        = 8MB,
    FILEGROWTH  = 10),
FILEGROUP   DiskBased_fg
(   NAME        = DiskBasedDB_1,
    FILENAME    = 'D:\Data\DiskBasedDB_1'),
(   NAME        = DiskBasedDB_2,
    FILENAME    = 'D:\Data\DiskBasedDB_2')
LOG ON
(   NAME        = DiskBasedDB_log,
    FILENAME    = 'E:\Log\DiskBasedDB_LogDiskBasedDB_log.ldf',
    SIZE        = 1000MB,
    FILEGROWTH  = 10)
COLLATE Latin1_General_BIN2
GO

USE DiskBasedDB
GO

ALTER AUTHORIZATION ON DATABASE::DiskBasedDB TO sa
GO
