<#########################################################################################>

<#Function Declarations#>


Function CheckRegKeyExists ($Dir, $KeyName)
{
	
	try
	{
		$CheckIfExists = Get-ItemProperty $Dir $KeyName -ErrorAction SilentlyContinue
		if ((!$CheckIfExists) -or ($CheckIfExists.Length -eq 0))
		{
			return $false
		}
		else
		{
			return $true
		}
	}
	catch
	{
		return $false
	}
	
}

Function Write-Log
{
	<#
	.SYNOPSIS
		A function to write ouput messages to a logfile.
	
	.DESCRIPTION
		This function is designed to send timestamped messages to a logfile of your choosing.
		Use it to replace something like write-host for a more long term log.
	
	.PARAMETER StrMessage
		The message being written to the log file.
	
	.EXAMPLE
		PS C:\> Write-Log -StrMessage 'This is the message being written out to the log.' 
	
	.NOTES
		N/A
#>
	
	Param
	(
		[Parameter(Mandatory = $True, Position = 0)]
		[String]$Message
	)

    
	add-content -path $LogFilePath -value ($Message)
    Write-Output $Message
}

Function Parse-Failure
{
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $False, ValueFromPipeline = $True)]
		[string]$FailureMessage)
	
	If ($FailureMessage -match 'Timeout expired.')
	{
		$ParsedMessage = 'The timeout period elapsed or the server is not responding.'
		Return $ParsedMessage
	}
	
	ELSEIF ($FailureMessage -match 'deadlock victim')
	{
		$ParsedMessage = 'The Transaction was deadlocked with another process.'
		Return $ParsedMessage
	}
	
	ELSEIF ($FailureMessage -match 'Username or password is incorrect')
	{
		$ParsedMessage = 'Username or password is incorrect.'
		Return $ParsedMessage
	}
	
	ELSEIF ($FailureMessage -match 'Server was unable to process request.')
	{
		$ParsedMessage = 'Unable to process request. Record Not Found.'
		Return $ParsedMessage
	}
	
	ELSEIF ($FailureMessage -match 'There is not enough space on the disk.')
	{
		$ParsedMessage = 'Server was unable to process request. Low Disk space.'
		Return $ParsedMessage
	}
	
	ELSEIF ($FailureMessage -match 'Object reference not set to an instance of an object.')
	{
		$ParsedMessage = 'Object reference not set to an instance of an object.'
		Return $ParsedMessage
	}
	
	ELSEIF ($FailureMessage -match 'HTTP Error 503. The service is unavailable.')
	{
		$ParsedMessage = 'HTTP Error 503. The service is unavailable.'
		Return $ParsedMessage
	}
	
	ELSEIF ($FailureMessage -match "'System.OutOfMemoryException' was thrown.")
	{
		$ParsedMessage = 'Server threw an Out of Memory Exception'
		Return $ParsedMessage
	}
	
	ELSEIF ($FailureMessage -match "This company is in a status that does not allow updating Service Tickets.")
	{
		$ParsedMessage = 'Company status does not allow updating Service Tickets.'
		Return $ParsedMessage
	}
	
	ELSEIF ($FailureMessage -match "This company is in a status that does not allow creating Service Tickets.")
	{
		$ParsedMessage = 'Company status does not allow creating Service Tickets.'
		Return $ParsedMessage
	}
	
	ELSEIF ($FailureMessage -match "Index was outside the bounds of the array.")
	{
		$ParsedMessage = 'Index was outside the bounds of the array.'
		Return $ParsedMessage
	}
	
	ELSEIF ($FailureMessage -match "The process cannot access the file")
	{
		$Regex = [regex]::matches($Item.lastfailuremessage, "(?:access the file ')(.+?)(?:')")
		If ($Regex -ne $null) { $ParsedMessage = "The process cannot access the file: $(($Regex.groups[1].value))" }
		Else { $ParsedMessage = "The process cannot access the file." }
		Return $ParsedMessage
	}
	
	ELSEIF ($FailureMessage -match "The server was not found or was not accessible.")
	{
		$Regex = [regex]::matches($Item.lastfailuremessage, "(?:, error:)(.+?)(?:\))")
		If ($Regex -ne $null) { $ParsedMessage = "The server was not found or was not accessible. Error: $(($Regex.groups[1].value))" }
		Else { $ParsedMessage = "The server was not found or was not accessible." }
		Return $ParsedMessage
	}
	
	ELSEIF ($FailureMessage -match 'System.ApplicationException: Cannot find board')
	{
		$Regex = [regex]::matches($Item.lastfailuremessage, "(?:board\s)(.+?)(?:\s+at\sConn)")
		If ($Regex -ne $null) { $ParsedMessage = "Cannot find board $(($Regex.groups[1].value))" }
		Else { $ParsedMessage = "Cannot find board." }
		Return $ParsedMessage
	}
	
	ELSEIF ($FailureMessage -match 'Cannot find company')
	{
		$Regex = [regex]::matches($Item.lastfailuremessage, "(?:company:\s)(.+?)(?:\s+at\sConn)")
		If ($Regex -ne $null) { $ParsedMessage = "Cannot find company $(($Regex.groups[1].value))" }
		Else { $ParsedMessage = "Cannot find company." }
		Return $ParsedMessage
	}
	
	Else
	{
		$ParsedMessage = $FailureMessage
		Return $ParsedMessage
	}
}

