USE [master]
GO
DROP DATABASE [insert_is_faster_in_2016]
GO
CREATE DATABASE [insert_is_faster_in_2016]
 ON  PRIMARY 
( NAME = N'insert_is_faster_in_2016', FILENAME = N'C:\temp\insert_is_faster_in_2016.mdf' , SIZE = 45Gb , MAXSIZE = UNLIMITED, FILEGROWTH = 65536KB )
 LOG ON 
( NAME = N'insert_is_faster_in_2016_log', FILENAME = N'C:\temp\insert_is_faster_in_2016_log.ldf' , SIZE = 30Gb , MAXSIZE = UNLIMITED , FILEGROWTH = 65536KB )
GO
alter database insert_is_faster_in_2016 set recovery simple
go