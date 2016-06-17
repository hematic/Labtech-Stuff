#Function Declarations
######################################
function Log-Message
{
    Param
    (
       [Parameter(Mandatory = $true, Position = 0)]
       [string]$Message 
    )

	Add-Content -Path $ScriptLog -Value $Message -force;
}

function Get-LabTechConnection
{
	param 
    (
	    [Parameter(Mandatory = $true, Position = 0)]
	    [string]$Phrase
	)
	
	$connectionObject = New-Object PSObject -Property @{
		host = "localhost"
		User = "root"
		pass = ""
		ltversion = 0
	}
	
	$Version = (Get-ItemProperty "HKLM:\Software\Wow6432Node\LabTech\Agent" -Name Version -ea SilentlyContinue).Version;
	
	#Looks like in 10.5 they decided to remove the version key ...
	$LTAgentVersion = Get-ItemProperty "C:\Program Files\LabTech\ltagent.exe"
	
	if ($LTAgentVersion)
	{
		$Version = $LTAgentVersion.VersionInfo.FileVersion.Substring(0, 7);
	}
	
	if (-not $Version)
	{
		#Try 10.5+ path
		$Version = (Get-ItemProperty "HKLM:\Software\LabTech\Agent" -Name Version -ea SilentlyContinue).Version;
		
		if (-not $Version)
		{
			write-error "Failed to retrieve version."
			return $null;
		}
	}
	
	$LTVersion = [double]$Version
	$connectionObject.ltversion = $LTVersion;
	
	# Check version
	if ($LTVersion -lt [double]105.210)
	{
		Log-Message "Version is pre 10.5";
		$DatabaseHost = (Get-ItemProperty "HKLM:\Software\Wow6432Node\LabTech\Agent" -Name SQLServer).SQLServer;
		
		if ($DatabaseHost)
		{
			$connectionObject.host = $DatabaseHost;
		}
		
		$connectionObject.pass = (Get-ItemProperty "HKLM:\Software\Wow6432Node\LabTech\Setup" -Name RootPassword -ea SilentlyContinue).RootPassword;
		return $connectionObject;
	}
	else
	{
		Log-Message "Version is 105 or greater";
		
		$DatabaseUser = (Get-ItemProperty "HKLM:\Software\LabTech\Agent" -Name User -ea SilentlyContinue).User;
		$DatabaseHost = (Get-ItemProperty "HKLM:\Software\LabTech\Agent" -Name SQLServer -ea SilentlyContinue).SQLServer;
		
		if ($DatabaseUser)
		{
			$connectionObject.user = $DatabaseUser;
		}
		
		if ($DatabaseHost)
		{
			$connectionObject.host = $DatabaseHost;
		}
	}
	
	#############################################
	###  Only for 10.5                         ##
	#############################################
	
	# Start with 64-bit location
	
	$CommonPath = "$env:ProgramFiles\LabTech\LabTechCommon.dll";
	
	if (-NOT (Test-Path $CommonPath))
	{
		# try 32-bit location next.
		$CommonPath = "${env:ProgramFiles(x86)}\LabTech Client\LabTechCommon.dll";
		$exists = Test-Path $CommonPath;
	}
	
	# Check to see if we found DLL
	if ($exists -eq $false)
	{
		write-error "Failed to find LabTechCommon library."
		return $null;
	}
	
	try
	{
		[Reflection.Assembly]::LoadFile($CommonPath) | out-null
		Log-Message "Successfully loaded commonpath";
	}
	catch
	{
		# probably can't find file
		Write-Error -Message "Failed to load LabTechCommon" -Exception System.IO.FileNotFoundException;
		return $null;
	}
	
	# Get txt to decrypt
	if (Test-Path "HKLM:\Software\LabTech\Agent")
	{
		$txtToDecrypt = Get-ItemProperty HKLM:\Software\LabTech\Agent -Name MysqlPass | select -expand MySQLPass;
	}
	else
	{
		$txtToDecrypt = Get-ItemProperty HKLM:\Software\WOW6432Node\LabTech\Agent -Name MysqlPass | select -expand MySQLPass;
	}
	
	Log-Message "Text to decrypt: $txtToDecrypt"
	
	if (-not $txtToDecrypt)
	{
		Write-Error "Failed to locate mysqlPass key"
		return $null;
	}
	
	[array]$byteArray = @([byte]240, [byte]3, [byte]45, [byte]29, [byte]0, [byte]76, [byte]173, [byte]59);
	
	$lbtVector = [byte[]]$byteArray;
	$cryptoSvcProvider = New-Object System.Security.Cryptography.TripleDESCryptoServiceProvider;
	
	[byte[]]$InputBuffer = [System.Convert]::FromBase64String($txtToDecrypt);
	
	if ($InputBuffer.Length -lt 1)
	{
		write-error "Empty buffer. Cannot decrypt";
		return $null;
	}
	
	$hash = new-object LabTechCommon.clsLabTechHash;
	$hash.ComputeHash([System.Text.Encoding]::ASCII.GetBytes($Phrase));
	$cryptoSvcProvider.Key = $hash.GetDigestBytes();
	$cryptoSvcProvider.IV = $lbtVector;
	
	$access = [System.Text.Encoding]::ASCII.GetString($cryptoSvcProvider.CreateDecryptor().TransformFinalBlock($InputBuffer, 0, $InputBuffer.Length));
	
	if ($access)
	{
		$connectionObject.pass = $access;
		return $connectionObject;
	}
	else
	{
		return $null;
	}
	
}

