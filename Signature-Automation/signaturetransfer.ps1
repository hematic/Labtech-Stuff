<#	
	.NOTES
	===========================================================================
	 Created with: 	SAPIEN Technologies, Inc., PowerShell Studio 2015 v4.2.86
	 Created on:   	6/11/2015 10:20 AM
	 Created by:   	Phillip Marshall 
	 Organization: 	LabTech Software 
	 Filename:     	SignatureTransfer.ps1
	===========================================================================
	.DESCRIPTION
		Script was designed to replace the RoboCopy setup to mirror the Marketing
		Signature share over the the LTShare of the LabTech Server. 

	.Output
		Script outputs numerous files for error checking and logging.
		1) C:\windows\temp\SigTransfer-Log.txt: Acts as the overall script log
		2) C:\Windows\Temp\objfilearray.txt: This is an export of the object  
		   that contains all of the source files.
		3) C:\Windows\Temp\objdestinationfilearray.txt: This is an export of the 
	       object that contains all of the destination files.
		4) C:\Windows\Temp\PSerrors.txt: This is an export of the $error variable.
		5) Finally the script will return 'SUCCESS' or 'FAILURE' to the LT Script.
#>

#######################################################################################
#Function Declarations

function Copy-Folder
{
	<#
	.SYNOPSIS
		A function to copy a folder from one path to another.
	
	.DESCRIPTION
		This function allows you to pass a folder object path to it and it will check a 
	    destination path to see if that folder exists. If it doesnt it will copy it there.
	
	.PARAMETER Folder
		An object that contains various properties related to a folder:
			FullPath
			NewPath
			Extension
			Name
			MD5
			Copied
	
	.EXAMPLE
		PS C:\> Copy-Folder -Folder $Item
	
	.NOTES
		N/A
	#>
	
	param
	(
		[parameter(Mandatory = $true)]
		[Object]$Folder
	)
	
	If (Test-Path $Folder.newpath)
	{
		$Folder.copied = 'Present'
	}
	
	Else
	{
		Copy-Item -Path $Folder.fullpath -Destination $Folder.newpath -Force
		
		If (Test-Path $Folder.newpath)
		{
			$Folder.copied = 'Yes'
		}
		
		Else
		{
			$Folder.copied = 'Failed'
		}
	}
	Write-FileLog "Folder: $($Folder.newpath) | Copied: $($Folder.Copied)"
	Return $Folder
}

function Copy-File
{
	<#
	.SYNOPSIS
		A function to copy a file from one path to another.
	
	.DESCRIPTION
		This function allows you to pass a file object path to it and it will check a 
	    destination path to see if that file exists. If it does it will verify the md5 
	    hash of that item against the original. If the file doesnt exist, or the md5 
	    hash does not match, it will copy over the file.
	
	.PARAMETER File
		An object that contains various properties related to a file:
			FullPath
			NewPath
			Extension
			Name
			MD5
			Copied
	
	.EXAMPLE
		PS C:\> Copy-File -File $Item
	
	.NOTES
		N/A
	#>
	
	param
	(
		[parameter(Mandatory = $true)]
		[Object]$File
	)
	
	If (Test-Path $File.newpath)
	{
		$TestMD5 = Create-MD5Hash $File.newpath
		
		If ($TestMD5 -eq $File.MD5)
		{
			$File.copied = 'Present'
		}
		
		Else
		{
			Copy-Item -Path $File.fullpath -Destination $File.newpath -Force
			
			If (Test-Path $File.newpath)
			{
				$File.copied = 'Yes'
			}
			
			Else
			{
				$File.copied = 'Failed'
			}
		}
	}
	
	Else
	{
		Copy-Item -Path $File.fullpath -Destination $File.newpath -Force
		
		If (Test-Path $File.newpath)
		{
			$File.copied = 'Yes'
		}
		
		Else
		{
			$File.copied = 'Failed'
		}
	}
	Write-FileLog "File: $($File.newpath) | Copied: $($File.Copied)"
	Return $File
	
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
	
	.PARAMETER Severity
		The label assigned to that log message line. Options are "Note", "Warning", and "Problem"
	
	.EXAMPLE
		PS C:\> Write-Log -StrMessage 'This is a note message being written out to the log.' 
		PS C:\> Write-Log -StrMessage 'This is a warning message being written out to the log.' -Severity 2
		PS C:\> Write-Log -StrMessage 'This is a error message being written out to the log.' -Severity 3
		PS C:\> Write-Log -StrMessage 'This message being written has no severity.'
	
	.NOTES
		N/A
#>
	
	Param
		(
		[Parameter(Mandatory = $True, Position = 0)]
		[String]$Message,
		[Parameter(Mandatory = $False, Position = 1)]
		[INT]$Severity
	)
	
	$Note = "[NOTE]"
	$Warning = "[WARNING]"
	$Problem = "[ERROR]"
	[string]$Date = get-date
	
	switch ($Severity)
	{
		1 { add-content -path $LogFilePath -value ($Date + "`t:`t" + $Note + $Message) }
		2 { add-content -path $LogFilePath -value ($Date + "`t:`t" + $Warning + $Message) }
		3 { add-content -path $LogFilePath -value ($Date + "`t:`t" + $Problem + $Message) }
		default { add-content -path $LogFilePath -value ($Date + "`t:`t" + $Message) }
	}
	
	
}

