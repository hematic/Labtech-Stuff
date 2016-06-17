<#
#####################################################################################
#Script Created by Phillip Marshall													#
#Creation Date 2/15/14																#
#																		            #
#Description - This script will gather all signature file information for one user  #
#              from the local machine and compare against a array of data compiled  #
#              from the outfile of the Serversiggather.ps1 script. Once the compare #
#              operation is complete it downloads and needed signature files.       #
#####################################################################################
#>

<#######################################################################################>
#Function Declarations

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

	add-content -path $LogFilePath -value ($Date + "`t:`t" + $Message)
}

Function Create-MD5Hash
{
	
	<#
	.SYNOPSIS
		A function to generate an MD5 hash for a file.
	
	.DESCRIPTION
		This function allows you to pass a file path to it and generate an MD5 Hash.
	
	.PARAMETER FileName
		The full path of the file to generate the MD5 hash for.
	
	.EXAMPLE
		PS C:\> Create-MD5Hash -Filename 'C:\Windows\Temp\ziptest.zip'
	
	.NOTES
		N/A
#>
	
	Param
	(
		[Parameter(Mandatory = $True, Position = 0)]
		[String]$Filename
	)
	
	$md5 = new-object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
	$hash = ([System.BitConverter]::ToString($md5.ComputeHash([System.IO.File]::ReadAllBytes($Filename)))).replace('-', '')
	$hash.ToLower()
	
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
	
	Write-Log "Entering Zip-Actions Function."
	
	switch ($PsCmdlet.ParameterSetName)
	{
		'Zip' {
			
			If ([int]$psversiontable.psversion.Major -lt 3)
			{
				
				New-Item $ZipPath -ItemType file
				$shellApplication = new-object -com shell.application
				$zipPackage = $shellApplication.NameSpace($ZipPath)
				$files = Get-ChildItem -Path $FolderPath -Recurse
				
				foreach ($file in $files)
				{
					$zipPackage.CopyHere($file.FullName)
					Start-sleep -milliseconds 500
				}
				
				Write-Log "Exiting Zip-Actions Function."
				break
				
			}
			
			Else
			{
				
				Add-Type -assembly "system.io.compression.filesystem"
				$Compression = [System.IO.Compression.CompressionLevel]::Optimal
				[io.compression.zipfile]::CreateFromDirectory($FolderPath, $ZipPath, $Compression, $True)
				Write-Log "Exiting Zip-Actions Function."
				break
			}
		}
		
		'Unzip' {
			Add-Type -assembly "system.io.compression.filesystem"
			$Compression = [System.IO.Compression.CompressionLevel]::Optimal
			[io.compression.zipfile]::ExtractToDirectory($ZipPath, $FolderPath)
			
			If ($DeleteZip) { Remove-item $ZipPath }
			
			Write-Log "Exiting Zip-Actions Function."
			break
		}
	}
	
}

Function Clean-Dir
{
	
	<#
	.SYNOPSIS
		A function to delete everything from a directory.
	
	.DESCRIPTION
		This function is PS 2 compatible. It will delete all files and subfolders from a directory.
		It leaves the root folder intact.
	
	.PARAMETER FilePath
		The root path that you wanted emptied out.
	
	.EXAMPLE
		PS C:\> Clean-Dir -FilePath 'C:\Windows\Temp\'
	
	.NOTES
		N/A
#>
	
	param
	(
		[parameter(Mandatory = $true)]
		[String]$FilePath
	)
	Write-Log "Entering the Clean-Dir Function."
	$ListofFiles = Get-ChildItem -Path $FilePath -Recurse | Where-Object { -not ($_.PSIsContainer) }
	$ListofDirs = Get-ChildItem -Path $FilePath -Recurse | Where-Object { $_.PSIsContainer }
	
	Foreach ($File in $ListofFiles)
	{
		Remove-Item $File.fullname -Force
	}
	
	Foreach ($Folder in $ListofDirs)
	{
		Remove-Item $Folder.FullName -Force
	}
	
	If ((Get-ChildItem -Path $FilePath -Recurse).count -ne 0)
	{
		Write-Log "Unable to clean out the local signature directory!!"
		$Result = 'UNCLEAN'
		Write-Log "Exiting the Clean-Dir Function."
		End-Script $Result
	}
	
	Else
	{
		Write-Log "All items were deleted successfully."
		Write-Log "Exiting the Clean-Dir Function."
	}
}

