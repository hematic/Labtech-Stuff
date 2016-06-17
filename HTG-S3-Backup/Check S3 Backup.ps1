[String]$Bucketname = 'partner_backups'
[String]$LTBackupFileName = "@BackupFileName@" -replace " ","_"

Import-Module "C:\Program Files (x86)\AWS Tools\PowerShell\AWSPowerShell\AWSPowerShell.psd1"
Set-AWSCredentials -AccessKey "@AccessKey@" -SecretKey "@SecretKey@"
Set-DefaultAWSRegion us-east-1

$FileInfo = get-s3object -BucketName $Bucketname -key $LTBackupFileName

If(!$FileInfo.etag)
{
    Return "File Missing From S3"
    exit;
}

$LastModified = get-date ($FileInfo.LastModified)
$Today = get-date

If($LastModified.date -eq $Today.Date)
{
    Return "File Uploaded Successfully!"
    exit;
}

Else
{
    Return "Backup Failed"
    exit;
}