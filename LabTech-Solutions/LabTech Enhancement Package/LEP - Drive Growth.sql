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

/*Table structure for table `drivegrowth` */

DROP TABLE IF EXISTS `drivegrowth`;

CREATE TABLE `drivegrowth` (
  `Entry` int(11) NOT NULL AUTO_INCREMENT,
  `Computerid` int(11) NOT NULL,
  `ComputerName` varchar(40) DEFAULT NULL,
  `Driveid` int(11) NOT NULL,
  `ClientID` int(11) NOT NULL,
  `DriveLetter` varchar(2) NOT NULL,
  `DriveSize` int(20) NOT NULL,
  `FreeSpace` int(20) NOT NULL,
  `EntryDate` int(6) NOT NULL,
  `EntryAge` int(2) NOT NULL DEFAULT '0',
  PRIMARY KEY (`Entry`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