function Get-SQLResult
{
    param 
    (
	    [Parameter(Mandatory = $true, Position = 0)]
	    [string]$Query
	)

	$result = .\mysql.exe --host="$DBHost" --user="$DBUser" --password="$DBPass" --database="LabTech" -e "$query" --batch --raw -N;
	return $result;
}

Function CheckRegKeyExists ($Dir,$KeyName) 
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

function Download-MySQLExe
{
	
	try
	{
		$DownloadObj = new-object System.Net.WebClient;
		$DownloadObj.DownloadFile($DownloadURL, $MySQLZipPath);
	}
	catch
	{
		$Caughtexception = $_.Exception.Message;
	}
	
	if (!(Test-Path $MySQLZipPath))
	{
		Log-Message "[DOWNLOAD FAILED] :: Failed to download MySQL ZIP archive! If any exceptions, here they are: $Caughtexception";
		return $false;
	}
	
	# ok, the file exists. Let's ensure that it matches up with our hash.
	# mysql.zip hash
	$ExpectedHash = "40-FD-7B-E8-19-22-99-31-C6-64-D3-0C-46-C1-BF-F2";
	$fileMd5 = New-Object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
	$zipHash = [System.BitConverter]::ToString($fileMd5.ComputeHash([System.IO.File]::ReadAllBytes($MySQLZipPath)))
	
	if ($zipHash -ne $ExpectedHash)
	{
		# Integrity issue. Could be content filtering...
		Log-Message "[HASH MISMATCH] :: The mysql.zip file's md5 hash does not match the original."
		return $false;
	}
	else
	{
		return $true;
	}
	
	
}

Function Zip-Actions
{
       <#
       .SYNOPSIS
              A function to zip or unzip files.
       
       .DESCRIPTION
              This function has 3 possible uses.
              1) Zip a folder or files and save the zip to specified location.
              2) Unzip a zip file to a specified folder.
              3) Unzip a zip file and delete the original zip when complete.       
      
 
       .PARAMETER ZipPath
              The full path of the file to unzip or the full path of the zip file to be created.
       
       .PARAMETER FolderPath
              The path to the files to zip or the path to the directory to unzip the files to.
       
       .PARAMETER Unzip
              If $true the function will perform an unzip instead of a zip
       
       .PARAMETER DeleteZip
              If set to $True the zip file will be removed at then end of the unzip operation.
       
       .EXAMPLE
              PS C:\> Zip-Actions -ZipPath 'C:\Windows\Temp\ziptest.zip' -FolderPath 
              PS C:\> Zip-Actions -ZipPath 'C:\Windows\Temp\ziptest.zip' -FolderPath 'C:\Windows\Temp\ZipTest' -Unzip $true
              PS C:\> Zip-Actions -ZipPath 'C:\Windows\Temp\ziptest.zip' -FolderPath 'C:\Windows\Temp\ZipTest' -Unzip $true -DeleteZip $True
       
       .NOTES
              Additional information about the function.
