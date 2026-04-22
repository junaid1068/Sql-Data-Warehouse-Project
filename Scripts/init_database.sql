/*
Script Purpose:
Create a database named Datawarehouse and three schemas named bronze, silver, and gold.

Warning : 
Running this script will drop and recreate the entire 'Datawarehouse' database if it exists.

*/
Use Master;
go
if exists (Select 1 from sys.databases where name = 'Datawarehouse')
Begin
	Alter Database Datawarehouse Set Single_User With Rollback Immediate;
	Drop Database Datawarehouse;
End;
go

--Create Database and Schemas
-- Schemas : Schema is a logical container for database objects such as tables, views, and stored procedures.
--It helps to organize and manage database objects based on their purpose or function.
-- It works like a folder structure within the database, allowing you to group related objects together.
Create Database Datawarehouse ;
go

use Datawarehouse;
go

Create Schema Bronze;
go

Create Schema silver;	
go

Create Schema gold;
go
