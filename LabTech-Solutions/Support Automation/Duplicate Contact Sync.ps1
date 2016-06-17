<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2015 v4.2.83
	 Created on:   	4/29/2015 8:48 AM
	 Created by:   	 
	 Organization: 	 
	 Filename:     	
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>
<#########################################################################################>
<################################## Function Declarations ################################>

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

Function Global:wh
{
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $False, ValueFromPipeline = $True)]
		[string]$MyInput,
		[Parameter(Mandatory = $True, ValueFromPipeline = $True)]
		[int]$Color,
		[Parameter(Mandatory = $True, ValueFromPipeline = $True)]
		[int]$NewLine)
		<# 1 for red, 2 for green, anything else is white #>
	
	Begin
	{
		switch ($color)
		{
			1 { [string]$color = 'red' }
			2 { [string]$color = 'green' }
			default { [string]$color = 'white' }
		}
		if ($MyInput -eq $Null) { $MyInput = "" }
		If ($newLine -eq 0)
		{
			write-host "$MyInput" -fore $color;
			$MyStream.WriteLine($MyInput)
		}
		if ($newLine -eq 1)
		{
			write-host "$MyInput" -fore $color -NoNewLine;
			$MyStream.Write($MyInput)
		}
	}
	Process { }
	end { }
	
}

Function Do-Regex
{
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $True, ValueFromPipeline = $True)]
		[string]$Regex,
		[Parameter(Mandatory = $True, ValueFromPipeline = $True)]
		[string]$MatchData)
	
	$TempRegexResults = [regex]::matches($MatchData, $Regex)
	$RegexResult = "$($TempRegexResults.groups[1].value)"
	Return $RegexResult
}

<#########################################################################################>
<############################### Pre-Requisite Server Checks #############################>

$ExistCheckSQLDir = CheckRegKeyExists HKLM:\Software\Wow6432Node\Labtech\Setup MySQLDir;
$ExistCheckRootPwd = CheckRegKeyExists HKLM:\Software\Wow6432Node\Labtech\Setup RootPassword;

if ($ExistCheckSQLDir -eq $true)
{ $SQLDir = (Get-ItemProperty HKLM:\Software\Wow6432Node\Labtech\Setup -name MySQLDir).MySQLDir; }

elseif ($ExistsCheckSQLDir -eq $false)
{ wh "Critical Error: Unable to Locate SQL Directory Registry key ( HKLM:\Software\Wow6432Node\LabTech\Setup.MySQLDir )" -Color 1 -NewLine 0; exit; }

if ($ExistCheckRootPwd -eq $true)
{ $RootPwd = (Get-ItemProperty HKLM:\Software\Wow6432Node\Labtech\Setup -name RootPassword).RootPassword; }

elseif ($LabTechDir -eq $false)
{ wh "Critical Error: Unable to Locate Root Password Registry key ( HKLM:\Software\Wow6432Node\LabTech\Setup.RootPassword )" -Color 1 -NewLine 0; exit; }

$ContactCheck = Test-Path "c:\program files (x86)\labtech\backup\tablebase\contacts.sql"

IF ($ContactCheck -eq $False)
{
	wh "Unable to find the backup copy of the contacts table from this morning. Exiting the script." -color 1 -newline 0
		exit;
}

ELSE
{
	wh "Found the backup copy of the contacts table from this morning. Continuing the script." -color 2 -newline 0
}

<#########################################################################################>
<################################ Query to delete contacts ###############################>

set-location $SQLDir\bin;

