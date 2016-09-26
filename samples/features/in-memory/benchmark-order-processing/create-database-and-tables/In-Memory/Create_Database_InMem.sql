USE master
GO

--  create main database files; for large-scale workloads, add additional containers in the InMem_fg filegroup
CREATE DATABASE InMemDB
ON PRIMARY
(   NAME        = InMemDB_root,
    FILENAME    = 'D:\Data\InMem_root.mdf',
    SIZE        = 8MB,
    FILEGROWTH  = 10),
FILEGROUP   InMem_fg   CONTAINS MEMORY_OPTIMIZED_DATA
(   NAME        = InMemDB_1,
    FILENAME    = 'D:\Data\InMem_1')
LOG ON
(   NAME        = InMemDB_log,
    FILENAME    = 'E:\Log\InMem_log.ldf',
    SIZE        = 1000MB,
    FILEGROWTH  = 10)
COLLATE Latin1_General_BIN2
GO

USE InMemDB
GO

/** For memory-optimized tables, automatically map all lower isolation levels (including READ COMMITTED) to SNAPSHOT **/
ALTER DATABASE CURRENT SET MEMORY_OPTIMIZED_ELEVATE_TO_SNAPSHOT = ON
GO

ALTER AUTHORIZATION ON DATABASE::InMemDB TO sa
GO
