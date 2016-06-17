<#######################################################################################>
#Function Declarations

Function Process-LocalFile
{
	<#
	.SYNOPSIS
		A function to process a local file into an object.
	
	.DESCRIPTION
		This function takes a file object and creates a new object we use to compare 
        with items in the s3 bucket.
	
	.PARAMETER File
		The file object we are converting.
	
	.EXAMPLE
		PS C:\> Process-LocalFile -File $File
	
	.NOTES
		N/A
    #>

	Param
	(
		[Parameter(Mandatory = $True, Position = 0)]
		[Object]$File
	)

    $Array = $File.fullname.split("\")
    $Garbage = $Array[$Array.count- 1]
    $split = $File.fullname -replace $Garbage
    $Split = $Split -split "$($localroot.Replace("\","\\"))"
    $BucketFolder = $($split[1]).Trimend('\')
    $InvalPath = ([regex]::matches($BucketFolder, "([^\\]+$)")).groups[1].value

    $FunctionObj +=
    @([pscustomobject]@{
	    FullPath = $File.FullName
        BucketFolderPath = $BucketFolder
        BucketInvalPath = $InvalPath
	    FileName = $File.name
        Folder = $Item.psiscontainer
        New = $False
        Verified = $False
        InvalidationID = ''
     })
     
     Return $FunctionOBJ 
}

Function Process-LocalFolder
{
	<#
	.SYNOPSIS
		A function to process a local folder into an object.
	
	.DESCRIPTION
		This function takes a folder object and creates a new object we use to compare 
        with items in the s3 bucket.
	
	.PARAMETER Folder
		The folder object we are converting.
	
	.EXAMPLE
		PS C:\> Process-LocalFolder -Folder $Folder
	
	.NOTES
		N/A
    #>

	Param
	(
		[Parameter(Mandatory = $True, Position = 0)]
		[Object]$Folder
	)
    
    $BucketFolder = ($Folder.FullName -split "$($localroot.Replace("\","\\"))")
    $BucketFolder = $($BucketFolder[1]).trimend('\')
    $InvalPath = ([regex]::matches($BucketFolder, "([^\\]+$)")).groups[1].value

    $FunctionObj +=
    @([pscustomobject]@{
	    FullPath = $Folder.FullName
        BucketFolderPath = $BucketFolder
        BucketInvalPath = $InvalPath
	    FileName = 'N/A'
        Folder = $True
        New = $False
        Verified = $False
     }) 
          
     Return $FunctionOBJ 
}

Function Process-S3Folder
{
	Param
	(
		[Parameter(Mandatory = $True, Position = 0)]
		[Object]$S3Folder
	)

    $Split = $S3Folder.key.split("/")
    $SplitNum = [int]($split.count) - 2
    $BucketFolder = $Split[$SplitNum]

        $FunctionObj +=
    @([pscustomobject]@{
	    BucketFolder = $BucketFolder
        Etag = $S3Folder.etag
        LastModDate = $S3Folder.LastModified
	    FileName = 'N/A'
        Folder = $True
     }) 

    Return $FunctionOBJ 
}

Function Process-S3File
{
	Param
	(
		[Parameter(Mandatory = $True, Position = 0)]
		[Object]$S3File
	)

    $Split = $S3File.key.split("/")
    $FolderNum = [int]($split.count) - 2
    $FileNum = [int]($split.count) - 1
    $BucketFolder = $Split[$FolderNum]
    $BucketFileName = $Split[$FileNum]

        $FunctionObj +=
    @([pscustomobject]@{
	    BucketFolder = $BucketFolder
        Etag = $S3Folder.etag
        LastModDate = $S3File.LastModified
	    FileName = $BucketFileName
        Folder = $False
     }) 

    Return $FunctionOBJ 
}


<#######################################################################################>
#Variable Declarations

Import-Module “C:\Program Files (x86)\AWS Tools\PowerShell\AWSPowerShell\AWSPowerShell.psd1”
Set-AWSCredentials -AccessKey AKIAJFA6CWXDPUFA42MQ -SecretKey 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
Set-DefaultAWSRegion us-east-1
[Array]$Invalidations = @()
[Array]$LocalItems = @()
[Array]$S3Items = @()
[String]$Bucket = 'labtech-msp'
[String]$DistributionID = 'E39T58PANF3BWW'
[String]$LocalRooT = $env:CloudfrontScriptPath
$BucketFileList = Get-S3Object -BucketName $Bucket
$LocalFileList = Get-ChildItem $LocalRooT -Recurse


If($env:cloudfrontscriptpath -eq $null)
{
    Write-Output "!!!!NO ENVIRONMENTAL VARIABLE SET!!!!";
    exit;
}

<#######################################################################################>
#Process all items on the local machine

Foreach($Item in $LocalFileList)
{

    If($Item.psiscontainer -eq $true)
    {
        $LocalFolder = Process-LocalFolder -Folder $Item
        $LocalItems += $LocalFolder
    }

    Else
    {
        $LocalFile = Process-LocalFile -File $Item
        $LocalItems += $LocalFile
    }

}

<#######################################################################################>
#Process all items that exist in the S3 Bucket

Foreach($Item in $BucketFileList)
{
    $FolderCheck = $($Item.key).substring($($Item.key).length - 1, 1)
    If($FolderCheck -eq '/')
    {
        $S3Folder =  Process-S3Folder -S3Folder $Item
        $S3Items += $S3Folder

    }

    Else
    {
        $S3File =  Process-S3File -S3File $Item
        $S3Items += $S3File
    }

}

<#######################################################################################>
#Verify that all local folders exist in the bucket. If they don't we create them.

Foreach($Item in $LocalItems)
{
    #Determine the object is a folder...
    If($Item.Folder -eq $True)
    {
        #Determine if the folder already exists in the bucket...
        If($S3Items | Where-Object {$_.BucketFolder -eq "$($Item.BucketInvalPath)" -and $_.Folder -eq $True})
        {
            #If it already exists, set the 'Verified' property to $True...
            $Item.verified = $True
        } 
        
        #If the folder does not already exist we need to create it. 
        Else
        {
           #Set the 'new' property on the item to $True
           $Item.new = $True
           #Create the folder in the proper path in the bucket in S3 and capture any errors in $CreateError
           $Result = Write-S3Object -BucketName $Bucket -Key $($Item.bucketfolderpath + '/') -Content "Dummy Content" -ErrorVariable $CreateError
           
           #If there were no errors. We set the 'verified' property to true.
           If(-not $CreateError) {$Item.verified = $True}

           #If there were errors. We set the 'verified' property equal to the error.
           Else {$Item.verified = $CreateError}
        }
    }

    #Else the object is a file.
    Else
    {
        #If the file currently exists in the same directory in S3......
        If($S3Items | Where-Object {$_.BucketFolder -eq "$($Item.Bucketinvalpath)" -and $_.Filename -eq $($Item.Filename)})
        {
            #Create a new random guid to use to identify the invalidation.
            $Guid = [guid]::NewGuid()
            #Create a variable to use for the full S3 path for the file we want to invalidate.
            $PathsItem = ('/' + $($Item.BucketInvalPath) + '/' + $($item.FileName))

            #Perform the invalidation on the file that is currently there.
            Try
            {
                $invalidation = new-cfinvalidation -DistributionId $DistributionID -Paths_Item $PathsItem -force -InvalidationBatch_CallerReference $Guid -Paths_Quantity 1
            }

            Catch
            {
                $Exceptionmessage = $_.exception.message
            }

            Finally
            {
                #If there were no errors. We set the 'verified' property to true.
                If(-not $Exceptionmessage) {$Item.verified = $True}
                #If there were errors. We set the 'verified' property equal to the error.
                Else {$Item.verified = $Exceptionmessage}
                $item.InvalidationID = $invalidation.Invalidation.Id
            }

            #Upload the new file overtop of the old one.
            Write-S3Object -BucketName $Bucket -Key $($Item.bucketfolderpath + '/' + $Item.Filename) -File $Item.FullPath -ErrorVariable $CreateError
           
            #If no upload errors occured, and the invalidation for that object is 'InProgress'.... 
            If(-not $CreateError -and $invalidation.Invalidation.Status -eq 'InProgress')
            {
                #The item is verified.
                $Item.verified = $True
            }

            #If something went wrong...
            Else
            {
                #Set the verified property to a concat of all the possible error information.
                $item.verified = $($invalidation.Invalidation.Status) + '|' + $CreateError
            }

            #Add the information for the invalidations to the array.
            $Invalidations += $invalidation

        }  

        #If its a new file that isnt already in S3...
        Else
        {
            #Set the 'new' property to True    
            $Item.new = $True
            #Upload the new file.
            Write-S3Object -BucketName $Bucket -Key $($Item.bucketfolderpath + '/' + $Item.Filename) -File $Item.FullPath -ErrorVariable $CreateError -PublicReadOnly

            #If no upload errors occured,
            If(-not $CreateError)
            {
                #The item is verified.
                $Item.verified = $True

            }

            #If something went wrong...
            Else
            {
                #Set the verified property to the upload error.
                $Item.Verified = $CreateError
            }
        }
    }

}

<#######################################################################################>
#Report on Results

$Localitems | Select FullPath,FileName,New,Verified,InvalidationID | Out-GridView -Title 'Cloudfront Upload and Invalidation Results'

[Array]$body = @()

$Body += @"
<!DOCTYPE html>
<html>
<head>
<style>
table, th, td {
    border: 1px solid black;
    border-collapse: collapse;
}
th, td {
    padding: 5px;
}
th {
    text-align: left;
}
</style>
</head>
<body>

<p>Below are the results from the Automated Process ran $(Get-Date -Format g)<br></p>
<p><b>Fullpath</b> shows the complete path the file or folder came from on the local machine.<br>
<b>Filename</b> shows the filename only with the path stripped.<br>
<b>New Item</b> will show True if the file or folder did not previously exist in the bucket.<br>
<b>Successfully Uploaded</b> will show true or false.<br>
If the item already existed we performed an invalidation on the old item. The invalidation ID is here for your reference.<br>
A quick link to your CloudFront Distribution is <a href="https://console.aws.amazon.com/cloudfront/home?region=us-east-1#distribution-settings:E39T58PANF3BWW">here</a></p>

<table style="width:100%">
<caption>CloudFront Uploads and Invalidations</caption>
  <tr>
    <th>Fullpath</th>
    <th>FileName</th> 
    <th>New Item</th>
    <th>Successfully Uploaded</th>
    <th>InvalidationID</th>
  </tr>
"@

Foreach($Item in $LocalItems)
{
    $Body += @"
<tr>
    <td>$($Item.fullpath)</td>
    <td>$($Item.filename)</td> 
    <td>$($Item.new)</td>
    <td>$($Item.verified)</td>
    <td>$($Item.invalidationID)</td>
</tr>
"@
    
}

$Body+= @"
</table>
<p>If there are any problems, click below to send me an email.<br></p>
<a href="mailto:pmarshall@labtechsoftware.com">
<img src="https://s3.amazonaws.com/ltpremium/Phillip/EmailButton.png" alt="Click to email me" height="100" width="100" /></a>
</body>
</html>
"@

[STRING]$StringBody = $Body

$EmailParams = @{
To = "dyates@labtechsoftware.com"
From = "cloud@labtechsoftware.com"
Subject = "CloudFront Upload/Invalidation Report $(Get-Date -Format g)"
SMTPServer = "mailserver1.hostedrmm.com"
Port = '25'
Body = $StringBody
}

Send-MailMessage @EmailParams -BodyAsHtml