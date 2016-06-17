Function Write-Log
{
	<#
	.SYNOPSIS
		A function to write ouput messages to a logfile.
	
	.DESCRIPTION
		This function is designed to send timestamped messages to a logfile of your choosing.
		Use it to replace something like write-host for a more long term log.
	
	.PARAMETER Message
		The message being written to the log file.
	
	.EXAMPLE
		PS C:\> Write-Log -Message 'This is the message being written out to the log.' 
	
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

Function Zip-Actions
{
       
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
       
       write-log "Entering Zip-Actions Function."
       
       switch ($PsCmdlet.ParameterSetName)
       {
              'Zip' {
                     
                     If ([int]$psversiontable.psversion.Major -lt 3)
                     {
                           write-log "Step 1"
                           New-Item $ZipPath -ItemType file
                           $shellApplication = new-object -com shell.application
                           $zipPackage = $shellApplication.NameSpace($ZipPath)
                           $files = Get-ChildItem -Path $FolderPath -Recurse
                           write-log "Step 2"
                           foreach ($file in $files)
                           {
                                  $zipPackage.CopyHere($file.FullName)
                                  Start-sleep -milliseconds 500
                           }
                           
                           write-log "Exiting Zip-Actions Function."
                           break           
                     }
                     
                     Else
                     {
                           write-log "Step 3"
                           Add-Type -assembly "system.io.compression.filesystem"
                           $Compression = [System.IO.Compression.CompressionLevel]::Optimal
                           [io.compression.zipfile]::CreateFromDirectory($FolderPath, $ZipPath, $Compression, $True)
                           write-log "Exiting Zip-Actions Function."
                           break
                     }
              }
              
              'Unzip' {

			    $shellApplication = new-object -com shell.application
			    $zipPackage = $shellApplication.NameSpace($ZipPath)
			    $destinationFolder = $shellApplication.NameSpace($FolderPath)
			    $destinationFolder.CopyHere($zipPackage.Items(), 20)
                write-log "Exiting Unzip Section"
				
                        }
       }
       
}

$LogFilePath = "$Env:windir\temp\script.txt"

#Do Windows Patching
######################################

Write-Log "***Windows Patching BEGINS***"
Write-Log "#############################"

$Source = ‘https://s3.amazonaws.com/ltpremium/modules/PSWindowsUpdate.zip’
$Destination = “$env:temp\PSWindowsUpdate.zip”
$UnzipPath = "$env:windir\System32\WindowsPowerShell\v1.0\Modules\"

Write-Log "Downloading Windows Update PowerShell Module"

Invoke-WebRequest -Uri $Source -OutFile $Destination
Unblock-File $Destination

Write-Log "Unzipping Windows Update PowerShell Module"

Zip-Actions -ZipPath $Destination -FolderPath $UnzipPath -Unzip $true -DeleteZip $true | Out-Null;

Write-Log "Importing Windows Update PowerShell Module"

Import-Module PSWindowsUpdate

Write-Log "Enabling the Windows Update Service"

Set-Service 'wuauserv' -StartupType Manual
Start-Service -Name 'wuauserv'

Write-Log "Installing Updates"

$PatchingProcess = Get-WUInstall -MicrosoftUpdate -IgnoreUserInput -AcceptAll -IgnoreReboot

If($PatchingProcess)
{
    Write-log "$($PatchingProcess | FT | Out-String)"
}

Else
{
    Return "No Patches Needed."
}

Return "Windows Patching Complete!"