$ContactPurge = .\mysql.exe --user=root --password=$RootPwd -e "
USE Labtech;
DELETE 
FROM contacts 
WHERE externalID<>0 
	AND contactid NOT IN (SELECT contactid FROM computers) 
	AND contactID NOT IN (SELECT contactid FROM alerttemplates)  (
	AND contactID NOT IN (SELECT contactid FROM locations) 
	AND contactid NOT IN (SELECT contactid FROM reportscheduler);" --batch -N

IF ($ContactPurge -match '0 errors')
{
	wh "Query Completed without Error. Doing some data gathering..." -color 2 -newline 0
	Do-Regex -Regex "(.*)(?:\srow\(s\)\saffected)" -MatchData $ContactPurge
	wh "Number of affected rows was $($RegexResult)" -color 1 -newline 0
}

ELSE
{
	wh "We received a MySQL Error. This script has failed."	-color 1 -newline 0
	Do-Regex -Regex "(?:Error Code:)([\S\s]*)(?:Execution Time)" -MatchData $ContactPurge
	wh "The error is $($RegexResult)" -color 1 -newline 0
		exit;
}

<#########################################################################################>

set-location $SQLDir\bin;

$TruncateMapping = .\mysql.exe --user=root --password=$RootPwd -e "
USE Labtech;
TRUNCATE plugin_cw_contactmapping;" --batch -N

IF ($TruncateMapping -match '0 errors')
{
	wh "Query Completed without Error. Doing some data gathering..." -color 2 -newline 0
	Do-Regex -Regex "(.*)(?:\srow\(s\)\saffected)" -MatchData $TruncateMapping
	wh "Number of affected rows was $($RegexResult)" -color 1 -newline 0
}

ELSE
{
	wh "We received a MySQL Error. This script has failed."	-color 1 -newline 0
	Do-Regex -Regex "(?:Error Code:)([\S\s]*)(?:Execution Time)" -MatchData $TruncateMapping
	wh "The error is $($RegexResult)" -color 1 -newline 0
		exit;
}

<#########################################################################################>
<#########################################################################################>

set-location $SQLDir\bin;

$InsertContacts = .\mysql.exe --user=root --password=$RootPwd -e "
USE Labtech;
INSERT INTO plugin_cw_contactmapping (contactID, CWContactRecID, LastUpdate)
SELECT ContactID, ExternalID, Last_Date
FROM contacts;" --batch -N

IF ($InsertContacts -match '0 errors')
{
	wh "Query Completed without Error. Doing some data gathering..." -color 2 -newline 0
	Do-Regex -Regex "(.*)(?:\srow\(s\)\saffected)" -MatchData $InsertContacts
	wh "Number of affected rows was $($RegexResult)" -color 1 -newline 0
}

ELSE
{
	wh "We received a MySQL Error. This script has failed."	-color 1 -newline 0
	Do-Regex -Regex "(?:Error Code:)([\S\s]*)(?:Execution Time)" -MatchData $InsertContacts
	wh "The error is $($RegexResult)" -color 1 -newline 0
		exit;
}

<#########################################################################################>

set-location $SQLDir\bin;

$PurgeUnmapped = .\mysql.exe --user=root --password=$RootPwd -e "
USE Labtech;
DELETE FROM plugin_cw_contactmapping WHERE CWContactRecID=0;" --batch -N

IF ($PurgeUnmapped -match '0 errors')
{
	wh "Query Completed without Error. Doing some data gathering..." -color 2 -newline 0
	Do-Regex -Regex "(.*)(?:\srow\(s\)\saffected)" -MatchData $PurgeUnmapped
	wh "Number of affected rows was $($RegexResult)" -color 1 -newline 0
}

ELSE
{
	wh "We received a MySQL Error. This script has failed."	-color 1 -newline 0
	Do-Regex -Regex "(?:Error Code:)([\S\s]*)(?:Execution Time)" -MatchData $PurgeUnmapped
	wh "The error is $($RegexResult)" -color 1 -newline 0
	exit;
}

<#########################################################################################>

<#########################################################################################>

set-location $SQLDir\bin;

$ForceContactImport = .\mysql.exe --user=root --password=$RootPwd -e "
USE Labtech;
;" --batch -N

IF ($PurgeUnmapped -match '0 errors')
{
	wh "Query Completed without Error. Doing some data gathering..." -color 2 -newline 0
	Do-Regex -Regex "(.*)(?:\srow\(s\)\saffected)" -MatchData $PurgeUnmapped
	wh "Number of affected rows was $($RegexResult)" -color 1 -newline 0
}

ELSE
{
	wh "We received a MySQL Error. This script has failed."	-color 1 -newline 0
	Do-Regex -Regex "(?:Error Code:)([\S\s]*)(?:Execution Time)" -MatchData $PurgeUnmapped
	wh "The error is $($RegexResult)" -color 1 -newline 0
	exit;
}



<#########################################################################################>