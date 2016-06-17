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

/*Table structure for table `dellwarranties` */

DROP TABLE IF EXISTS `dellwarranties`;

CREATE TABLE `dellwarranties` (
  `Row` int(8) NOT NULL AUTO_INCREMENT,
  `ComputerID` int(8) NOT NULL,
  `ComputerName` varchar(64) NOT NULL,
  `ServiceLevelDescription` varchar(64) NOT NULL,
  `EntitlementType` varchar(64) NOT NULL,
  `WarrantyStart` date NOT NULL,
  `WarrantyEnd` date NOT NULL,
  PRIMARY KEY (`Row`)
) ENGINE=InnoDB AUTO_INCREMENT=6 DEFAULT CHARSET=utf8;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