Function Remove-OldFile
{
	
		<#
	.SYNOPSIS
		A function to test and remove paths.
	
	.DESCRIPTION
		Pass a path to the function. It will test the connection and
		remove the item if it exists.
	
	.PARAMETER $FilePath
		The filepath to test.
	
	.EXAMPLE
		PS C:\> Remove-OldFile -Filepath $Path
	
	.NOTES
		N/A
	#>
	
	param
	(
		[parameter(Mandatory = $true)]
		[string]$Path
	)
	
	If (Test-Path $Path)
	{
		Remove-Item $Path -Force
	}
	
}

Function End-Script
{
	
	<#
	.SYNOPSIS
		A function to wrap up the end of the script.
	
	.DESCRIPTION
		Function has multiple tasks:
		1) Out-files a list of user created variables and their values.
		2) Out-files the contents of $Error.
		3) Out-files $Result
		4) Terminates the Script.
	
	.PARAMETER $Result
		The result string to outfile.
	
	.EXAMPLE
		PS C:\> End-Script -Result $Result
	
	.NOTES
		N/A
	#>
	
	param
	(
		[parameter(Mandatory = $true)]
		[String]$Result
	)

	Out-File -InputObject $Error -FilePath $ErrorPath
	Out-File -InputObject $Result -Filepath $ResultsPath
	Write-Log ("********************************")
	Write-Log ("*  $ScriptName Script Ends  *")
	Write-Log ("********************************")
	exit;
	
}

Function Signature-Download
{
  	<#
	.SYNOPSIS
		A function to download a signature form the LT Share.
	
	.DESCRIPTION

	.PARAMETER $Link
		
	
	.EXAMPLE
		PS C:\> End-Script -Result $Result
	
	.NOTES
		N/A
	#>
	
	param
	(
		[parameter(Mandatory = $true)]
		[Object]$File
	)  

    $url = "https://cwlabtech.connectwise.com/labtech/transfer/signatures/$LastUser/$($file.FileName)"
    $Savepath = "$LocalFilePath\$($file.FileName)"

    (New-Object System.Net.WebClient).DownloadFile($url, $Savepath)
    
    If(Test-path $Savepath)
    {
        $file.downloaded = 'SUCCESS'
        Return $File
    }

    Else
    {
        $file.downloaded = 'FAILURE'
        Return $File
    }

}

<#######################################################################################>
#Variable Declarations

$ErrorActionPreference = 'SilentlyContinue'																#Set to stop errors from garbling output.
[String]$LastUser = '@lastuser@' 	
[String]$ErrorPath = 'C:\Windows\Temp\ScriptErrors.txt'													#Out-file Path to record all errors produced by the script.
[String]$ResultsPath = "$($env:windir)\LTSVC\Signatures\SSG-Results.txt"												#Out-File Path to record script result.
[String]$ZipPath = "$($env:windir)\temp\OldSigs.zip"													#Path to Zip the Signature Directory to.
[String]$LogFilePath = "C:\Windows\LTSvc\Signatures\Signatures-$($LastUser).txt"						#Out-File Path for the script log file.
[String]$LocalFilePath = "C:\Users\$lastuser\AppData\Roaming\Microsoft\Signatures"						#Path to signature folder on the local machine.
[Bool]$SigPathCheck = Test-Path $localfilepath															#Result of test-path to the local signature directory.

<#######################################################################################>
#Deletion of files from previous script runs.

Remove-OldFile $ResultsPath
Remove-OldFile $ErrorPath
Remove-OldFile $FilesToGetPath
Remove-OldFile $HashesToCheckPath
Remove-OldFile $ZipPath
Remove-OldFile $LogFilePath

<#######################################################################################>
#Begin Logging

Write-Log ("********************************")
Write-Log ("* LocalSigGather Script Begins *")
Write-Log ("********************************")

<#######################################################################################>
#Build the array of objects containing the files that exist for the user on the server.

Write-Log "Downloading the list of signatures from the LT Share..."

$Url = "https://cwlabtech.connectwise.com/labtech/transfer/scripts/Signatures/SSG-SigFiles/serversignatures-$LastUser.txt"
$Savepath = "$($env:windir)\LTSvc\signatures\ServerSignatures-$($LastUser).txt"
(New-Object System.Net.WebClient).DownloadFile($url, $Savepath)
[String]$ServerFiles = Get-Content "$($env:windir)\LTSvc\signatures\ServerSignatures-$($LastUser).txt"

Write-Log "Starting to build the array that will contain all signature files for the user on the LTShare."