<#########################################################################################>

<#Pre-Requisite Server Checks#>

$ErrorActionPreference = 'SilentlyContinue'

[String]$LogFilePath = "$($env:windir)/temp/TicketSyncResults.txt"

If (Test-Path "$LogFilePath") 
{ 
    Remove-Item "$LogFilePath" -Force
}

$ExistCheckSQLDir = CheckRegKeyExists HKLM:\Software\Wow6432Node\Labtech\Setup MySQLDir;
$ExistCheckRootPwd = CheckRegKeyExists HKLM:\Software\Wow6432Node\Labtech\Setup RootPassword;

if ($ExistCheckSQLDir -eq $true) { $SQLDir = (Get-ItemProperty HKLM:\Software\Wow6432Node\Labtech\Setup -name MySQLDir).MySQLDir; }

else
{
	Write-Log "Critical Error: Unable to Locate SQL Directory Registry key ( HKLM:\Software\Wow6432Node\LabTech\Setup.MySQLDir )"
	exit;
}

if ($ExistCheckRootPwd -eq $true) { $RootPwd = (Get-ItemProperty HKLM:\Software\Wow6432Node\Labtech\Setup -name RootPassword).RootPassword; }

elseif ($LabTechDir -eq $false)
{
	Write-Log "Critical Error: Unable to Locate Root Password Registry key ( HKLM:\Software\Wow6432Node\LabTech\Setup.RootPassword )"
	exit;
}

<#########################################################################################>
<#Check 1.0 - Verify that necessary tables exist.#>
set-location $SQLDir\bin;

$PreReqs = .\mysql.exe --user=root --password=$RootPwd -e "

SELECT COUNT(*)
FROM information_schema.tables 
WHERE table_schema = 'labtech' 
AND table_name = 'plugin_cw_ticket_failures';" --batch -N

If ($PreReqs -ne '1') { Write-Log "The ConnectWise Plugin is Not Installed!!"; exit; }

<#########################################################################################>

<#Check 2.0 - Get list of unsynced tickets and the reasons.#>

set-location $SQLDir\bin;

$MissingTickets = .\mysql.exe --user=root --password=$RootPwd -e "
USE Labtech;
SELECT clients.name, plugin_cw_ticket_failures.ticketid, REPLACE(REPLACE(plugin_cw_ticket_failures.lastfailuremessage, '\r', ''), '\n', ''), tickets.starteddate 
FROM plugin_cw_ticket_failures
LEFT JOIN (tickets,clients)
ON (tickets.ticketid=plugin_cw_ticket_failures.ticketid AND clients.clientid = tickets.clientid)
WHERE plugin_cw_ticket_failures.lastattempt > DATE_ADD(NOW(),INTERVAL -30 DAY)" --batch -N

<#########################################################################################>

<#Build the custom object with the ticket data.#>
If ($MissingTickets -ne $null)
{
	Foreach ($Ticket in $MissingTickets)
	{
		$TicketsTemp = $Ticket -split '\t+'
		$objMissingTickets +=
		@([pscustomobject]@{ ClientName = $TicketsTemp[0]; TicketID = $TicketsTemp[1]; LastFailureMessage = $TicketsTemp[2]; StartedDate = $TicketsTemp[3]; })
	}
}

Else { Write-Log "No unsynced tickets were gathered."; exit; }

<#########################################################################################>

<#Parse each failure for the reason and clean up the output.#>

ForEach ($Item in $objmissingtickets)
{
	$ParsedMessage = Parse-Failure -FailureMessage $Item.LastFailureMessage
	$Item.LastFailureMessage = $ParsedMessage
}

<#########################################################################################>

<#Clean up and output.#>

$objMissingTickets | Where-Object {$_.ticketid -notlike '*-*' } | Format-List -Property Clientname, ticketid, LastfailureMessage | Out-file -FilePath $LogFilePath