#>
       
       [CmdletBinding(DefaultParameterSetName = 'Zip')]
       param
       (
              [Parameter(ParameterSetName = 'Unzip')]
              [Parameter(ParameterSetName = 'Zip',
                              Mandatory = $true,
                              Position = 0)]
              [ValidateNotNull()]
              [string]$ZipPath,
              [Parameter(ParameterSetName = 'Unzip')]
              [Parameter(ParameterSetName = 'Zip',
                              Mandatory = $true,
                              Position = 1)]
              [ValidateNotNull()]
              [string]$FolderPath,
              [Parameter(ParameterSetName = 'Unzip',
                              Mandatory = $false,
                              Position = 2)]
              [ValidateNotNull()]
              [bool]$Unzip,
              [Parameter(ParameterSetName = 'Unzip',
                              Mandatory = $false,
                              Position = 3)]
              [ValidateNotNull()]
              [bool]$DeleteZip
       )
       
       Log-Message "Entering Zip-Actions Function."
       
       switch ($PsCmdlet.ParameterSetName)
       {
              'Zip' {
                     
                     If ([int]$psversiontable.psversion.Major -lt 3)
                     {
                           Log-Message "Step 1"
                           New-Item $ZipPath -ItemType file
                           $shellApplication = new-object -com shell.application
                           $zipPackage = $shellApplication.NameSpace($ZipPath)
                           $files = Get-ChildItem -Path $FolderPath -Recurse
                           Log-Message "Step 2"
                           foreach ($file in $files)
                           {
                                  $zipPackage.CopyHere($file.FullName)
                                  Start-sleep -milliseconds 500
                           }
                           
                           Log-Message "Exiting Zip-Actions Function."
                           break           
                     }
                     
                     Else
                     {
                           Log-Message "Step 3"
                           Add-Type -assembly "system.io.compression.filesystem"
                           $Compression = [System.IO.Compression.CompressionLevel]::Optimal
                           [io.compression.zipfile]::CreateFromDirectory($FolderPath, $ZipPath, $Compression, $True)
                           Log-Message "Exiting Zip-Actions Function."
                           break
                     }
              }
              
              'Unzip' {

			    $shellApplication = new-object -com shell.application
			    $zipPackage = $shellApplication.NameSpace($ZipPath)
			    $destinationFolder = $shellApplication.NameSpace($FolderPath)
			    $destinationFolder.CopyHere($zipPackage.Items(), 20)
                Log-Message "Exiting Unzip Section"
				
                        }
       }
       
}

