USE master
GO

--  create main database files
CREATE DATABASE InMemDB
ON PRIMARY
(   NAME        = InMemDB_root,
    FILENAME    = 'F:\InMemDB_Data\InMem_root.mdf',
    SIZE        = 2048MB,
    FILEGROWTH  = 10),
FILEGROUP   InMem_fg   CONTAINS MEMORY_OPTIMIZED_DATA
(   NAME        = InMemDB_1,
    FILENAME    = 'G:\InMemDB_Data_1\InMem_1'),
(   NAME        = InMemDB_2,
    FILENAME    = 'G:\InMemDB_Data_2\InMem_2'),
(   NAME        = InMemDB_3,
    FILENAME    = 'G:\InMemDB_Data_3\InMem_3'),
(   NAME        = InMemDB_4,
    FILENAME    = 'G:\InMemDB_Data_4\InMem_4'),
(   NAME        = InMemDB_5,
    FILENAME    = 'H:\InMemDB_Data_5\InMem_5'),
(   NAME        = InMemDB_6,
    FILENAME    = 'H:\InMemDB_Data_6\InMem_6'),
(   NAME        = InMemDB_7,
    FILENAME    = 'H:\InMemDB_Data_7\InMem_7'),
(   NAME        = InMemDB_8,
    FILENAME    = 'H:\InMemDB_Data_8\InMem_8'),
(   NAME        = InMemDB_9,
    FILENAME    = 'I:\InMemDB_Data_9\InMem_9'),
(   NAME        = InMemDB_10,
    FILENAME    = 'I:\InMemDB_Data_10\InMem_10'),
(   NAME        = InMemDB_11,
    FILENAME    = 'I:\InMemDB_Data_11\InMem_11'),
(   NAME        = InMemDB_12,
    FILENAME    = 'I:\InMemDB_Data_12\InMem_12'),
(   NAME        = InMemDB_13,
    FILENAME    = 'J:\InMemDB_Data_13\InMem_13'),
(   NAME        = InMemDB_14,
    FILENAME    = 'J:\InMemDB_Data_14\InMem_14'),
(   NAME        = InMemDB_15,
    FILENAME    = 'J:\InMemDB_Data_15\InMem_15'),
(   NAME        = InMemDB_16,
    FILENAME    = 'J:\InMemDB_Data_16\InMem_16')
LOG ON
(   NAME        = InMemDB_log_1,
    FILENAME    = 'K:\InMemDB_Log_1\InMem_log_1.ldf',
    SIZE        = 1968GB,
    FILEGROWTH  = 10),
(   NAME        = InMemDB_log_2,
    FILENAME    = 'K:\InMemDB_Log_2\InMem_log_2.ldf',
    SIZE        = 1968GB,
    FILEGROWTH  = 10),
(   NAME        = InMemDB_log_3,
    FILENAME    = 'K:\InMemDB_Log_3\InMem_log_3.ldf',
    SIZE        = 1968GB,
    FILEGROWTH  = 10)
COLLATE Latin1_General_BIN
GO

USE InMemDB
GO

/** For memory-optimized tables, automatically map all lower isolation levels (including READ COMMITTED) to SNAPSHOT **/
ALTER DATABASE CURRENT SET MEMORY_OPTIMIZED_ELEVATE_TO_SNAPSHOT = ON
GO

ALTER AUTHORIZATION ON DATABASE::InMemDB TO sa
GO
