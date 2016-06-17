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

<#########################################################################################>

<#Pre-Requisite Server Checks#>

[String]$LogFilePath = "$env:windir/temp/LargeTableInfo.txt"

If (Test-Path "$LogFilePath") 
{ 
    Remove-Item "$LogFilePath" -Force
}

$ExistCheckSQLDir = CheckRegKeyExists HKLM:\Software\Wow6432Node\Labtech\Setup MySQLDir;
$ExistCheckRootPwd = CheckRegKeyExists HKLM:\Software\Wow6432Node\Labtech\Setup RootPassword;

if ($ExistCheckSQLDir -eq $true)
{ $SQLDir = (Get-ItemProperty HKLM:\Software\Wow6432Node\Labtech\Setup -name MySQLDir).MySQLDir; }

elseif ($ExistsCheckSQLDir -eq $false)
{ Write-Log "Critical Error: Unable to Locate SQL Directory Registry key ( HKLM:\Software\Wow6432Node\LabTech\Setup.MySQLDir )";exit; }

if ($ExistCheckRootPwd -eq $true)
{ $RootPwd = (Get-ItemProperty HKLM:\Software\Wow6432Node\Labtech\Setup -name RootPassword).RootPassword; }

elseif ($LabTechDir -eq $false)
{ Write-Log "Critical Error: Unable to Locate Root Password Registry key ( HKLM:\Software\Wow6432Node\LabTech\Setup.RootPassword )"; exit; }

<#########################################################################################>

set-location $SQLDir\bin;

$TableInfo = .\mysql.exe --user=root --password=$RootPwd -e "
USE Labtech;
SELECT ``Table_Name``, ``Table_Rows``, ``Data_Length`` / 1024 /1024, ``Index_length`` / 1024 /1024
FROM information_schema.tables
WHERE table_schema = 'LabTech'" --batch -N

Foreach ($Table in $TableInfo)
{
	$Tabletemp = $Table -split '\t+'
	$objTableInfo +=
	@([pscustomobject]@{ Name = $TableTemp[0]; Rows = $TableTemp[1]; SizeInMB = $TableTemp[2]; IndexLengthInMB = $TableTemp[3] })
}

Foreach ($Table in $objTableInfo)
{
	if ($($Table.SizeInMb) -ne 'null') { $Table.SizeInMb = "{0:N2}" -f [float]$Table.SizeInMb }
	if ($Table.IndexLengthInMB -ne 'null') { $Table.IndexLengthInMB = "{0:N2}" -f [float]$Table.IndexLengthInMB }
}

<#########################################################################################>

$TableResults = $objTableInfo | Where-Object { $_.SizeInMb -ne 'null' -and [int]$_.SizeInMb -gt 500 }


If($TableResults -eq $null -or $TableResults -eq "")
{
    Write-Log "No Large Tables Exist"
}

Else
{
    $TableResults | Format-List | Out-file -FilePath $LogFilePath
}