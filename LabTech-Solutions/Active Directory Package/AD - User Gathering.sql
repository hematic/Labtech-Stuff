/*
SQLyog Community v10.3 
MySQL - 5.5.31 : Database - labtech
*********************************************************************
*/

/*!40101 SET NAMES utf8 */;

/*!40101 SET SQL_MODE=''*/;

/*!40014 SET @OLD_UNIQUE_CHECKS=@@UNIQUE_CHECKS, UNIQUE_CHECKS=0 */;
/*!40014 SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0 */;
/*!40101 SET @OLD_SQL_MODE=@@SQL_MODE, SQL_MODE='NO_AUTO_VALUE_ON_ZERO' */;
/*!40111 SET @OLD_SQL_NOTES=@@SQL_NOTES, SQL_NOTES=0 */;
CREATE DATABASE /*!32312 IF NOT EXISTS*/`labtech` /*!40100 DEFAULT CHARACTER SET utf8 */;

USE `labtech`;

/*Table structure for table `ad_users` */

DROP TABLE IF EXISTS `ad_users`;

CREATE TABLE `ad_users` (
  `Entry` int(11) NOT NULL AUTO_INCREMENT,
  `ComputerID` varchar(11) NOT NULL,
  `Domain` varchar(128) NOT NULL,
  `AccountExpirationDate` varchar(50) DEFAULT NULL,
  `AccountExpires` varchar(50) DEFAULT NULL,
  `CannotChangePassword` varchar(11) DEFAULT NULL,
  `Created` varchar(50) DEFAULT NULL,
  `Deleted` varchar(50) DEFAULT NULL,
  `Department` varchar(50) DEFAULT NULL,
  `Description` varchar(128) DEFAULT NULL,
  `DisplayName` varchar(50) DEFAULT NULL,
  `DistinguishedName` varchar(255) DEFAULT NULL,
  `EmailAddress` varchar(128) DEFAULT NULL,
  `Enabled` varchar(11) DEFAULT NULL,
  `GivenName` varchar(50) DEFAULT NULL,
  `HomeDirectory` varchar(128) DEFAULT NULL,
  `HomePhone` varchar(20) DEFAULT NULL,
  `LastLogonDate` varchar(50) DEFAULT NULL,
  `LockedOut` varchar(11) DEFAULT NULL,
  `MemberOf` varchar(512) DEFAULT NULL,
  `MobilePhone` varchar(20) DEFAULT NULL,
  `Name` varchar(128) DEFAULT NULL,
  `OfficePhone` varchar(20) DEFAULT NULL,
  `Organization` varchar(255) DEFAULT NULL,
  `PasswordExpired` varchar(11) DEFAULT NULL,
  `PasswordLastSet` varchar(50) DEFAULT NULL,
  `PasswordNeverExpires` varchar(11) DEFAULT NULL,
  `ProfilePath` varchar(255) DEFAULT NULL,
  `SAMAccountName` varchar(255) DEFAULT NULL,
  `SamAccountType` varchar(50) DEFAULT NULL,
  `SID` varchar(255) NOT NULL,
  `SurName` varchar(128) DEFAULT NULL,
  `Title` varchar(128) DEFAULT NULL,
  `TrustedForDelegation` varchar(11) DEFAULT NULL,
  `WhenChanged` varchar(50) DEFAULT NULL,
  `WhenCreated` varchar(50) DEFAULT NULL,
  PRIMARY KEY (`SID`),
  KEY `Entry` (`Entry`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