Function Write-FileLog
{
	<#
	.SYNOPSIS
		A function to write ouput messages to a logfile.
	
	.DESCRIPTION
		This function is designed to send timestamped messages to a logfile of your choosing.
		Use it to replace something like write-host for a more long term log.
	
	.PARAMETER StrMessage
		The message being written to the log file.
	
	.PARAMETER Severity
		The label assigned to that log message line. Options are "Note", "Warning", and "Problem"
	
	.EXAMPLE
		PS C:\> Write-Log -StrMessage 'This is a note message being written out to the log.' 
		PS C:\> Write-Log -StrMessage 'This is a warning message being written out to the log.' -Severity 2
		PS C:\> Write-Log -StrMessage 'This is a error message being written out to the log.' -Severity 3
		PS C:\> Write-Log -StrMessage 'This message being written has no severity.'
	
	.NOTES
		N/A
#>
	
	Param
		(
		[Parameter(Mandatory = $True, Position = 0)]
		[String]$Message
	    )
	
	[string]$Date = get-date
	
    add-content -path $FileTransferPath -value ($Date + "`t:`t" + $Message)

	}

Function Create-MD5Hash
{
	
	<#
	.SYNOPSIS
		A function to generate an MD5 hash for a file.
	
	.DESCRIPTION
		This function allows you to pass a file object to it and generate an MD5 Hash.
	
	.PARAMETER File
		An object that contains various properties related to a file:
			FullPath
			NewPath
			Extension
			Name
			MD5
			Copied
	
	.EXAMPLE
		PS C:\> Create-MD5Hash -File $item
	
	.NOTES
		N/A
#>
	
	Param (
		[Parameter(Mandatory = $True, Position = 0)]
		[Object]$File
	)
	
	If ($File.extension -ne '')
	{
		$md5 = new-object -TypeName System.Security.Cryptography.MD5CryptoServiceProvider
		$hash = ([System.BitConverter]::ToString($md5.ComputeHash([System.IO.File]::ReadAllBytes($File.fullname)))).replace('-', '')
		Return $hash.ToLower()
	}
	
	Else
	{
		Return 'Folder'
	}
}

function Remove-File
{
	<#
	.SYNOPSIS
		A function to verify a file exists in another directory and if it does not
	    remove it from the directory it currently exists in.
	
	.DESCRIPTION
		This function allows you to pass a file object path to it and it will check a 
	    destination path to see if that file exists. If it does not exist in that directory
	    the file will be removed from its currenty directory. It also changes the files 
	    'Validated' property.
	
	.PARAMETER File
		An object that contains various properties related to a file:
			FullPath
			CheckPath
			Extension
			Name
			Validated
	
	.EXAMPLE
		PS C:\> Remove-File -File $Item
	
	.NOTES
		N/A
	#>
	
	param
	(
		[parameter(Mandatory = $true)]
		[Object]$File
	)
	
	If (Test-Path $File.checkpath)
	{
		$File.validated = 'Yes'
	}
	
	Else
	{
		Remove-Item -Path $File.FullPath -Force
		$File.validated = 'Removed'
		Write-Log "The file $($File.fullpath) was removed."
	}

	Write-FileLog "File: $($File.fullpath) | Validated: $($File.Validated)"
	Return $File
}

