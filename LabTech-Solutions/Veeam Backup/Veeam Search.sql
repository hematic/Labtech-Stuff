/*
SQLyog Community v10.3 
MySQL - 5.5.31 
*********************************************************************
*/
/*!40101 SET NAMES utf8 */;

create table `sensorchecks` (
	`SensID` int (11),
	`Name` varchar (300),
	`SQL` text ,
	`QueryType` int (11),
	`ListDATA` text ,
	`FolderID` int (11)
); 
insert into `sensorchecks` (`SensID`, `Name`, `SQL`, `QueryType`, `ListDATA`, `FolderID`) values(NULL,'Backup - Veeam','Select DISTINCT Computers.ComputerID, Clients.Name as `Client Name`, Computers.Name as ComputerName, Computers.Domain, Computers.UserName, Software.`Name` as `Software_Name` from Computers, Clients, Software Where Computers.ClientID = Clients.ClientID and Software.ComputerID = Computers.ComputerID and ((Software.`Name` like \'Veeam Backup & Replication\'))','4','Related - Software Installed|Name (Software)|Like|Veeam Backup & Replication|=||=|^','2');
