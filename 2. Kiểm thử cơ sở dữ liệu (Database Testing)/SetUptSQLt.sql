CREATE DATABASE tSQLt_TestDB;
GO
USE tSQLt_TestDB;
GO
---Chạy PrepareServer.sql
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'clr enabled', 1;
RECONFIGURE;
GO
--Chạy tSQLt.class.sql
SELECT * FROM tSQLt.Info();