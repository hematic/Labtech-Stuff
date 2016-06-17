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

/*Table structure for table `probecollectiontemplates` */

DROP TABLE IF EXISTS `probecollectiontemplates`;

CREATE TABLE `probecollectiontemplates` (
  `Id` int(11) NOT NULL AUTO_INCREMENT,
  `GUID` char(36) DEFAULT NULL,
  `DeviceGuid` char(36) DEFAULT NULL,
  `TemplateName` varchar(255) DEFAULT NULL,
  `LevelStop` int(11) DEFAULT NULL,
  `IsSubLevel` int(11) DEFAULT NULL,
  `CustomTable` varchar(255) DEFAULT NULL,
  `Indexes` varchar(255) DEFAULT NULL,
  `RetrievalMethod` int(11) DEFAULT NULL,
  `Targets` int(11) DEFAULT NULL,
  PRIMARY KEY (`Id`)
) ENGINE=InnoDB AUTO_INCREMENT=17 DEFAULT CHARSET=utf8;

/*Data for the table `probecollectiontemplates` */

insert  into `probecollectiontemplates`(`Id`,`GUID`,`DeviceGuid`,`TemplateName`,`LevelStop`,`IsSubLevel`,`CustomTable`,`Indexes`,`RetrievalMethod`,`Targets`) values (1,'ed9391ec-95a5-11df-90db-91f30e6bf070','25cab265-9338-11df-ab47-fd808a336046','SNMP Device Standard Collections',0,0,'','',1,3),(2,'a5c9852b-98ba-11df-b8b3-32dec130a9be','33d62276-9338-11df-ab47-fd808a336046','SNMP Printers Default Collection Template',0,0,'','',1,1),(3,'86a7b510-09f5-11e0-b6dd-19b74a4fab6d','1c1e777b-e380-11df-9168-8febede3a698','Brother Printer Supplies',0,0,'','',1,1),(4,'4e805987-1cd3-11e4-bd49-00505687662d','e69f15c8-1cd0-11e4-bd49-00505687662d','APC Management Card',0,0,'','',1,1),(6,'468167d8-1cd6-11e4-bd49-00505687662d','','APC Power Distribution Unit',0,0,'','',1,3),(7,'1dfdf683-1cd8-11e4-bd49-00505687662d','173bcd2b-e8f0-11df-9525-9da8713ddfa8','Cisco Switch Collection Template',0,0,'','',1,3),(8,'6a1a066d-1d68-11e4-bd49-00505687662d','','Dell PowerConnect Switch Collection',0,0,'','',1,3),(9,'cc162ecb-1d69-11e4-bd49-00505687662d','','Dell DRAC',0,0,'','',1,3),(10,'501b60ce-1d91-11e4-bd49-00505687662d','','Dell Servers',0,0,'','',1,3),(11,'3a38f7f1-1d9f-11e4-bd49-00505687662d','','Eaton ConnectUPS-MS and Network Management Cards Collection',0,0,'','',1,3),(12,'32648aab-1da0-11e4-bd49-00505687662d','','HP ProCurve Switch',0,0,'','',1,3),(13,'88819d67-1da3-11e4-bd49-00505687662d','','Ricoh Printer/Copier',0,0,'','',1,3),(14,'3b4a0aa8-1f02-11e4-bd49-00505687662d','','Sensor Gateway Environmental',0,0,'','',1,3),(15,'8edcc132-1f03-11e4-bd49-00505687662d','','SonicWall Security Appliances',0,0,'','',1,3),(16,'88913f65-1f04-11e4-bd49-00505687662d','','SonicWall SSL VPN',0,0,'','',1,3);

/*!40101 SET SQL_MODE=@OLD_SQL_MODE */;
/*!40014 SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS */;
/*!40014 SET UNIQUE_CHECKS=@OLD_UNIQUE_CHECKS */;
/*!40111 SET SQL_NOTES=@OLD_SQL_NOTES */;
