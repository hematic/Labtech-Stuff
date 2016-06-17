/*
SQLyog Community v12.01 (64 bit)
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

/*Table structure for table `lt_certs` */

DROP TABLE IF EXISTS `lt_certs`;

CREATE TABLE `lt_certs` (
  `ComputerID` int(11) NOT NULL,
  `ComputerName` varchar(50) DEFAULT NULL,
  `ClientID` int(11) DEFAULT NULL,
  `ClientName` varchar(50) DEFAULT NULL,
  `Issuer` varchar(50) NOT NULL,
  `CertName` varchar(50) NOT NULL,
  `NotAfter` varchar(20) DEFAULT NULL,
  `ExpiresIn` int(5) DEFAULT NULL,
  PRIMARY KEY (`ComputerID`,`Issuer`,`CertName`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
