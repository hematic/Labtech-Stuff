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

/*Table structure for table `hpf_cashregister` */

DROP TABLE IF EXISTS `hpf_cashregister`;

CREATE TABLE `hpf_cashregister` (
  `PosiFlexDataID` int(11) NOT NULL,
  `CR_Number` tinyint(1) NOT NULL DEFAULT '0',
  `CR_Config1` int(1) DEFAULT NULL,
  `CR_DrawerFailedOpenCount` int(4) unsigned zerofill DEFAULT NULL,
  `CR_ModelName` varchar(255) DEFAULT NULL,
  `CR_PID` binary(5) DEFAULT NULL,
  `CR_Status` varchar(10) DEFAULT NULL,
  `CR_RecordNumber` int(11) NOT NULL,
  `CR_ManufactureDate` datetime NOT NULL,
  `EntryDate` datetime NOT NULL,
  PRIMARY KEY (`PosiFlexDataID`,`CR_Number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*Table structure for table `hpf_epsonprinter` */

DROP TABLE IF EXISTS `hpf_epsonprinter`;

CREATE TABLE `hpf_epsonprinter` (
  `PosiFlexDataID` int(11) NOT NULL,
  `EpsonPP` varchar(10) DEFAULT NULL,
  `EPP_RecordNumber` int(11) NOT NULL,
  `EntryDate` datetime NOT NULL,
  PRIMARY KEY (`PosiFlexDataID`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*Table structure for table `hpf_poledisplay` */

DROP TABLE IF EXISTS `hpf_poledisplay`;

CREATE TABLE `hpf_poledisplay` (
  `PosiFlexDataID` int(11) NOT NULL,
  `PD_Number` tinyint(1) NOT NULL DEFAULT '0',
  `PD_CommunicationErrorCount` int(5) DEFAULT NULL,
  `PD_ModelName` varchar(10) DEFAULT NULL,
  `PD_SerialNumber` varchar(10) DEFAULT NULL,
  `PD_RecordNumber` int(11) NOT NULL,
  `EntryDate` datetime NOT NULL,
  PRIMARY KEY (`PosiFlexDataID`,`PD_Number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*Table structure for table `hpf_posiflex` */

DROP TABLE IF EXISTS `hpf_posiflex`;

CREATE TABLE `hpf_posiflex` (
  `PosiFlexDataID` int(11) NOT NULL AUTO_INCREMENT,
  `ComputerID` int(11) NOT NULL,
  `ClientID` int(11) NOT NULL,
  `LocationID` int(11) NOT NULL,
  `RecordNumber` int(11) NOT NULL,
  `EntryDate` datetime NOT NULL,
  PRIMARY KEY (`PosiFlexDataID`)
) ENGINE=InnoDB AUTO_INCREMENT=3 DEFAULT CHARSET=utf8;

/*Table structure for table `hpf_receiptprinter` */

DROP TABLE IF EXISTS `hpf_receiptprinter`;

CREATE TABLE `hpf_receiptprinter` (
  `PosiFlexDataID` int(11) NOT NULL,
  `PP_Number` tinyint(1) NOT NULL DEFAULT '0',
  `PP_PrinterAge` int(4) DEFAULT NULL,
  `PP_CharacterPrintedCount` int(11) DEFAULT NULL,
  `PP_FailedPaperCutCount` int(4) DEFAULT NULL,
  `PP_MechanicalRevision` varchar(16) DEFAULT NULL,
  `PP_ModelName` varchar(10) DEFAULT NULL,
  `PP_POSConfig` int(1) DEFAULT NULL,
  `PP_PrinterInstallDate` varchar(30) DEFAULT NULL,
  `PP_RecordNumber` int(11) NOT NULL,
  `EntryDate` datetime NOT NULL,
  PRIMARY KEY (`PosiFlexDataID`,`PP_Number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*Table structure for table `hpf_stripereader` */

DROP TABLE IF EXISTS `hpf_stripereader`;

CREATE TABLE `hpf_stripereader` (
  `PosiFlexDataID` int(11) NOT NULL,
  `MSR_Number` tinyint(1) NOT NULL DEFAULT '0',
  `MSR_HoursPoweredCount` int(5) DEFAULT NULL,
  `MSR_FailedRead` int(5) DEFAULT NULL,
  `MSR_ModelName` varchar(10) DEFAULT NULL,
  `MSR_UnreadableCard` int(5) DEFAULT NULL,
  `MSR_RecordNumber` int(11) NOT NULL,
  `EntryDate` datetime NOT NULL,
  PRIMARY KEY (`PosiFlexDataID`,`MSR_Number`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