Function Process-Results
{
       
       [cmdletbinding()]

       param
       (
            [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
            [Array]$Updates
       )


        Foreach($Update in $Updates)
        {
       
            #Eliminate first 2 rows of the log
            ##################################
            If($Update -like '*LabTech Solution Center -*' -or $Update -like '*|1|2|3|4| Item Name*'){}


            #Parse Last Row of the Log
            ##################################
            ElseIf($Update -like '*items installed successfully*')
            {
                $Script:NumGoodUpdates = ([regex]::matches($Update, "(\d*)")).groups[1].value
                $Script:NumTotalUpdates = ([regex]::matches($Update, "(?:\d*\sof\s)(\d*)")).groups[1].value
            }

            #Parse All Other Rows
            ##################################
            ElseIf($Update -like '*|{*')
            {
                $Guid = ([regex]::matches($Update, "(?:\|{)(.*)(?:})")).groups[1].value
                $Col1 = ([regex]::matches($Update, "(?:\|{.+\}\s)(\w)")).groups[1].value
                $Col2 = ([regex]::matches($Update, "(?:\|{.+\}\s\w\s)(\w)")).groups[1].value
                $Col3 = ([regex]::matches($Update, "(?:\|{.+\}\s\w\s\w\s)(\w)")).groups[1].value
                $Col4 = ([regex]::matches($Update, "(?:\|{.+\}\s\w\s\w\s\w\s)(\w)")).groups[1].value
                $Name = ([regex]::matches($Update, "(?:\|{.+\}\s\w\s\w\s\w\s\w\s)(.*)")).groups[1].value

                $Script:ParsedUpdates += New-Object PSObject -Property @{
                Name             = $Name;
		        GUID             = $Guid;
		        Specified        = $Col1;
                Updated          = $Col2;
                WhyUpdateStatus  = $Col3;
                Result           = $Col4;
                }

            }

        }

        Return $Script:ParsedUpdates
     
       
}

#Prep Work 
######################################
    
#Files
######################################
[STRING]$ScriptLog = "$Env:windir\temp\script.txt"
[STRING]$FailedUpdateLog = "$Env:windir\temp\failedupdates.txt"
[STRING]$UpdateLog = "$Env:windir\temp\marketplaceupdates.txt"
[STRING]$CommandFile = "$Env:windir\Temp\SCCommandfile.txt"

#Other Items
######################################
$VerbosePreference = 'SilentlyContinue'
$ErrorActionPreference = 'SilentlyContinue'
[STRING]$KeyPhrase = 'Thank you for using LabTech.'
[Array]$ExtraItemsArray = @()

#Add all the custom items we want.
######################################
$ExtraItemsArray += New-Object PSObject -Property @{
    Name = 'Active Directory'
    Guid = '368b2769-4bd4-4408-92aa-08f1fe32f7d6'
}

$ExtraItemsArray += New-Object PSObject -Property @{
    Name = 'Deployment manager Dashboard'
    Guid = '5fb33973-c1ec-4cfb-b74b-aebea1c7032b'
}

$ExtraItemsArray += New-Object PSObject -Property @{
    Name = 'LT License Manager'
    Guid = 'b13fe3a1-0afd-4d58-a628-0b4632de886f'
}

$ExtraItemsArray += New-Object PSObject -Property @{
    Name = 'ScreenConnect'
    Guid = 'ccf607eb-1c6d-4b29-b68c-7e127477a7c1'
}

$ExtraItemsArray += New-Object PSObject -Property @{
    Name = 'Virtualization'
    Guid = '58d5204e-a51a-4f28-af0d-e563517c0cce'
}

$ExtraItemsArray += New-Object PSObject -Property @{
    Name = 'BlackListed Events'
    Guid = '08a92050-9af4-4f7c-954c-9969c2afd239'
}

$ExtraItemsArray += New-Object PSObject -Property @{
    Name = 'Database Management Pack'
    Guid = '23c9ddef-d410-4150-9239-6c7f18a8dba6'
}

$ExtraItemsArray += New-Object PSObject -Property @{
    Name = 'Messaging Management Pack'
    Guid = '91bf72c8-6718-45f8-8915-2782f69d701b'
}

$ExtraItemsArray += New-Object PSObject -Property @{
    Name = 'Web/Proxy Management Pack'
    Guid = '29486994-5a76-4658-bea8-2c1008078812'
}

[STRING]$ExtraItems = $ExtraItemsArray | % {"I:`{$($_.guid)`};"}
[BOOL]$ExistCheckSQLDir = CheckRegKeyExists HKLM:\Software\Wow6432Node\Labtech\Setup MySQLDir;
[BOOL]$DownloadNeeded = $True;
[ARRAY]$Script:ParsedUpdates = @()
[ARRAY]$FailedUpdates = @()

#Clean Up Old Files
######################################
If($CommandFile)     {remove-item $CommandFile -force -ea SilentlyContinue | Out-null}
If($ScriptLog)       {remove-item $ScriptLog -force -ea SilentlyContinue | Out-null}
If($FailedUpdateLog) {remove-item $FailedUpdateLog -force -ea SilentlyContinue | Out-null}
If($UpdateLog)       {remove-item $UpdateLog -force -ea SilentlyContinue | Out-null}

#Get connected to the Labtech database
######################################

if ($ExistCheckSQLDir -eq $true)
{
	# Likely to be LT 10
	$SQLDir = (Get-ItemProperty HKLM:\Software\Wow6432Node\LabTech\Setup -name MySQLDir).MySQLDir;
	
	if (Test-Path $SQLDir\mysql.exe)
	{
		Log-Message "Found mysql.exe in MySQL directory..";
		$DownloadNeeded = $false;
	}
}

If ($DownloadNeeded)
{
	
	$DownloadURL = "https://ltpremium.s3.amazonaws.com/third_party_apps/mysql_x64/mysql.zip"
	$MySQLExePath = "$env:windir\temp\mysql.exe"
	$MySQLZipPath = "$env:windir\temp\mysql.zip"
	
	# download mysql.zip and verify md5
	$DownloadResult = Download-MySQLExe;
	
	Log-Message $DownloadResult;
	
	if ($DownloadResult -ne $true)
	{
		Log-Message "Failed to download Mysql.exe, which is required to interface with MySQL. Could not complete server validation."
		Return "Failed to download Mysql.exe"
	}
	
	# Unzip mysql.exe to temp
	New-item "$env:windir\ServerMonitor\Packages\MySQL" –ItemType Directory –FORCE | out-null;
	
	Zip-Actions -ZipPath $MySQLZipPath -FolderPath "$env:windir\temp\" -Unzip $true -DeleteZip $true | Out-Null;
	
	if (-not (Test-Path $MySQLExePath))
	{
		Log-Message "[EXTRACTION FAILED] :: Failed to extract MySQL.exe from the zip archive. Script is exiting! Here are the Powershell errors: $($Error)";
		Return "Extraction of MySQL failed."
	}

	else
	{
		$SuccessfulDownload = $true;
		Log-Message "[SUCCESS] :: MySQL.exe was successfully extracted from the downloaded zip archive.";
		$SQLDir = "$env:windir\ServerMonitor\Packages\MySQL";
	}
}

[psobject]$ConnectionDetails = Get-LabTechConnection $KeyPhrase;

if ($ConnectionDetails -eq $null)
{
	$errorMessage = "Failed to determine MySQL connection details from this server.`n`n";
	Log-Message $errorMessage
	Return "Failed to get MySQL Connection Details"
}

else
{
	Log-Message "Successfully retrieved connection details."
}

$DBUser = $ConnectionDetails.user;
$DBHost = $ConnectionDetails.host;
$DBPass = $ConnectionDetails.pass;
$LTVersion = $ConnectionDetails.LTVersion;

#Get the LT Share directory from the DB
######################################

set-location "$env:windir\temp\";

$LtShareQry = @"
SELECT `localltshare` FROM `config`
"@

$LTSharedir = get-sqlresult -query $Ltshareqry

If($LtshareDir -eq $null)
{
    Log-message "Unable to retrieve the Local LT Share path from the database."
    Return "Unable to retrieve Local LT Share Path"
}

Else
{
    Log-message "Local LT Share : $LTShareDir"
}

#Set the proper file and folder permissions.
######################################

attrib -r $Ltsharedir
icacls $ltsharedir\* /T /Q /C /RESET
Set-Location "C:\Program Files (x86)\LabTech Client"
attrib -R *.* /S
Set-Location  "C:\ProgramData\LabTech Client\Logs"
attrib -R *.* /S

#Run the solution center update process.
######################################

#We add our extra items to the commandfile that marketplace.exe will use.
Add-Content -Path $Commandfile -Value $ExtraItems

#Declare the arguments to use with Start-process
$AllArgs = "/update /fix /commandfile $Commandfile"

#Call marketplace.exe in a hidden window and wait for it to finish. We send all output to $UpdateLog
Start-Process -FilePath "${env:ProgramFiles(x86)}\LabTech Client\LTMarketplace.exe" -ArgumentList $AllArgs -PassThru -RedirectStandardOutput $UpdateLog -Wait -WindowStyle Hidden

#Grab the results form the log for parsing.
$updateResults = Get-content $Updatelog

#Error Checking to validate the EXE ran correctly
######################################

If(!$updateResults)
{
    Log-Message 'The marketplace update log was not generated.'
    Return "The marketplace update log was not generated."
}

Else
{
    If($updateResults | Where-object { $_ -match 'items installed successfully'})
    {
        Log-Message "Update log contains valid results. Moving on."
    }

    Else
    {
        Log-Message "Something is wrong with the update log."
        Return "Something is wrong with the update log."
    }
}

#Parse the update results into an object
######################################

Process-Results $updateResults

#Find Failed Updates
######################################

$Script:ParsedUpdates | Where-Object {$_.Result -eq 'F'} | Select-Object -ExpandProperty Name | Add-Content -Path $FailedUpdateLog

If ((Test-Path $FailedUpdateLog) -eq $False)
{
    Add-Content -Path $ScriptLog -Value "Complete Success"
    Return "Complete Success"
}

ELSE
{
    Add-Content -Path $ScriptLog -Value "Check FailedUpdates Log"
    Return "Check Failed Updates Log"
}