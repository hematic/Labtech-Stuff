
INSERT INTO `Agents` (`Name`,`LocID`,`ClientID`,`ComputerID`,`DriveID`,`CheckAction`,`AlertAction`,`AlertMessage`,`ContactID`,`interval`,`Where`,`What`,`DataOut`,`Comparor`,`DataIn`,`LastScan`,`LastFailed`,`FailCount`,`IDField`,`AlertStyle`,`Changed`,`Last_Date`,`Last_User`,`ReportCategory`,`TicketCategory`,`Flags`) Values('Veeam VM Backup Job Started','0','0','1126','0','6','4','%NAME% %STATUS% on %CLIENTNAME%\\%COMPUTERNAME% at %LOCATIONNAME% for %FIELDNAME% result %RESULT%.!!!%NAME% %STATUS% on %CLIENTNAME%\\%COMPUTERNAME% at %LOCATIONNAME% for %FIELDNAME% result %RESULT%.','0','300','127.0.0.1','6','*!!!0!!!Veeam Backup!!!1!!!*','1','1','2014/01/30 14:09:39','2014/01/30 03:30:57','0','','1','0','2014/01/30 14:09:39','asp_LabTech@localhost','9','0','0');