function Remove-Folder
{
	<#
	.SYNOPSIS
		A function to verify a folder exists in another directory and if it does not
	    remove it from the directory it currently exists in.
	
	.DESCRIPTION
		This function allows you to pass a folder object path to it and it will check a 
	    destination path to see if that folder exists. If it does not exist in that directory
	    the folder will be removed from its currenty directory. It also changes the folder's 
	    'Validated' property.
	
	.PARAMETER Folder
		An object that contains various properties related to a file:
			FullPath
			CheckPath
			Extension
			Name
			Validated
	
	.EXAMPLE
		PS C:\> Remove-Folder -File $Item
	
	.NOTES
		N/A
	#>
	param
	(
		[parameter(Mandatory = $true)]
		[Object]$Folder
	)
	
	If (Test-Path $Folder.checkpath)
	{
		$Folder.validated = 'Yes'
	}
	
	Else
	{
		Remove-Item -Path $Folder.FullPath -Force -Recurse
		$Folder.validated = 'Removed'
		Write-Log "The folder $($Folder.fullpath) was removed."
	}
	
    Write-FileLog "Folder: $($Folder.fullpath) | Validated: $($Folder.Validated)"
	Return $Folder
}

Function Get-UserVariables
{
	
		<#
	.SYNOPSIS
		A function to gather a list of all user variables in the powershell script..
	
	.DESCRIPTION
		This function will exclude all variables that are NOT user created.
	
	.EXAMPLE
		PS C:\> Get-UserVariables
	
	.NOTES
		N/A
#>
	
	Compare-Object (Get-Variable) $AutomaticVariables -Property Name -PassThru | Where -Property Name -ne "AutomaticVariables"
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
	$Mystuff = Get-UserVariables
	Out-File -InputObject $MyStuff -FilePath $OutVarPath
	Out-File -InputObject $Error -FilePath $ErrorPath
	Out-File -InputObject $Result -Filepath $ResultsPath
	Write-Log ("********************************")
	Write-Log ("***** $($ScriptName) Ends *****")
	Write-Log ("********************************")
	exit;
}

#######################################################################################
#Variable Declarations

$ErrorActionPreference = 'SilentlyContinue'
[Object]$AutomaticVariables = Get-Variable
[String]$ScriptName = "Signature Transfer"
[String]$SourceFolderPath = "\\HQFS\Marketing\Art\email-signatures\"
[String]$DestinationFolderPath = "x:"
[string]$PSDrivePath = '\\172.17.1.11\LTShare\Transfer\Signatures\'
[String]$ErrorPath = "$($env:windir)\temp\SigTransferERRORS.txt"
[String]$LogFilePath = "$($env:windir)\temp\SigtransferLOG.txt"
[String]$OutVarPath = "$($env:windir)\temp\SigTransferVARS.txt"
[String]$ResultsPath = "$($env:windir)\temp\SigTransferRESULTS.txt"
[String]$FileTransferPath = "$($env:windir)\temp\DetailedFileLog.txt"
[Int]$FailedFolders = 0
[Int]$FailedFiles = 0
[Array]$objFileArray = @()
$date=(get-date -Format d) -replace "/","."

#######################################################################################
#Handle Previous Files

IF (Test-Path $ErrorPath)		 {Remove-Item $ErrorPath}
IF (Test-Path $OutVarPath) 		 {Remove-Item $OutVarPath}
IF (Test-Path $ResultsPath) 	 {Remove-Item $ResultsPath}
IF (Test-Path $LogFilePath)	     {Rename-Item -Path $LogFilePath -NewName "SigtransferLOG - $Date.txt"}
If (Test-Path $FileTransferPath) {Rename-Item -Path $FileTransferPath -NewName "DetailedFileLog - $Date.txt"}

#######################################################################################
#Gather all files from the marketing share

Write-Log "*************************************"
Write-Log "***** $($ScriptName) BEGINS *****"
Write-Log "*************************************"

Write-Log "Beginning retrieval of sourcefiles..." 

<#
Try
{
   Test-Path $SourceFolderPath 
}


Catch
{
    $Exceptionmessage = $_.exception.message
}