While ($ServerFiles.length -gt 0)
{
	$pos = $ServerFiles.IndexOf('!@!')
	$FullPath = $ServerFiles.Substring(0, $pos)
	$ServerFiles = $ServerFiles.Substring($pos + 3)
	
	$pos = $ServerFiles.IndexOf('@#@')
	$FileName = $ServerFiles.Substring(0, $pos)
	$ServerFiles = $ServerFiles.Substring($pos + 3)
	
	$pos = $ServerFiles.IndexOf('#$#')
	$Hash = $ServerFiles.Substring(0, $pos)
	$ServerFiles = $ServerFiles.Substring($pos + 3)
	
	$ServerSignatures +=
	@([pscustomobject]@{
		FullPath = $Fullpath;
		FileName = $Filename;
		Hash = $Hash;
        Downloaded = "NO";
        verified = "NO"
	})
}

Write-Log "Completed array of Objects. Length is $($ServerSignatures.length)"

If ($($ServerSignatures.length) -lt 1)
{
	Write-Log "Something went wrong trying to convert the signature string passed from the LabTech script into an array."
	$Result = 'Script Failed';
	End-Script $Result
}

<#######################################################################################>
#Checking if the local signature directory exists.

Write-Log "Checking the path to the signature directory..."

If ($SigPathCheck -eq $false)
{
	Write-Log "Didn't exist...creating it..."
	New-Item $localfilepath -type directory
	[Bool]$SigPathCheck = Test-Path $localfilepath
	If ($SigPathCheck -eq $false)
	{
		Write-Log "Unable to create the local signature directory at $LocalFilePath)."
		$Result = 'Script Failed';
		End-Script $Result
	}
	
	Write-Log "Signature folder exists now."
}

Write-Log "Directory Exists. Moving on..."

<#######################################################################################>
#Copy Down the files.

Write-Log "Copying down the files from the server..."

Foreach ($File in $ServerSignatures)
{
    $File = Signature-Download $File

    if($file.downloaded -eq 'FAILURE')
    {
        Write-Log "FILE: $($File.filename) failed to download."
    }

    Else 
    {
        Write-Log "FILE: $($File.filename) downloaded succesfully."
    }
}


<#######################################################################################>
#For each file in the signature folder we set permissions on them and then add to $LocalFileArray

Write-Log "Building an array of the signature files present in the users folder."
[Array]$LocalFiles = Get-ChildItem $Localfilepath | Where-Object { -not ($_.PSIsContainer) }

ForEach ($File in $Localfiles)
{
	IF ($file.IsReadOnly -eq $True) 
    { 
        $file.IsReadOnly = $false 
    }
	
	$Hash = Create-MD5Hash $file.fullname

	$LocalSignatures +=
	@([pscustomobject]@{
		FullPath = $file.FullName;
		FileName = $file.name;
		Hash = $Hash;
	})
}

Write-Log "Total number of signatures found was $($LocalSignatures.length)."

If (-not $LocalSignatures)
{
	Write-Log "A Problem Occured building the array of local signature files."
	$Result = 'Script Failed';
	End-Script $Result
}

<#######################################################################################>
#This section removes any files that exist in the local signature dir that don't exist
#in the server signature dir. It does this check by filename.

#Commenting this out for now NEED TO PUT BACK IN FOR 2.5
<#
Write-Log "Beginning Object comparison."

foreach ($Signature in $LocalSignatures)
{
	If ($serversignatures.filename -contains $Signature.filename)
	{
		
	}
	
	Else
	{
		Remove-Item $Signature.fullpath -Force
		Write-Log "Removed: $($Signature.fullpath)"
	}
}


#Remove all SubFolders

Get-ChildItem $Localfilepath -Recurse | Where-Object { ($_.PSIsContainer) } | Remove-Item -force -Recurse


Write-Log "Array comparison complete."
#>

#Build HashesToGet and FilesToCheck

foreach ($Signature in $ServerSignatures)
{
	If ($LocalSignatures.hash -contains $Signature.hash)
	{ 
        $Signature.verified = 'SUCCESS'
    }
	Else
	{
        $Signature.verified = 'FAIL'
	}
}


<#######################################################################################>
#Exits the script if all files are up to date.

If ($ServerSignatures.verified -contains 'FAIL')
{
	Write-Log "Some signatures did not update."
    Write-Log ("********************************")
    Write-Log ("*  BEGIN LIST OF FAILED FILES  *")
    Write-Log ("********************************")

    Foreach($Signature in $ServerSignatures)
    {
        If ($Signature.verified -eq 'FAIL')
        {
            Write-Log ""
            Write-Log "Signature : $($Signature.filename) failed to update."
            Write-Log "Download Status : $($Signature.downloaded)"
            Write-Log "Verification Status : $($Signature.verified)"
            Write-log "Hash : $($Signature.hash)"
        }
    }
    
	$Result = 'Updates Failed';
    End-Script $Result
}

Else
{
    Write-Log "Script completed Successfully."
    $Result = 'Success'
    End-Script $Result
}