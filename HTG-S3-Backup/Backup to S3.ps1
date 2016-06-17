####################################################################
#Variable Declarations

    #S3Copy Vars
    [String]$ScriptLog = "$Env:windir\temp\S3Backuplog.txt"
    [String]$S3CopyLink = "http://s3.amazonaws.com/ltpremium/tools/s3copy/s3copy.exe"
    [String]$S3CopyDownloadPath = "$Env:windir\temp\S3copy.exe"
    [String]$Bucketname = 'partner_backups'

    #Supplied By LabTech
    [String]$LTBackupBaseLocation = "@LTPath@\Backup\LabTech.1.zip"
    [String]$LTBackupTempLocation = "@BackupFilePath@"
    [String]$LTBackupFileName = "@BackupFileName@"
    [String]$AccessKey = "@AccessKey@"
    [String]$SecretKey = "@SecretKey@"

####################################################################
#Download S3Copy.exe

Write-Output "Starting Download Job for S3Copy.exe"

#Declare the Job
$S3CopyDownloadJob = Start-BitsTransfer `
    -Source $S3CopyLink `
    -Destination $S3CopyDownloadPath `
    -Asynchronous

#Make sure the transfer has completed. 
while (($S3CopyDownloadJob.JobState -eq "Transferring") -or ($S3CopyDownloadJob.JobState -eq "Connecting"))
{ 
    sleep 3;
}

Write-Output "Download Job finished. Checking status."

#Check the staus of the jobs completion. 
Switch($S3CopyDownloadJob.JobState)
{
       "Transferred" {Complete-BitsTransfer -BitsJob $S3CopyDownloadJob; Write-Output "S3Copy.exe has successfully downloaded.";}
       "Error"       {Write-Output "Failed to download S3Copy.exe. Error was : $($S3CopyDownloadJob.ErrorDescription)"; exit; }
       default       {Write-Output "Something went wrong with the download of S3Copy..."}
}


####################################################################
#Copy backup file to a temp directory

$copyResults = Copy-Item `
    -Path $LTBackupBaseLocation `
    -Destination "$LTBackupTempLocation$LTBackupFileName" `
    -Force

#Add a test path for Detination here

####################################################################
#Upload the Backup Using S3Copy

$AllArgs = "$LTBackupTempLocation $BucketName $LTBackupFileName $AccessKey $SecretKey"

Start-Process `
    -FilePath $S3CopyDownloadPath `
    -ArgumentList $AllArgs `
    -RedirectStandardOutput $ScriptLog `
    -PassThru `
    -Wait
    #-WindowStyle Hidden