Finally
{
    If($Exceptionmessage) 
    {
        $Result = "Test-path failed for Marketing Share"
        Write-Log "Test-Path Failed for $($Sourcefolderpath)" -Severity 3
        Write-Log "Exception: $Exceptionmessage"
        End-Script -Result $Result
    }
}
#>

if(!(Test-Path $SourceFolderPath ))
{
    $Result = "Test-path failed for Marketing Share"
    Write-Log "Test-Path Failed for $($Sourcefolderpath)" -Severity 3
    End-Script -Result $Result
}


$SourceFiles = Get-ChildItem $SourceFolderPath -Recurse

If(!($SourceFiles))
{
    $Result = "Unable to Gather Files from the Marketing Share."
    Write-Log "Unable to Gather Files from the Marketing Share." -Severity 3
    End-Script -Result $Result
}

Write-Log "Completed retrieval of Sourcefiles..." 

#######################################################################################
#Make and test the PSDrive connection. No -credential is needed as the script is being run-as 
#a user with permissions already.

try
{
	New-PSDrive -Name X -PSProvider FileSystem -Root $PSDrivePath -ErrorAction Stop | Out-Null
}

catch
{
	$errormessage = $_.Exception.Message
}

if ($errormessage)
{
	$Result = "Failed to create PS Drive."
    Write-Log "Failed to create PS Drive." -Severity 3
    End-Script -Result $Result
}

if(!(Test-Path x:\ ))
{
    $Result = "Test-path failed for $($PSDrivePath) - Mapped to 'X:\'"
    Write-Log "Test-path failed for $($PSDrivePath) - Mapped to 'X:\'" -Severity 3
    End-Script -Result $Result
}

Write-Log "New PS Drive Created Successfully" 

#######################################################################################
#Build the initial array of file objects

Write-Log "Building the array of source files." 

foreach ($File in $Sourcefiles)
{
	$objFileArray +=
	@([pscustomobject]@{
		FullPath = $File.fullname; 														#The current full path of the file. IE - \\HQFS\Marketing\Art\email-signatures\PCarrasco\Inc5000.htm
		NewPath = $File.FullName.replace($SourceFolderPath, $DestinationFolderPath)		#The full path we want to transfer that file to. IE - x:PCarrasco\Inc5000.htm
		Extension = $File.extension;													#.htm, .exe etc
		Name = $File.name;																#The file name with no path. IE - Inc5000.htm
		MD5 = Create-MD5Hash $File;														#The Generated MD5. If it is a folder it will just say 'Folder'
		Copied = 'No';																	#The property we use to identify if a file has been marked as copied over yet.
	})
}

Write-Log "Array building complete." 

$TotalSourceFiles = ($objFileArray | Where-Object { $_.extension -ne '' } | Measure-Object).count
$TotalSourceFolders = ($objFileArray | Where-Object { $_.extension -eq '' } | Measure-Object).count

Write-Log "Total Number of files detected at Source:	 $($TotalSourceFiles)" 
Write-Log "Total Number of folders detected at Source:	 $($TotalSourceFolders)" 

#######################################################################################
#Handle Folders First

Write-Log "Beginning to check and copy folder structure." 

Foreach ($Item in $objFileArray)
{
	If ($Item.extension -eq '')
	{
		$Item = Copy-Folder $Item
	}
	
}

Write-Log "Completed Copying folder structure." 

#######################################################################################
#Handle Files second

Write-Log "Beginning to check and copy files." 

Foreach ($Item in $objFileArray)
{
	If ($Item.extension -ne '')
	{
		$Item = Copy-File $Item
	}
	
}

Write-Log "Completed Copying files." 

#######################################################################################
#Check for errors 

Write-Log "Verifying folder structure." 

Foreach ($Item in $objFileArray)
{
	If ($Item.extension -eq '' -and $Item.copied -eq "Failed")
	{
		Write-Log "[FAILED FOLDER] $($Item.fullpath)" -Severity 2
		[Int]$FailedFolders++
	}
	
	If ($Item.extension -ne '' -and $Item.copied -eq "Failed")
	{
		Write-Log "[FAILED File] $($Item.fullpath)" -Severity 2
		[Int]$FailedFiles++
	}
	
}

If ([Int]$FailedFolders -eq 0)
{
	Write-Log "[SUCCESS 1/2]All Folders were copied successfully" 
}

