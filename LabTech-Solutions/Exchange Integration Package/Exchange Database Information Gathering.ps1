#####################################################################################
#Script Created by Phillip Marshall													#
#Creation Date 6/5/14																#
#Revision 2																			#
#Revisions Changes - Added Commenting and cleaned up formatting.					#
#																					#
#Description - This script will pull exchange mailbox database information			#
#information from a Exchange 2010 box and return it into a format that can be		#
#that can be inserted into a custom table in the LabTech monitoring Database.		#
#####################################################################################

Function ExchangeDatabaseInfo
{
        #Creates the two sections of the MySQL insert statement for the LabTech Database.
        $DatabaseInsert = "REPLACE INTO ExchangeDatabases (AgentID,ClientName,ClientID,Databasename,Servername,TotalWhitespace,TotalDatabaseSize)"
        $DatabaseValues = ""
             
    Try
    {
        #Adds 2007 Exchange Snapin
        Add-PSSnapin Microsoft.Exchange.Management.PowerShell.Admin
    }
    Catch
    {}

     Try
    {
        #Adds 2010 Exchange Snapin
        Add-PSSnapin Microsoft.Exchange.Management.PowerShell.E2010
    }
    Catch
    {}

        #Gets the information for all Mailboxes Stores.
        Get-mailboxdatabase -status | % { 
	        $Databasename = $_.Name
	        $Space = ((Get-MailboxDatabase -Identity $Databasename -Status).availablenewmailboxspace).ToGB()
	        $Size = ((Get-MailboxDatabase -Identity $Databasename -Status).DatabaseSize).ToGB()
	            If($DatabaseValues -eq "")
                {
		            $DatabaseValues = " VALUES('%computerid%','%clientname%','%clientid%',`'$Databasename`','%computername%',`'$Space`',`'$Size`')"
                }
	            Else
                {
		            $DatabaseValues = $DatabaseValues + ",('%computerid%','%clientname%','%clientid%',`'$Databasename`','%computername%',`'$Space`',`'$Size`')"
                }
}
        #Outputs the insert statements to a file to be pulled in VIA a LabTech Script.  
        IF ($DatabaseValues -eq "") 
        {
            $Output = "No Values were retrieved"
            out-file -filepath C:\Windows\temp\databasestats.txt -inputobject $Output
        }
        Else 
        {
            $Output = $DatabaseInsert + $DatabaseValues
            out-file -filepath C:\Windows\temp\databasestats.txt -inputobject $Output
        }
}

ExchangeDatabaseInfo