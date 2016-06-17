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

[String]$LogFilePath = "$($env:windir)/temp/PluginInfo.txt"

If (Test-Path "$LogFilePath") 
{ 
    Remove-Item "$LogFilePath" -Force
}

$ExistCheckSQLDir = CheckRegKeyExists HKLM:\Software\Wow6432Node\Labtech\Setup MySQLDir;
$ExistCheckRootPwd = CheckRegKeyExists HKLM:\Software\Wow6432Node\Labtech\Setup RootPassword;

if ($ExistCheckSQLDir -eq $true)
{ 
    $SQLDir = (Get-ItemProperty HKLM:\Software\Wow6432Node\Labtech\Setup -name MySQLDir).MySQLDir; 
}

elseif ($ExistsCheckSQLDir -eq $false)
{ 
    Write-Log "Critical Error: Unable to Locate SQL Directory Registry key ( HKLM:\Software\Wow6432Node\LabTech\Setup.MySQLDir )";
    exit; 
}

if ($ExistCheckRootPwd -eq $true)
{ 
    $RootPwd = (Get-ItemProperty HKLM:\Software\Wow6432Node\Labtech\Setup -name RootPassword).RootPassword; 
}

elseif ($LabTechDir -eq $false)
{ 
    Write-Log "Critical Error: Unable to Locate Root Password Registry key ( HKLM:\Software\Wow6432Node\LabTech\Setup.RootPassword )"; 
    exit; 
}

<#########################################################################################>

set-location $SQLDir\bin;

$PluginInfo = .\mysql.exe --user=root --password=$RootPwd -e "
USE Labtech;
SELECT 
``name``, ``version``, ``enable`` 
FROM ``plugins``" --batch -N

Foreach ($Plugin in $PluginInfo)
{
	$Plugintemp = $Plugin -split '\t+'
	$objPluginInfo +=
	@([pscustomobject]@{ PluginName = $PluginTemp[0]; Version = $PLuginTemp[1]; Enabled = $PluginTemp[2]; })
}

Foreach ($Plugin in $objPluginInfo)
{
	If ($Plugin.Enabled -eq '0') { $Plugin.Enabled = 'NO' }
	If ($Plugin.Enabled -eq '1') { $Plugin.Enabled = 'YES' }
}

<#########################################################################################>

$objPluginInfo | Format-List | Out-File -FilePath $LogFilePath