Else
{
    Write-Log "Some folders failed to copy successfully!!" -Severity 3
    $Result = "Some folders failed to copy successfully!!"
    End-Script -Result $Result
}

If ([Int]$FailedFiles -eq 0)
{
	Write-Log "[SUCCESS 2/2]All Files were copied successfully" 
}

Else
{
    Write-Log "Some files failed to copy successfully!!" -Severity 3
    $Result = "Some files failed to copy successfully!!"
    End-Script -Result $Result
}

#######################################################################################
#Build Destination File array.

Write-Log "Building an array of destination file objects." 

$DestinationFiles = Get-ChildItem $DestinationFolderPath -recurse

foreach ($File in $DestinationFiles)
{
	$objDestinationFileArray +=
	@([pscustomobject]@{
		FullPath = $File.fullname;												#The current full path of the file. IE - \\172.17.1.11\LTShare\Transfer\Signatures\MDuren\LabTech.htm
		CheckPath = $File.FullName.replace($PSDrivePath, $SourceFolderPath)		#The full path of the file IF it exists in the marketing share. IE - \\HQFS\Marketing\Art\email-signatures\MDuren\LabTech.htm
		Extension = $File.extension;											#.htm, .exe etc
		Name = $File.name;														#The file name with no path. IE - Labtech.htm
		Validated = 'No';														#Whether or not the file has been validated to exist in the source directory as well.
	})
}

Write-Log "Completed the array of destination file objects." 

#######################################################################################
#File verification

Write-Log "Beginning to verify all files in destination directory should be there." 

Write-Log "*****************************"
Write-Log "*Begin List of Removed Files*"
Write-Log "*****************************"

Foreach ($Item in $objDestinationFileArray)
{
	If ($Item.extension -ne '')
	{
		$Item = Remove-File $Item
	}
}

Write-Log "*****************************"
Write-Log "**End List of Removed Files**"
Write-Log "*****************************"

$TotalDestinationFiles = ($objDestinationFileArray | Where-Object { $_.extension -ne '' } | Measure-Object).count
$VerifiedFiles = ($objDestinationFileArray | Where-Object { $_.validated -eq 'Yes' } | Measure-Object).count
$UnVerifiedFiles = ($objDestinationFileArray | Where-Object { $_.validated -eq 'No' -and $_.extension -ne '' } | Measure-Object).count
$RemovedFiles = ($objDestinationFileArray | Where-Object { $_.validated -eq 'Removed' } | Measure-Object).count

Write-Log "Completed Verifying Files." 
Write-Log "Total Number of files detected at destination: $($TotalDestinationFiles)"
Write-Log "Verified Files	: $($VerifiedFiles)"
Write-Log "UnVerified Files: $($UnVerifiedFiles)"
Write-Log "Removed Files	: $($RemovedFiles)"

#######################################################################################
#Folder Verification

Write-Log "Beginning to verify all folders in destination directory should be there." 

Write-Log "******************************"
Write-Log "*Begin List of Removed Folders*"
Write-Log "******************************"

Foreach ($Item in $objDestinationFileArray)
{
	If ($Item.extension -eq '')
	{
		$Item = Remove-Folder $Item
	}
}

Write-Log "******************************"
Write-Log "**END List of Removed Folders**"
Write-Log "******************************"

$TotalDestinationFolders = ($objDestinationFileArray | Where-Object { $_.extension -eq '' } | Measure-Object).count
$VerifiedFolders = ($objDestinationFileArray | Where-Object { $_.validated -eq 'Yes' -and $_.extension -eq '' } | Measure-Object).count
$UnVerifiedFolders = ($objDestinationFileArray | Where-Object { $_.validated -eq 'No' -and $_.extension -eq '' } | Measure-Object).count
$RemovedFolders = ($objDestinationFileArray | Where-Object { $_.validated -eq 'Removed' -and $_.extension -eq '' } | Measure-Object).count

Write-Log "Completed Verifying Folders." 
Write-Log "Total Number of folders detected at destination: $($TotalDestinationFolders)"
Write-Log "Verified Folders:	$VerifiedFolders"
Write-Log "UnVerified Folders:	$UnVerifiedFolders"
Write-Log "Removed Folders:	$RemovedFolders"


#######################################################################################
#Return Results

    $Result = 'SUCCESS'
    Write-Log "No failed folders or files. Script was a success." 
    End-Script -Result $Result

