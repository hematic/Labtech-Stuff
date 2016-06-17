/*
SQLyog Community v9.10 
MySQL - 5.5.30 
*********************************************************************
*/
/*!40101 SET NAMES utf8 */;

create table `exchangedatabases` (
	`Entry` int (128),
	`AgentID` int (128),
	`ClientName` varchar (384),
	`ClientID` int (128),
	`DatabaseName` varchar (384),
	`ServerName` varchar (384),
	`TotalWhiteSPace` int (128),
	`TotalDatabaseSize` int (128)
); 
