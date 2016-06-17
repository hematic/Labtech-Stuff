<# Function declarations #>

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

function global:wh {
	[CmdletBinding()]
	param(
	[Parameter(Mandatory=$False,ValueFromPipeline=$True)] [string]$MyInput,
	[Parameter(Mandatory=$True,ValueFromPipeline=$True)] [int]$Color,
	[Parameter(Mandatory=$True,ValueFromPipeline=$True)] [int]$NewLine)
		<# 1 for red, 2 for green, anything else is white #>
		
	Begin {
	switch ($color) {
				1 { [string]$color = 'red' }
				2 { [string]$color = 'green' }
				default { [string]$color = 'white' }
				}
if($MyInput -eq $Null) {$MyInput=""}
If($newLine -eq 0) {
			write-host "$MyInput" -fore $color;
			$MyStream.WriteLine($MyInput)
						}
if($newLine -eq 1) {
			write-host "$MyInput" -fore $color -NoNewLine;
			$MyStream.Write($MyInput)
						}
}
	Process{}
	end{}

}

function DBSizeCheckMsg {
	if ($args[0] -eq 0) 
	{
		wh "LabTech Database Size Check: .................. " -Color 3 -NewLine 1;
		wh "FAIL !!!" -Color 1 -NewLine 0;
	} 
	elseif ($args[0] -eq 1) 
	{
		wh "LabTech Database Size Check: .................. " -Color 3 -NewLine 1;
		wh "PASS" -Color 2 -NewLine 0; 
	}
}

function WritePassRAM {

	wh "RAM Total Meets Agent Count Recommendations: .. " -Color 3 -NewLine 1; 
	wh "PASS - $($args[0]) GB installed" -Color 2 -NewLine 0;
}
			
function WriteFailRAM {
	wh "RAM Total Meets Agent Count Recommendations: .. " -Color 3 -NewLine 1;
	wh "FAIL - Server only has $($mem) GB - Recommended is at LEAST $($args[1])GB !!!" -Color 1 -NewLine 0;
}

function WritePassInternet {

	wh "WAN Speed Meets Agent Count Recommendations: .. " -Color 3 -NewLine 1; 
	wh "PASS - $($args[0]) Mbit /sec" -Color 2 -NewLine 0;
}

function WriteFailInternet {

	wh "WAN Speed Does Not Meet Agent Count Recommendations: .. " -Color 3 -NewLine 1; 
	wh "FAIL - $($args[0]) Mbit /sec" -Color 2 -NewLine 0;
}

Function WritePassCPU {
	wh "CPU Count Meets Agent Count Recommendations: .. " -Color 3 -NewLine 1; 
	wh "PASS - $($args[0]) CPU(s) x $($args[1]) cores  installed"  -Color 2 -NewLine 0;
}
			
Function WriteFailCPU {
	wh "CPU Count Meets Agent Count Recommendations: .. " -Color 3 -NewLine 1;
	wh "FAIL - Server only has $($args[0]) CPU(s) x $($args[1]) core(s) installed!! " -Color 1 -NewLine 0;
}

Function CheckDiskCount {
	$NumberOfdisks = $args[0];

	<#Check Number of Disks #>
	if($NumberOfdisks -gt 1)
	{
		wh "Multiple Disk Drives Check: ................... " -Color 3 -NewLine 1;
		wh "PASS - $($NumberOfDisks) Installed"  -Color 2 -NewLine 0;
	}
	else
	{
		wh "Multiple Disk Drives Check: ................... " -Color 3 -NewLine 1;
		wh "NO - Does not mean a failure - Could be RAID Configuration !!!" -Color 1 -NewLine 0;
	}
}

function CheckTotalSpace
				{
	$ScalabilityBracket = $args[0];
	$TotalSpace = [math]::Round($args[1]/1kb,1);
	
	wh "Disk Space Meets Agent Count Recommendations: . " -Color 3 -NewLine 1; 
	
	<#Check Total Disk Space in respect to number of Agents#>
	switch($ScalabilityBracket)
	{
		1 { if($TotalSpace -ge 80) 
			{ 
			wh "PASS - $($TotalSpace)"  -Color 2 -NewLine 0;
			}
		else {
			wh "FAIL - Total Disk Space is only $($TotalSpace) GB !!!" -Color 1 -NewLine 0;
			}}
		2 { if($TotalSpace -ge 160)
			{ 
			wh "PASS - $TotalSpace"  -Color 2 -NewLine 0;
			}
		else {
			wh "FAIL - Total Disk Space is only $($TotalSpace) GB !!!" -Color 1 -NewLine 0;
			}}
		3 { if($TotalSpace -ge 160)
			{ 
			wh "PASS - $($TotalSpace)"  -Color 2 -NewLine 0;
			}
		else {
			wh "FAIL - Total Disk Space is only $($TotalSpace) GB !!!" -Color 1 -NewLine 0;
			}}
		4 { if($TotalSpace -ge 320) 
			{ 
			wh "PASS - $($TotalSpace)"  -Color 2 -NewLine 0;
			}
		else {
			wh "FAIL - Total Disk Space is only $($TotalSpace) GB !!!" -Color 1 -NewLine 0;
			}}
		5 { if($TotalSpace -ge 320) 
			{ 
			wh "PASS - $($TotalSpace)"  -Color 2 -NewLine 0;
			}
		else {
			wh "FAIL - Total Disk Space is only $($TotalSpace) GB !!!" -Color 1 -NewLine 0;
			}}
		6 { if($TotalSpace -ge 400) 
			{ 
			wh "PASS - $($TotalSpace)"  -Color 2 -NewLine 0;
			}
		else {
			wh "FAIL - Total Disk Space is only $($TotalSpace) GB !!!" -Color 1 -NewLine 0;
			}}
		}

}

Function downloadSpeed($strUploadUrl)
{
	$topServerUrlSpilt = $strUploadUrl -split 'upload'
	$url4000 = $topServerUrlSpilt[0] + 'random2000x2000.jpg'
	$col = new-object System.Collections.Specialized.NameValueCollection 
	$wc = new-object system.net.WebClient 
	$wc.QueryString = $col 
	$downloadElaspedTime = (measure-command {$webpage1 = $wc.DownloadData($url4000)}).totalmilliseconds
	$string = [System.Text.Encoding]::ASCII.GetString($webpage1)
	$downSize = ($webpage1.length + $webpage2.length) / 1Mb
	$downloadSize = [Math]::Round($downSize, 2)
	$downloadTimeSec = $downloadElaspedTime * 0.001
	$downSpeed = ($downloadSize / $downloadTimeSec) * 8
	$downloadSpeed = [Math]::Round($downSpeed, 2)
	return $downloadSpeed
}

<# -------------------------------------------------------------------------- #>

$Hostname = [System.Net.DNS]::Gethostname();

If( $Hostname.Length -gt 15 ) { $Hostname = $Hostname.Substring(0,15) }

if (test-path $env:windir/temp/$($hostname)-LTServerValidationResults.txtTEMP) {
	remove-item $env:windir/temp/$($hostname)-LTServerValidationResults.txtTEMP
}
if (test-path $env:windir/temp/$($hostname)-LTServerValidationResults.txt) {
	remove-item $env:windir/temp/$($hostname)-LTServerValidationResults.txt
}
$fp = "$env:windir/temp/$($hostname)-LTServerValidationResults.txtTEMP"
$MyStream = new-object System.IO.StreamWriter $fp

$StartTime=get-date;

wh -Myinput "" -Color 3 -NewLine 0;
wh -MyInput "             Last Ran: $($StartTime)  (Agent Time)     " -Color 2 -NewLine 0;
wh -MyInput "========================================================" -Color 3 -NewLine 0;
wh -MyInput "======== Server Validation Checklist ===================" -Color 3 -NewLine 0;
wh -MyInput "========================================================" -Color 3 -NewLine 0;
wh -MyInput "=============== Revision: MB 03.10.2015 ================" -Color 3 -NewLine 0;
wh -MyInput "========================================================" -Color 3 -NewLine 0;
wh -MyInput "" -Color 3 -NewLine 0;

wh -MyInput "========================================================" -Color 3 -NewLine 0;
wh -MyInput "======== Part 1 - Hardware Validation ==================" -Color 3 -NewLine 0;
wh -MyInput "========================================================" -Color 3 -NewLine 0;
wh -MyInput "" -Color 3 -NewLine 0;

<# Task - Virtual Machine Check - Should not be a VM #>

$systeminfo = systeminfo | findstr /i /c:"System Manufacturer" /c:"System Model"
if(($systeminfo -match 'Virtual') -OR ($systeminfo -match 'VMWare'))
	{
	wh "Check Host is not a Virtual Machine: .......... " -Color 3 -NewLine 1; 
	wh "FALSE" -Color 1 -NewLine 0;
	$VMCheck = $true
	}
	else 
	{
	wh "Check Host is not a Virtual Machine: .......... " -Color 3 -NewLine 1; 
	wh "TRUE"  -Color 2 -NewLine 0;
	$VMCheck = $false
	}

<# Task - Agent Count Match Recommended Server Req? #>

<# Task - Ram Total Meets Agent Count Recommendations #>


$ExistCheckSQLDir = CheckRegKeyExists HKLM:\Software\Wow6432Node\Labtech\Setup MySQLDir;
$ExistCheckRootPwd = CheckRegKeyExists HKLM:\Software\Wow6432Node\Labtech\Setup RootPassword;

if($ExistCheckSQLDir -eq $true)
{
	$SQLDir=(Get-ItemProperty HKLM:\Software\Wow6432Node\Labtech\Setup -name MySQLDir).MySQLDir;
}
elseif ($ExistsCheckSQLDir -eq $false)
{ 
	wh "Critical Error: Unable to Locate SQL Directory Registry key ( HKLM:\Software\Wow6432Node\LabTech\Setup.MySQLDir )" -Color 1 -newLine 1;
	exit;
}

if($ExistCheckRootPwd -eq $true)
{
	$RootPwd=(Get-ItemProperty HKLM:\Software\Wow6432Node\Labtech\Setup -name RootPassword).RootPassword;
} 
elseif ($LabTechDir -eq $false) 
{ 
	wh "Critical Error: Unable to Locate Root Password Registry key ( HKLM:\Software\Wow6432Node\LabTech\Setup.RootPassword )" -Color 1 -newLine 1;
	exit;
}

set-location $SQLDir\bin;
$NumberOfAgents = .\mysql.exe --user=root --password=$RootPwd -e "select count(*) from LabTech.Computers" --batch -N

$mem = get-wmiobject -Class Win32_ComputerSystem
$mem = [math]::round($mem.TotalPhysicalMemory/1gb,1)

IF ($VMCheck = $False)
{
	#Physical Server
	switch ([int]$NumberOfAgents)
	{
		{$_ -LE 2000}							{
					if($mem -ge 8) { WritePassRAM $mem; }
					else { WriteFailRAM $mem 8; }
					}
		{(($_ -GT 2000) -AND ($_ -LE 5000))} 	{ 
					if($mem -ge 16) { WritePassRAM $mem; }
					else { WriteFailRAM $mem 16; }
					}
		{(($_ -GT 5000) -AND ($_ -LE 10000))} 	{ 
					if($mem -ge 24) { WritePassRAM $mem; }
					else { WriteFailRAM $mem 24; }
					}
		{(($_ -GT 10000) -AND ($_ -LE 20000))}	{ 
					if($mem -ge 32) { WritePassRAM $mem; }		
					else { WriteFailRAM $mem 32; }					
					}
		{$_ -GT 20000}							{ 
					if($mem -ge 48) { WritePassRAM $mem; }		
					else { WriteFailRAM $mem 48; }					
					}
		default { wh "Failure to detect Memory information." }
	}
}

Else
{
	#Virtual Server
	switch ([int]$NumberOfAgents)
	{
		{$_ -LE 2000}							{
					if($mem -ge 6) { WritePassRAM $mem; }
					else { WriteFailRAM $mem 8; }
					}
		{(($_ -GT 2000) -AND ($_ -LE 5000))} 	{ 
					if($mem -ge 12) { WritePassRAM $mem; }
					else { WriteFailRAM $mem 16; }
					}
		{(($_ -GT 5000) -AND ($_ -LE 10000))} 	{ 
					if($mem -ge 20) { WritePassRAM $mem; }
					else { WriteFailRAM $mem 24; }
					}
		{(($_ -GT 10000) -AND ($_ -LE 20000))}	{ 
					if($mem -ge 30) { WritePassRAM $mem; }		
					else { WriteFailRAM $mem 32; }					
					}
		{$_ -GT 20000}							{ 
					if($mem -ge 46) { WritePassRAM $mem; }		
					else { WriteFailRAM $mem 48; }					
					}
		default { wh "Failure to detect Memory information." }
	}
}

<# -------------------------------------------------------------------------- #>

<# Task - Verify AVG RAM Usage below 50 #>



set-location $SQLDir\bin;
$MyQuery = .\mysql.exe --user=root --password=$RootPwd -e "
use Labtech;
SET @MaximumDate = DATE_ADD((select max(eventdate) 
							from h_ComputerStats 
							where ComputerID in (select computerID 
											from computers 
											where name='$Hostname')
							), INTERVAL -7 DAY);
SELECT AVG(Mem) `MemoryAvg`,
	AVG(CPU) `CPUAvg`
FROM H_Computerstats h
WHERE ComputerID IN (SELECT ComputerID 
			FROM computers 
			where name='$Hostname')
AND h.eventdate > @MaximumDate
GROUP BY ComputerID limit 0,1;" --batch -N

<#$myQuery.split()[0] mem#>
<#$myQuery.Split()[1] CPU#>

wh "RAM Usage Average Below 50%: .................. " -Color 3 -NewLine 1;

if(!$myquery)
{
	wh "FAIL - Unable to detect (Query returned NULL)"-Color 1 -NewLine 0;
} else {
if([math]::round($myQuery.split()[0],1) -gt 50) {
	wh "FAIL - Average Usage For Past 7 days = $([math]::round($myQuery.Split()[0],1))% !!!" -Color 1 -NewLine 0;
	}
ELSE {
	wh "PASS - Average Usage For Past 7 days = $([math]::round($myQuery.Split()[0],1))%"  -Color 2 -NewLine 0;
	} 
}
<# -------------------------------------------------------------------------- #>

<# Task - Verify AVG CPU Usage below 50 #>

wh "CPU Usage Average Below 50%: .................. " -Color 3 -NewLine 1;

if(!$myquery)
{
	wh "FAIL - Unable to detect (Query returned NULL)"-Color 1 -NewLine 0;
} else {
if([math]::round($myQuery.split()[1],1) -GT 50) {
	wh "FAIL - Average Usage For Past 7 days = $([math]::round($myQuery.Split()[1],1))% !!!" -Color 1 -NewLine 0;
	}
else {
	wh "PASS - Average Usage For Past 7 days = $([math]::round($myQuery.Split()[1],1))%"  -Color 2 -NewLine 0;
	} 
}

<# -------------------------------------------------------------------------- #>

<# Storage space, Total CPU and Multiple Drive checks #>
set-location $SQLDir\bin;
$Query = .\mysql.exe --user=root --password=$RootPwd -e "
use Labtech;
SELECT sum(coalesce(Cores,0)) LogicalCPU,
		count(*) CountPhysicalCPU,
		max(coalesce(k.free,0)) FreeSpace, 
		max(coalesce(k.size,0)) TotalCapacity, 
		max(coalesce(k.NumDisks,0)) NumberofDisks FROM inv_processor p JOIN computers c 
	on c.ComputerID=p.ComputerID AND 
		c.Name='$hostname'
left outer join (select sum(free) free,
			sum(size) size, 
			count(*) NumDisks,
			ComputerID from drives
			where FileSystem<>'CDFS' AND FileSystem<>'UKNFS' AND FileSystem<>'DVDFS' AND Missing=0 group by ComputerID) as K 
on k.ComputerID=c.ComputerID
group by p.ComputerID Limit 0,1;" --batch -N

<#$Query.split()[0]#>
<# [0] = Logical Cores #>
<# [1] = Physical CPU #>
<# [2] = Free Space #>
<# [3] = Total Capacity #>
<# [4] =  Number of Disks #>


if(!$query) {
 wh "Logical Cores, Physical CPUs, Free Disk Space, Total Disk Capacity & Number of Disks CANNOT be detected. Query returned (NULL)." -color 1 -NewLine 1;
} 
else {
	$PhysicalCPUs = (gwmi -class win32_processor | measure).count
	$LogicalCores = Get-WmiObject -class win32_processor | select-object -expand NumberOfCores  -first 1;
	$TotalLogicalCores = (Get-WmiObject -class win32_processor | measure-object NumberOfCores -sum).Sum;
	$FreeDiskSpace = $Query.Split()[2]
	$TotalDiskCapacity = $Query.Split()[3]
	$NumberOfDisks = $Query.Split()[4]
	
}
IF($VMCheck -eq $False )
{

    switch ([int]$NumberOfAgents) 
    {
        {$_ -LE 2000}							
                {
                <#Check Physical CPUs and Cores#>
					if(($PhysicalCPUs -ge 1) -AND ($TotalLogicalCores -ge 4)) { WritePassCPU $PhysicalCPUs $LogicalCores; }
					else { WriteFailCPU $PhysicalCPUs $LogicalCores }

				<#Check Number of Disks #>
					CheckDiskCount $NumberOfDisks;
				<#Check Free Space #>
					$ScalabilityBracket = 1;
					CheckTotalSpace 1 $TotalDiskCapacity
			    }
     
	    {(($_ -GT 2000) -AND ($_ -LE 5000))}	 
				{ 
				<#Check Physical CPUs and Cores#>
					if(($PhysicalCPUs -ge 1) -AND ($TotalLogicalCores -ge 4)) { WritePassCPU $PhysicalCPUs $LogicalCores; }
					else { WriteFailCPU $PhysicalCPUs $LogicalCores}

				<#Check Number of Disks #>
					CheckDiskCount $NumberOfDisks;
				<#Check Free Space #>
					$ScalabilityBracket = 2;
					CheckTotalSpace 2 $TotalDiskCapacity
			    }

	    {(($_ -GT 5000) -AND ($_ -LE 10000))}	
				{ 
				<#Check Physical CPUs and Cores#>
					if(($PhysicalCPUs -ge 1) -AND ($TotalLogicalCores -ge 8)) { WritePassCPU $PhysicalCPUs $LogicalCores; }
					else { WriteFailCPU $PhysicalCPUs $LogicalCores}
			
				<#Check Number of Disks #>
					CheckDiskCount $NumberOfDisks;
				<#Check Free Space #>
					$ScalabilityBracket = 3;
					CheckTotalSpace 3 $TotalDiskCapacity
				}

	    {(($_ -GT 10000) -AND ($_ -LE 20000))}
				{ 
				<#Check Physical CPUs and Cores#>
					if(($PhysicalCPUs -ge 2) -AND ($TotalLogicalCores -ge 8)) { WritePassCPU $PhysicalCPUs $LogicalCores; }
					else { WriteFailCPU $PhysicalCPUs $LogicalCores}

				<#Check Number of Disks #>
					CheckDiskCount $NumberOfDisks;
				<#Check Free Space #>
					$ScalabilityBracket = 4;
					CheckTotalSpace 4 $TotalDiskCapacity
				}

	    {$_ -GT 20000}  
				{ 
				<#Check Physical CPUs and Cores#>
					if(($PhysicalCPUs -ge 2) -AND ($TotalLogicalCores -ge 8))  { WritePassCPU $PhysicalCPUs $LogicalCores; }		
					else { WriteFailCPU $PhysicalCPUs $LogicalCores}	

				<#Check Number of Disks #>
					CheckDiskCount $NumberOfDisks;
				<#Check Free Space #>
					$ScalabilityBracket = 6;
					CheckTotalSpace 6 $TotalDiskCapacity
				 }

        default {wh "Failure to detect CPU specifications."}
    }
}

Else
{

    switch ([int]$NumberOfAgents) 
    {
        {$_ -LE 2000}							
                {
                <#Check Physical CPUs and Cores#>
					if(($PhysicalCPUs -ge 1) -AND ($TotalLogicalCores -ge 4)) { WritePassCPU $PhysicalCPUs $LogicalCores; }
					else { WriteFailCPU $PhysicalCPUs $LogicalCores }

				<#Check Number of Disks #>
					CheckDiskCount $NumberOfDisks;
				<#Check Free Space #>
					$ScalabilityBracket = 1;
					CheckTotalSpace 1 $TotalDiskCapacity
			    }
     
	    {(($_ -GT 2000) -AND ($_ -LE 5000))}	 
				{ 
				<#Check Physical CPUs and Cores#>
					if(($PhysicalCPUs -ge 1) -AND ($TotalLogicalCores -ge 4)) { WritePassCPU $PhysicalCPUs $LogicalCores; }
					else { WriteFailCPU $PhysicalCPUs $LogicalCores}

				<#Check Number of Disks #>
					CheckDiskCount $NumberOfDisks;
				<#Check Free Space #>
					$ScalabilityBracket = 2;
					CheckTotalSpace 2 $TotalDiskCapacity
			    }

	    {(($_ -GT 5000) -AND ($_ -LE 10000))}	
				{ 
				<#Check Physical CPUs and Cores#>
					if(($PhysicalCPUs -ge 1) -AND ($TotalLogicalCores -ge 8)) { WritePassCPU $PhysicalCPUs $LogicalCores; }
					else { WriteFailCPU $PhysicalCPUs $LogicalCores}
			
				<#Check Number of Disks #>
					CheckDiskCount $NumberOfDisks;
				<#Check Free Space #>
					$ScalabilityBracket = 3;
					CheckTotalSpace 3 $TotalDiskCapacity
				}

	    {(($_ -GT 10000) -AND ($_ -LE 20000))}
				{ 
				<#Check Physical CPUs and Cores#>
					if(($PhysicalCPUs -ge 2) -AND ($TotalLogicalCores -ge 8)) { WritePassCPU $PhysicalCPUs $LogicalCores; }
					else { WriteFailCPU $PhysicalCPUs $LogicalCores}

				<#Check Number of Disks #>
					CheckDiskCount $NumberOfDisks;
				<#Check Free Space #>
					$ScalabilityBracket = 4;
					CheckTotalSpace 4 $TotalDiskCapacity
				}

	    {$_ -GT 20000}  
				{ 
				<#Check Physical CPUs and Cores#>
					if(($PhysicalCPUs -ge 2) -AND ($TotalLogicalCores -ge 8))  { WritePassCPU $PhysicalCPUs $LogicalCores; }		
					else { WriteFailCPU $PhysicalCPUs $LogicalCores}	

				<#Check Number of Disks #>
					CheckDiskCount $NumberOfDisks;
				<#Check Free Space #>
					$ScalabilityBracket = 6;
					CheckTotalSpace 6 $TotalDiskCapacity
				 }

        default {wh "Failure to detect CPU specifications."}
    }
}

<# -------------------------------------------------------------------------- #>

<# Task - Internet Speed Meets Agent Count Recommendations #>


<#
Using this method to make the submission to speedtest. Its the only way i could figure out how to interact with the page since there is no API.
More information for later here: https://support.microsoft.com/en-us/kb/290591
#>
$objXmlHttp = New-Object -ComObject MSXML2.ServerXMLHTTP
$objXmlHttp.Open("GET", "http://www.speedtest.net/speedtest-config.php", $False)
$objXmlHttp.Send()

#Retrieving the content of the response.
[xml]$content = $objXmlHttp.responseText

<#
Gives me the Latitude and Longitude so i can pick the closer server to me to actually test against. It doesnt seem to automatically do this.
Lat and Longitude for tampa at my house are $orilat = 27.9238 and $orilon = -82.3505
This is corroborated against: http://www.travelmath.com/cities/Tampa,+FL - It checks out.
#>
$oriLat = $content.settings.client.lat
$oriLon = $content.settings.client.lon

#Making another request. This time to get the server list from the site.
$objXmlHttp1 = New-Object -ComObject MSXML2.ServerXMLHTTP
$objXmlHttp1.Open("GET", "http://www.speedtest.net/speedtest-servers.php", $False)
$objXmlHttp1.Send()

#Retrieving the content of the response.
[xml]$ServerList = $objXmlHttp1.responseText

<#
$Cons contains all of the information about every server in the speedtest.net database. 
I was going to filter this to US servers only which would speed this up a lot but i know we have overseas partners we run this against. 
Results returned look like this for each individual server:

url     : http://speedtestnet.rapidsys.com/speedtest/upload.php
lat     : 27.9709
lon     : -82.4646
name    : Tampa, FL
country : United States
cc      : US
sponsor : Rapid Systems
id      : 1296

#>
$cons = $ServerList.settings.servers.server 
 
#Below we calculate servers relative closeness to you by doing some math against latitude and longitude. 
foreach($val in $cons) 
{ 
	$R = 6371;
	[float]$dlat = ([float]$oriLat - [float]$val.lat) * 3.14 / 180;
	[float]$dlon = ([float]$oriLon - [float]$val.lon) * 3.14 / 180;
	[float]$a = [math]::Sin([float]$dLat/2) * [math]::Sin([float]$dLat/2) + [math]::Cos([float]$oriLat * 3.14 / 180 ) * [math]::Cos([float]$val.lat * 3.14 / 180 ) * [math]::Sin([float]$dLon/2) * [math]::Sin([float]$dLon/2);
	[float]$c = 2 * [math]::Atan2([math]::Sqrt([float]$a ), [math]::Sqrt(1 - [float]$a));
	[float]$d = [float]$R * [float]$c;
	
	$ServerInformation +=
@([pscustomobject]@{Distance = $d; Country = $val.country; Sponsor = $val.sponsor; Url = $val.url })

}

$serverinformation = $serverinformation | Sort-Object -Property distance

#Runs the functions and returns the data we want.
$DLResults1 = downloadSpeed($serverinformation[0].url)
$SpeedResults += @([pscustomobject]@{Speed = $DLResults1;})

$DLResults2 = downloadSpeed($serverinformation[1].url)
$SpeedResults += @([pscustomobject]@{Speed = $DLResults2;})

$DLResults3 = downloadSpeed($serverinformation[2].url)
$SpeedResults += @([pscustomobject]@{Speed = $DLResults3;})

$DLResults4 = downloadSpeed($serverinformation[3].url)
$SpeedResults += @([pscustomobject]@{Speed = $DLResults4;})

$UnsortedResults = $SpeedResults | Sort-Object -Property speed
[INT]$WanSpeed = $UnsortedResults[3].speed

switch ([int]$NumberOfAgents) 
    {
        {$_ -LE 2000}							
                {
                <#Check Internet Download Speed#>
					if($WanSpeed -GE 2) { WritePassInternet $WanSpeed; }
					else { WriteFailInternet $WanSpeed; }
			    }
     
	    {(($_ -GT 2000) -AND ($_ -LE 5000))}	 
				{ 
				<#Check Internet Download Speed#>
					if($WanSpeed -GE 5) { WritePassInternet $WanSpeed; }
					else { WriteFailInternet $WanSpeed; }
			    }

	    {(($_ -GT 5000) -AND ($_ -LE 10000))}	
				{ 
				<#Check Internet Download Speed#>
					if($WanSpeed -GE 10) { WritePassInternet $WanSpeed; }
					else { WriteFailInternet $WanSpeed; }
				}

	    {(($_ -GT 10000) -AND ($_ -LE 20000))}
				{ 
				<#Check Internet Download Speed#>
					if($WanSpeed -GE 20) { WritePassInternet $WanSpeed; }
					else { WriteFailInternet $WanSpeed; }
				}

	    {$_ -GT 20000}  
				{ 
				<#Check Internet Download Speed#>
					if($WanSpeed -GE 40) { WritePassInternet $WanSpeed; }
					else { WriteFailInternet $WanSpeed; }
				 }

        default {wh "Failure to detect WAN Speeds."}
    }



<# -------------------------------------------------------------------------- #>

wh "" -Color 3 -NewLine 0;
wh -MyInput "========================================================" -Color 3 -NewLine 0;
wh -MyInput "======== Part 2 - Software Validation ==================" -Color 3 -NewLine 0;
wh -MyInput "========================================================" -Color 3 -NewLine 0;
wh "" -Color 3 -NewLine 0;

<# LT Database on non-OS drive?#>

$GetOSDriveLetter = ($env:windir).substring(0,1);
$GetGlobalVars = .\mysql.exe --user=root --password=$RootPwd -e "show variables;" --batch -N 
$LTDBDirectory = (($GetGlobalVars | findstr /i /c:"datadir").Split()[1]).Substring(0,1)

wh "LT Database on Non-OS Drive Check: ............ " -Color 3 -NewLine 1;

If($GetOSDriveLetter -match $LTDBDirectory) {
	wh "FAIL - Database located on OS Drive: '$LtDBDirectory' !!!" -Color 1 -NewLine 0;	
	}
else {
	wh "PASS"  -Color 2 -NewLine 0;
	}

<# -------------------------------------------------------------------------- #>


<#Supported OS#>

# MB 3.10.2015 - Changed for LabTech 10

$Ver = gwmi -class Win32_OperatingSystem | select -expand version
$OsName = (gwmi -class Win32_OperatingSystem).caption;

wh "Supported Operating System: ................... " -Color 3 -NewLine 1;

if($OsName -like '*Server 2008 R2*' -or $OsName -like '*Server 2012*')
{
	wh "PASS - $OsName Installed"   -Color 2 -NewLine 0;
}
else
{
	wh "FAIL - Invalid OS: $OsName !!!"  -Color 1 -NewLine 0;
}

<# -------------------------------------------------------------------------- #>

<#Database MySQL x64#>

$MySQLVersion = (Get-WmiObject win32_service | ?{$_.Name -eq 'LabMySQL'}).pathname

wh "Database MySQL x64: ........................... " -Color 3 -NewLine 1;

If($MySQLVersion -like '*Program Files (x86)*')
{
	wh "FAIL"  -Color 1 -NewLine 0;
}
ElseIf(-not $MySQLVersion)
{
	wh "FAIL - LabMySQL Service Missing!" -Color 1 -NewLine 0;
}
Else
{
	wh "PASS" -Color 2 -NewLine 0;
}

<# -------------------------------------------------------------------------- #>

<#LabTech Database Size#>

$DbDirectory = ($GetGlobalVars | findstr /i /c:"datadir");

$CharInd = $DbDirectory.IndexOf(":");

$DbDirectory = $DbDirectory.Substring($CharInd-1,$Dbdirectory.Length - $CharInd-1)+"\Labtech\";

$DbFiles = Get-ChildItem $DbDirectory
foreach ($i in $Dbfiles) { $Sizes+=$i.Length }
$sizes= $sizes / 1gb

switch($ScalabilityBracket) {
	1 {if($Sizes -gt 10) 
		{ 
		DBSizeCheckMSG 0;
		} else { 
		DBSizeCheckMSG 1;
		}
	   }
	2 {if($Sizes -gt 20) 
		{ 
		  DBSizeCheckMSG 0
		} else { 
		  DBSizeCheckMSG 1
		}
	   }
	3 {if($Sizes -gt 30) 
		{ 
		DBSizeCheckMSG 0
		} else { 
		DBSizeCheckMSG 1
		}
	   }
	4 {if($Sizes -gt 40) 
		{ 
		DBSizeCheckMSG 0
		} else { 
		DBSizeCheckMSG 1
		}
	   }
	5 {if($Sizes -gt 60) 
		{ 
		DBSizeCheckMSG 0
		} else { 
		DBSizeCheckMSG 1
		}
	   }
	6 {if($Sizes -gt 80) 
		{ 
		DBSizeCheckMSG 0
		} else { 
		DBSizeCheckMSG 1
		}
	   }
}

<# -------------------------------------------------------------------------- #>

<#My.ini configured optimally#>

#Figure out what buffer pool size should be ...
[int]$Memory = [math]::ceiling((gwmi -class win32_ComputerSystem).TotalPhysicalMemory / 1024 / 1024)

[int]$IdealBufferPool = switch ($Memory)
    {
		{ ($_ -lt 4000) } { $Percentage = "25%"; $Allocation = $_*.25; write-output "$($Allocation)"; }
        { ($_ -GE 4000 -AND  $_ -LE 7999) } { $Percentage = "37%"; $Allocation = $_*.37; write-output "$($Allocation)"; }
        {($_ -GE 8000 -AND  $_ -LE 31999) } { $Percentage = "50%"; $Allocation = $_*.5; write-output "$($Allocation)"; }
        {($_ -GE 32000 -AND  $_ -LE 47999) } { $Percentage = "75%"; $Allocation = $_*.75; write-output "$($Allocation)" }
        { $_ -GE 48000 } { $Percentage = "80%"; $Allocation = ($_*.8); write-output "$($Allocation)" }
        default { $Percentage = "(Small %)";$Allocation = "1024"; write-output '1024' }
    }
	
	
#Get actual Value in MB from My.INI
#$bufferPool=[int](($GetGlobalVars | findstr /i /c:"innodb_buffer_pool_size") -replace "Innodb_buffer_pool_size","") -replace '\s+',''
set-location $SQLDir\bin;
$BufferPoolSize = .\mysql.exe --user=root --password=$RootPwd -e "SELECT CAST(@@innodb_buffer_pool_size/1048576 AS UNSIGNED);" --batch -N

[int]$LboundPool = [Math]::Ceiling($IdealBufferPool *.95);
[int]$UboundPool = [Math]::Ceiling($IdealBufferPool *1.05);

wh "My.ini Configured Optimally: .................. " -color 3 -newline 1;

If($BufferPoolSize -eq $IdealBufferPool -or ($bufferPoolSize -ge $LBoundPool -and $BufferPoolSize -le $UBoundPool))
{
	wh "PASS"  -Color 2 -NewLine 0;
}
elseif($bufferPoolSize -lt $LboundPool)
{
	wh "FAIL !!! Pool Size Too Low: $($BufferPoolSize)M Suggested = $($IdealBufferPool)M ($Percentage)" -Color 1 -NewLine 0;
}
elseif($bufferPoolSize -gt $UboundPool)
{
	wh "FAIL !!! Pool Size Too High: $($BufferPoolSize)M Suggested = $($IdealBufferPool)M ($Percentage)" -Color 1 -NewLine 0;
}
else
{
	wh "Unable to Detect" -Color 1 -NewLine 0;
}

<# -------------------------------------------------------------------------- #>

<#MySQL version 5.5.28a or higher.#>

wh "MySQL version 5.5.28a or higher: .............. " -Color 3 -NewLine 1;

$GetSQLVersion = .\mysql.exe --user=root --password=$RootPwd -e "select @@version;" --batch -N 

if($GetSQLVersion -like '*.*')
{
	#Remove periods so PowerShell treats 5528 as a numerical value
	$GetSQLVersion = $GetSQLVersion.Replace(".","");
	
}

#Write-Host "MySQL Version is: $GetSQLversion";

if($GetSQLVersion -ge 5528)
{
	wh "PASS"  -Color 2 -NewLine 0; 
}
else
{
	wh "FAIL" -Color 1 -NewLine 0;
}


<# -------------------------------------------------------------------------- #>


<#No other software installed.#>

gwmi -class win32_product | ? { $_.Name -like '* SQL Server*'`
							-OR $_.Name -like '*Back*Exec*'`
							-or $_.name -like '*BackupAssist*'`
							-or $_.name -like '*Symantec*'`
							-or $_.name -like '*Management Studio*'`
							-or $_.Name -like '*Acronis*'`
							-or $_.name -like '*vMotion*'`
							-or $_.Name -like '*vCloud*'`
							-or $_.name -like '*Crystal*Server*'`
							-or $_.name -like '*Vipre*Server*'`
							-or $_.name -like '*ESET*Server*'`
							-or $_.name -like '*NOD32*'`
							-or $_.name -like '*Sharepoint*'`
							-or $_.name -like '*Microsoft*Dynamics*'`
							-OR $_.name -like '*Apache*'`
							-or $_.name -like '*XAMMP*'`
							-or ($_.Name -like '*Oracle*' -AND $_.name -notLIKE '*VM*')`
							-OR $_.name -like '*Security Essentials*'`
							-or $_.name -like '*Intuit*'`
							-or $_.name -like '*Peach*tree*' } | % { $BadSoftware +="$($_.Caption),"; }


wh "No other Software Installed: .................. " -Color 3 -NewLine 1;

if(!$BadSoftware)
{
	wh "TRUE"  -Color 2 -NewLine 0;
}
else
{
	$DetectedSoftware = $BadSoftware.Substring(0,$BadSoftware.Length-1);
	wh "FALSE - List of software: $DetectedSoftware" -Color 1 -NewLine 0;
}

<# -------------------------------------------------------------------------- #>

<#Latest LabTech Build#>

wh "Latest LabTech Build Installed: ............... " -Color 3 -NewLine 1;

$LatestLTBuild = .\mysql.exe --user=root --password=$RootPwd -e "use labtech; select coalesce(concat(MajorVersion,MinorVersion),0) from config;"--batch -N 
if($LatestLTBuild -GE "100332") 
	{
	wh "PASS"  -Color 2 -NewLine 0; 
	}
else {
	wh "FAIL !!! $($LatestLTBuild) Installed" -Color 1 -NewLine 0;
	}


<# -------------------------------------------------------------------------- #>

<#License key valid#>

$ExistsLabtechDir = CheckRegKeyexists HKLM:\Software\Wow6432Node\Labtech\Setup LabTechDir;
If($ExistsLabtechDir -eq $true) 
{
	$LabTechDir=(Get-ItemProperty HKLM:\Software\Wow6432Node\Labtech\Setup -name LabTechdir).LabTechDir;
}
elseif ($LabTechDir -eq $false)
{ 
	wh "Critical Error: Unable to Locate LabTechDir Registry Key" -Color 1 -newLine 1;
	exit;
}

$LTLicenseContent = get-content $LabTechDir/Logs/LTLicense.txt

<# file writes newest entries at bottom, so lets reverse before insertion into the hash table #>
[array]::Reverse($LTLicenseContent)

$KvPKey=1;

wh "License key valid: ............................ " -Color 3 -NewLine 1;

#For first check
$ValidLicense=$false;
#For "License key validated by LabTech Server" check
$ValidatedLicense=$false;

 foreach ($entry in $LTLicenseContent)
	{
	$entry -match ".[\d{1,2}]\/\d{1,2}/\d{4}\s\d?.:..:....." | out-null
	if($entry -ne $null)
		{
		$entryMatch = $Matches[0]
		$ts = new-timespan -start ($entryMatch) -end (get-date -format g);
		if ([math]::abs($ts.TotalHours) -lt 168) 
			{
				if($entry -like '*Got License:::*')
				{
					$ValidLicense=$true;
				}
				if($entry -like '*Updated Verifier License:::*')
				{
					$ValidLicense=$true;
					$ValidatedLicense=$true;
				}
			}
		}
	}
	
if ($ValidLicense -eq $true)
{
	wh "PASS"  -Color 2 -NewLine 0; 
}
Else
{
	wh "FAIL" -Color 1 -NewLine 0;
}

<# -------------------------------------------------------------------------- #>

<#License key validated by LabTech server#>

wh "License key validated by LabTech server: ...... " -Color 3 -NewLine 1;

if($ValidatedLicense -eq $false)
	{
	wh "FAIL" -Color 1 -NewLine 0;
	}
else
	{
	wh "PASS"  -Color 2 -NewLine 0; 
	}

<# -------------------------------------------------------------------------- #>

<#UAC Disabled#>
wh "UAC Disabled: ................................. " -Color 3 -NewLine 1; 
$UACStatus=(Get-ItemProperty HKLM:\Software\Microsoft\Windows\CurrentVersion\Policies\System).EnableLUA;
switch($UACStatus) 
{
	0 { wh "PASS"  -Color 2 -NewLine 0; }
	1 { wh "FAIL" -Color 1 -NewLine 0;}
}

<# -------------------------------------------------------------------------- #>

wh "" -Color 3 -NewLine 0;
wh -MyInput "========================================================" -Color 3 -NewLine 0;
wh -MyInput "======== Part 3 - Server Roles and Services ============" -Color 3 -NewLine 0;
wh -MyInput "========================================================" -Color 3 -NewLine 0;
wh "" -Color 3 -NewLine 0;


<# TASK 0 - Verify LTAgent Service Running As System #>

$k=get-wmiobject win32_service startname -filter 'Name="LTAgent"' | select -Expand StartName

$NullFlag=0;

wh "LTAgent Running As LocalSystem Check: ......... " -Color 3 -NewLine 1;

if($k -eq $null) 
	{
	wh "FAIL - running as", $k ," !!!" -Color 1 -NewLine 0;
	$NullFlag=1;	
	}

if($NullFlag -eq '' -AND $k.contains('LocalSystem'))
	{
	wh "PASS"  -Color 2 -NewLine 0;
	} 
elseif ($NullFlag -eq '0')
	{
	wh "FAIL - running as", $k ," !!!" -Color 1 -NewLine 0;
	}

<# -------------------------------------------------------------------------- #>

<# TASK 1 - Check LTAsp Log for Errors - Last 72 Hours #>

$DateRegEx="\s\d{1,2}?\/\d{1,2}/\d{4}\s\d{1,2}:\d{1,2}:\d{1,2}\s[ap]?[m]?"
$DateNow = get-date -format g;

$ASPDirtyContent = get-content "$env:windir/temp/ltasp.txt" | findstr /i "error exception failed"
$ASPCleanContent = @{}
$KvPKey=1

foreach ($entry in $ASPDirtyContent)
{
	if(($entry -match $DateRegEx) -eq $false) { continue; }
	
	$EntryMatch = $Matches[0]

	if(($EntryMatch -Match [regex]"(AM|PM)") -eq $false) 
	{
	 <# its military time #>
	$EntryMatch=[datetime]((($EntryMatch -replace '(\d{1,2})/(\d{1,2})/(\d{1,4}) (\d{1,2}):(\d{1,2}):(\d{1,2})','$2/$1/$3 $4:$5:$6')).Trim())
	} 

	$ts = new-timespan -start ($entryMatch) -end ($datenow);
	if ([math]::abs($ts.TotalHours) -lt 72) 
	{
		$ASPcleancontent.add($KVPKEY,$entry);
		$KVPKey+=1;
	}
		
}

wh "Checking LTAsp.txt Errors - Past 72hr: ........ " -Color 3 -NewLine 1;
if($ASPCleanContent.Count -gt 0) 
	{
	wh -MyInput "FAIL !!!" -Color 1 -NewLine 0;
	wh -MyInput "              Errors detected: $($AspCleanContent.Count) found in $env:windir/temp/ltasp.txt" -Color 1 -NewLine 0;
	}
else {
	wh "PASS"  -Color 2 -NewLine 0;
	}


<# -------------------------------------------------------------------------- #>



<# TASK 2 - Check LTAErrors Log for Errors - Last 72 Hours #>

$DateRegEx="\s\d{1,2}\/\d{1,2}/\d{4}\s\d{1,2}:\d{1,2}:\d{1,2}\s[ap]?[m]?"
$DateNow = get-date -format g;
$EntryMatch=$null;
$Entry=$null;

$LabTechDir=(Get-ItemProperty HKLM:\Software\Wow6432Node\Labtech\Setup -name LabTechdir).LabTechDir;
$LabTechDir = $labtechdir -replace "\\","\";
$DirtyContent = get-content $LabTechDir\Logs\LTAErrors.txt | findstr /i "error exception failed"

$LTCleanContent = @{}
$KvPKey=1
 foreach ($entry in $DirtyContent)
	{
	if(($entry -match $DateRegEx) -eq $false) { continue; }

	$EntryMatch = $Matches[0]

	if(($EntryMatch -Match [regex]"(AM|PM)") -eq $false) 
	{
	 <# its military time #>
	$EntryMatch=[datetime]((($EntryMatch -replace '(\d{1,2})/(\d{1,2})/(\d{1,4}) (\d{1,2}):(\d{1,2}):(\d{1,2})','$2/$1/$3 $4:$5:$6')).Trim())
	} 

	$ts = new-timespan -start ($entryMatch) -end ($datenow);
	if ([math]::abs($ts.TotalHours) -lt 72) 
	{
		$LTcleancontent.add($KVPKEY,$entry);
		$KVPKey+=1;
	}
		
	}
	
	wh "Checking LTAErrors.txt Errors - Past 72hr: .... " -Color 3 -NewLine 1;
	
	if($LTCleanContent.Count -gt 0) 
	{
	wh "FAIL !!!" -Color 1 -NewLine 0;
	wh "              Errors detected: $($LTCleanContent.Count) found in $($LabTechDir)Logs\LTAErrors.txt" -Color 1 -NewLine 0;
	}
else {
	wh "PASS"  -Color 2 -NewLine 0;
	}

<# -------------------------------------------------------------------------- #>


wh "" -Color 3 -NewLine 0;
wh -MyInput "========================================================" -Color 3 -NewLine 0;
wh -MyInput "======== Server Role Validation ========================" -Color 3 -NewLine 0;
wh -MyInput "========================================================" -Color 3 -NewLine 0;
wh "" -Color 3 -NewLine 0;

<# Task 3,4,5,6,7 - Server Roles and Role Services Validation #>

import-module ServerManager;
$ServerFeatureListObj = get-windowsfeature | where-object {$_.Installed -eq "Installed"} | Select -Expand "Name";
foreach ($i in $ServerFeatureListObj) { $list += $i };

<# MAB Playground test#>


$RoleServicesArray = @(('Web-Server',"Verify Web Server Role Installed: ............. "),
				('Web-Common-Http',"Common HTTP Features Installed: ............... "),
				('Web-Static-Content',"Static Content Installed: ..................... "),
				('Web-Dir-Browsing',"Directory Browsing Installed: ................. "),
				('Web-Http-Errors',"HTTP Errors Installed: ........................ "),
				('Web-Http-Redirect',"HTTP Redirection Installed: ................... "),
				('Web-Net-Ext',".NET Extensibility Installed: ................. "),
				('Web-ASP',"ASP Installed: ................................ "),
				('Web-ISAPI-Ext',"ISAPI Extensions Installed: ................... "),
				('Web-ISAPI-Filter',"ISAPI Filters Installed: ...................... "),
				('Web-Health',"Health & Diagnostics Installed: ............... "),
				('Web-Http-Logging',"HTTP Logging Installed: ....................... "),
				('Web-Performance',"Performance Installed: ........................ "),
				('Web-Basic-Auth',"Basic Authentication Installed: ............... "),
				('Web-Windows-Auth',"Windows Authentication Installed: ............. "),
				('Web-Stat-Compression',"Static Content Compression Installed: ......... "),
				('Web-Dyn-Compression',"Dynamic Content Compression Installed: ........ "),
				('Web-Mgmt-Tools',"Management Tools Installed: ................... "),
				('Web-Mgmt-Console',"IIS Mgmt Console Installed: ................... "),
				('Web-Scripting-Tools',"IIS Mgmt Scripts & Tools Installed: ........... "),
				('Web-Mgmt-Service',"Management Service Installed: ................. "),
				('Web-Mgmt-Compat',"IIS 6 Management Compatibility Installed: ..... "),
				('Web-Metabase',"IIS 6 Metabase Compatibility Installed: ....... "),
				('Web-WMI',"IIS 6 WMI Compatibility Installed: ............ "),
				('Web-Lgcy-Scripting',"IIS 6 Scripting Tools Installed: .............. "),
				('Web-Lgcy-Mgmt-Console',"IIS 6 Management Console Installed: ........... "),
				('Web-ASP-Net',"ASP.NET Installed: ............................ "),
				('Net-Framework-Core',".NET Framework 3.5 Installed: ................. "))
				
	ForEach ($Role in $RoleServicesArray)
		{
		wh $Role[1] 3 1; 
			if ($list -match $role[0]) 
				{
				wh "PASS"  -Color 2 -NewLine 0;
				} 
			else 
				{
				wh "FAIL !!!" -Color 1 -NewLine 0;
				}
		}

wh "" -Color 3 -NewLine 0;
wh -MyInput "========================================================" -Color 3 -NewLine 0;
wh -MyInput "======== IIS Configuration Validation ==================" -Color 3 -NewLine 0;
wh -MyInput "========================================================" -Color 3 -NewLine 0;
wh "" -Color 3 -NewLine 0;


<# -------------------------------------------------------------------------- #>



<# TASK 8 - ASP Debugging and Super Debugging is Enabled Verification #>

$AppCMD="$env:systemroot\system32\inetsrv"
set-location $AppCMD

$AspDebugFlag=.\appcmd.exe list config /section:asp | findstr /I /c:"appAllowDebugging="; 

$NullFlag=0;

wh "ASP Debugging and Super Debugging Enabled: .... " -Color 3 -NewLine 1;

if($AspDebugFlag -eq $null) 
	{
	wh "FAIL !!!" -Color 1 -NewLine 0;
	$NullFlag=1;
	}

if($NullFlag -eq '' -AND $AspDebugFlag.contains('appAllowDebugging="true"'))
	{
	wh "PASS"  -Color 2 -NewLine 0;
	} 
elseif ($NullFlag -eq '0') 
	{
	wh "FAIL !!!" -Color 1 -NewLine 0;
	}



<# -------------------------------------------------------------------------- #>



<# TASK 9 - ASP Logging Enabled Verification #>

$AspLoggingFlag=.\appcmd.exe list config /section:asp | findstr /I /c:"errorsToNTLog=";

$NullFlag=0;

wh "ASP Logging Enabled: .......................... " -Color 3 -NewLine 1;

if($AspLoggingFlag -eq $null) 
	{
	wh "FAIL !!!" -Color 1 -NewLine 0;
	$NullFlag=1;
	} 

if($NullFlag -eq '' -AND $AspLoggingFlag.contains('errorsToNTLog="true"'))
	{
	wh "PASS"  -Color 2 -NewLine 0;
	} 
elseif ($NullFlag -eq '0') 
	{
	wh "FAIL !!!" -Color 1 -NewLine 0;
	}



<# -------------------------------------------------------------------------- #>


<# TASK 10 - LabTech AppPool Is Using Integrated Mode Verification#>

$AppIntegMode=.\appcmd.exe list apppool /ManagedPipelineMode:Integrated | findstr /I /c:"LabTech"; 

wh "LabTech App Pool Using Integrated Mode: ....... " -Color 3 -NewLine 1;

if(!$AppIntegMode) 
	{
	wh "FAIL !!!" -Color 1 -NewLine 0;
	}
elseif($AppIntegMode -match 'Integrated')
	{
	wh "PASS"  -Color 2 -NewLine 0;
	} 
elseif ($AppIntegMode -notmatch 'Integrated')
	{
	wh "FAIL !!!" -Color 1 -NewLine 0;
	}



<# -------------------------------------------------------------------------- #>



<# TASK 11 - IIS Runtime Enabled Verification #>

$IISRuntimeEnabled=.\appcmd.exe list config -section:system.webserver/serverruntime | findstr /I /c:"1073741824";

wh "IIS Server Runtime Enabled Check: ............. " -Color 3 -NewLine 1;

if(!$IISRuntimeEnabled) 
	{
	wh "FAIL !!!" -Color 1 -NewLine 0;
	} 
elseif($IISRuntimeEnabled -match 'enabled="true"')
	{
	wh "PASS"  -Color 2 -NewLine 0;
	} 
elseif ($IISRunTimeEnabled -notmatch 'enabled="true"')
	{
	wh "FAIL !!!" -Color 1 -NewLine 0;
	} 


<# -------------------------------------------------------------------------- #>


<# TASK 12 - IIS Upload Read Ahead Size = 1073741824 Verification #>

wh "IIS Upload Read Ahead Size: ................... " -Color 3 -NewLine 1;

if(!$IISRuntimeEnabled) 
	{
	wh "FAIL !!!" -Color 1 -NewLine 0;
	}
elseif($IISRuntimeEnabled -match '1073741824')
	{
	wh "PASS"  -Color 2 -NewLine 0;
	} 
elseif ($IISRuntimeEnabled -notmatch '1073741824')
	{
	wh "FAIL !!!" -Color 1 -NewLine 0;
	}
 

<# -------------------------------------------------------------------------- #>



<# TASK 13 - IIS Connection Timeout = 15:00 minutes Verification #>

$IISConTimeout=.\appcmd.exe list config -section:system.applicationhost/weblimits | findstr /I /c:'connectionTimeout=';

wh "IIS Connection Timeout Check: ................. " -Color 3 -NewLine 1;

if(!$IISConTimeout) 
	{
	wh "FAIL !!!" -Color 1 -NewLine 0;
	}

if($IISConTimeout -match 'connectionTimeout="00:15:00"')
	{
	wh "PASS"  -Color 2 -NewLine 0;
	} 
elseif ($IISConTimeout -NOTmatch 'connectionTimeout="00:15:00"')
	{
	wh "FAIL !!!" -Color 1 -NewLine 0;
	}



<# -------------------------------------------------------------------------- #>


<# TASK 14 - IIS Header Wait Time = 5:00 minutes Verification #>

wh "IIS Header Wait Time Check: ................... " -Color 3 -NewLine 1;
	
if(!$IISConTimeout) 
	{
	wh "FAIL !!!" -Color 1 -NewLine 0;
	} 
elseif ($IISConTimeout -match 'headerWaitTimeout="00:05:00"')
	{
	wh "PASS"  -Color 2 -NewLine 0;
	} 
elseif ($IISConTimeout -NOTmatch 'headerWaitTimeout="00:05:00"')
	{
	wh "FAIL !!!" -Color 1 -NewLine 0;
	}


<# -------------------------------------------------------------------------- #>


<# TASK 15 - IIS Minimum Bytes Per Second = 0 Verification #>

wh "IIS Minimum Bytes Per Second: ................. " -Color 3 -NewLine 1;
	
if(!$IISConTimeout) 
	{
	wh "FAIL !!!" -Color 1 -NewLine 0;
	}
elseif($IISConTimeout -match 'minBytesPerSecond="0"')
	{
	wh "PASS"  -Color 2 -NewLine 0;
	} 
elseif ($IISConTimeout -notMatch 'minBytesPerSecond="0"')
	{
	wh "FAIL !!!" -Color 1 -NewLine 0;
	}


<# -------------------------------------------------------------------------- #>


<# TASK 16 - IIS Dynamic Compression = Disabled Verification #>

$IISCompression=.\appcmd.exe list config "Default Web Site" -section:urlCompression | findstr /I /c:'doDynamicCompression='; 

wh "IIS Dynamic Compression Check: ................ " -Color 3 -NewLine 1;

if(!$IISCompression) 
	{ 
	wh "FAIL !!!" -Color 1 -NewLine 0;
	}
elseif ($IISCompression -match 'doDynamicCompression="false"')
	{
	wh "PASS"  -Color 2 -NewLine 0;
	} 
elseif($IISCompression -NOTmatch 'doDynamicCompression="false"')
	{
	wh "FAIL !!!" -Color 1 -NewLine 0;
	}


<# -------------------------------------------------------------------------- #>

<# TASK 17 - IIS Static Compression = Disabled Verification #>

wh "IIS Static Compression Check: ................. " -Color 3 -NewLine 1;

if(!$IISCompression) 
	{
	wh "FAIL !!!" -Color 1 -NewLine 0;
	}
elseif($IISCompression -match 'doStaticCompression="false"')
	{
	wh "PASS"  -Color 2 -NewLine 0;
	} 
elseif ($IISCompression -notmatch 'doStaticCompression="false"')
	{
	wh "FAIL !!!" -Color 1 -NewLine 0;
	}


<# -------------------------------------------------------------------------- #>


<# TASK 18 - IIS Maximum Worker Processes = 1 Check #>

$IISWorkerProc=.\appcmd.exe list apppool /name:"LabTech" /processmodel.maxprocesses:1 | findstr /I /c:'"Labtech"'; 

wh "IIS Maximum Worker Processes Check: ........... " -Color 3 -NewLine 1;

if(!$IISWorkerProc) 
	{
	wh "FAIL - Must be '1' !!!" -Color 1 -NewLine 0;
	}
elseif($IISWorkerProc -match '"LabTech"')
	{
	wh "PASS"  -Color 2 -NewLine 0;
	} 
else
	{
	wh "FAIL - Must be '1' !!!" -Color 1 -NewLine 0;
	}


<# -------------------------------------------------------------------------- #>


<# TASK 19 - Transfer Folder Set as a Virtual Directory #>
$k=.\appcmd.exe list vdir "Default Web site/LabTech/Transfer" | findstr /I /c:'LTShare\Transfer';

wh "IIS Transfer Folder Set as a Virtual Directory: "  -Color 3 -NewLine 1; 

if($k -eq $null) 
	{
	wh "FAIL !!! - Null returned" -Color 1 -NewLine 0;
	}
elseif($k.contains('LabTech/Transfer'))
	{
	wh "PASS" -Color 2 -NewLine 0;
	} 
else
	{
	wh "FAIL !!!" -Color 1 -NewLine 0;
	}

<# -------------------------------------------------------------------------- #>


<# TASK 20 - Transfer Folder VDIR pointed to LTShare - Verify that it's in the LTSHARE\Transfer folder #>

wh "IIS Transfer VDIR in LTShare: ................. " -Color 3 -NewLine 1;

if($k -eq $null) 
	{
	wh "FAIL !!!" -Color 1 -NewLine 0;
	}
elseif ($k.contains('LTShare\Transfer'))
	{
	wh "PASS" -Color 2 -NewLine 0;
	}
else
	{
	wh "FAIL !!!" -Color 1 -NewLine 0;
	}

<# -------------------------------------------------------------------------- #>

<# TASK 21 - SSL Certificate Binding #>

& .\appcmd.exe list site /site.name:"Default Web Site" | % { If ($_ -like '*HTTPS*') { $SSLCheck = $true; } else { $SSLCheck = $false; } }

wh "Site Bound to a NON-Self Signed SSL Cert: ..... "  -Color 3 -NewLine 1; 

if(!$SSLCheck -or $SSLCheck -ne $True) 
	{
	wh "FAIL !!!" -Color 1 -NewLine 0;
	}
elseif($SSLCheck -eq $true)
	{
	wh "PASS" -Color 2 -NewLine 0;
	}
		
<# -------------------------------------------------------------------------- #>

wh "" -Color 3 -NewLine 0;
wh -MyInput "========================================================" -Color 3 -NewLine 0;
wh -MyInput "======== Network Configurations ========================" -Color 3 -NewLine 0;
wh -MyInput "========================================================" -Color 3 -NewLine 0;
wh "" -Color 3 -NewLine 0;

wh "TCP/IP TCP Chimney - Should Be Disabled: ...... " -Color 3 -NewLine 1;

<# TCP Chimney #>

$TCPChimney = get-itemproperty -path HKLM:\SYSTEM\CurrentControlSet\Services\Tcpip\Parameters -name EnableTCPChimney | select -expand EnableTCPChimney

if($TCPChimney -ne 0)
	{
		wh "FAIL!!! TCP/IP Chimney is Enabled!" -Color 1 -NewLine 0;
	}
else
	{
		wh "PASS" -Color 2 -NewLine 0;
	}

	
<# -------------------------------------------------------------------------- #>

<# Max Port #>


$RegExists = checkRegKeyExists HKLM:\System\ControlSet001\Services\tcpip\Parameters MaxUserPort
if($RegExists -eq $true) 
	{
			$MaxUserPorts = (Get-ItemProperty HKLM:\System\ControlSet001\Services\tcpip\Parameters -Name MaxuserPort).MaxUserPort
			
			wh "TCP/IP Max user ports = 65534: ................ " -Color 3 -NewLine 1;	
			
			if($MaxUserPorts -eq 65534)
			{
				wh "PASS" -Color 2 -NewLine 0;
			}
			else
			{
				wh "FAIL!!! Current Value is: $($MaxUserPorts)" -Color 1 -NewLine 0;
			}
	} 
else 
	{
	wh "Unable to Detect Value" -Color 1 -NewLine 0;
	}

<# -------------------------------------------------------------------------- #>

<# TCPIP TCP Timed wait delay #>

$RegExists = checkRegKeyExists HKLM:\System\ControlSet001\Services\tcpip\Parameters TCPTimedWaitDelay

wh "TCP/IP TCP Timed wait delay : ................. " -Color 3 -NewLine 1;

if($RegExists -eq $true) 
		{
				$TimedDelay = (Get-ItemProperty HKLM:\System\ControlSet001\Services\tcpip\Parameters -Name TCPTimedWaitDelay).TCPTimedWaitDelay
				
				if($TimedDelay -eq 30)
				{

					wh "PASS" -Color 2 -NewLine 0;
				}
				elseif ($TimedDelay -gt 30)
				{
					wh "FAIL!!! Timed Delay should be 30 seconds, not $($TimedDelay) (configured)" -Color 1 -NewLine 0;
				}
		}
else 	
		{
		wh "Unable to Detect Value" -Color 1 -NewLine 0;
		}

<# -------------------------------------------------------------------------- #>

<# TCPIP Reserved Ports = 3306-3306,8000-9024,40000-40100 #>

$RegExists = checkRegKeyExists HKLM:\System\ControlSet001\Services\tcpip\Parameters ReservedPorts
if($RegExists -eq $true) 
{
	$ReservedPorts = (Get-ItemProperty HKLM:\System\ControlSet001\Services\tcpip\Parameters -Name ReservedPorts).ReservedPorts
	$ReservedPorts = [String]$ReservedPorts;
	<# Using Qualifier to determine if all matched. If not all matched, I will use the sum to determine which did not match. #>
	
	$Qualifier = 0;

		if ($ReservedPorts -match "3306-3306") {$Qualifier+=4;}
		if ($ReservedPorts -match "8000-9024") { $Qualifier+=6; }	
		if ($ReservedPorts -match "40000-40100") { $Qualifier+=20; }
	
	
	wh "TCP/IP Reserve Ports: ......................... " -Color 3 -NewLine 1;
	
	if(($Qualifier % 30) -gt 0 )
		{
		switch([int]$Qualifier) {
			4  { wh "FAIL!!! - Only Reserved 3306-3306 (Missing 8000-9024, 40000-40100)" -color 1 -NewLine 0; }
			6  { wh "FAIL!!! - Only Reserved 8000-9024 (Missing 3306-3306, 40000-40100)" -color 1 -NewLine 0; }
			10 { wh "FAIL!!! - Only Reserved 3306-3306, 8000-9024 (Missing 40000-40100)" -color 1 -NewLine 0; }
			20 { wh "FAIL!!! - Only Reserved 40000-40100 (Missing 3306-3306, 8000-9024)" -color 1 -NewLine 0; }
			24 { wh "FAIL!!! - Only Reserved 3306-3306, 40000-40100 (Missing 8000-9024)" -color 1 -NewLine 0; }
			26 { wh "FAIL!!! - Only Reserved 8000-9024, 40000-40100 (Missing 3306-3306)" -color 1 -NewLine 0; }
		}
	} else <# Passed! #>
		{
			wh "PASS" -Color 2 -NewLine 0;
		}
	}
else 
	{ 	
	wh "TCP/IP Reserve Ports : ........................ " -Color 3 -NewLine 1;
	wh "Unable to Detect Value" -Color 1 -NewLine 0;
	}
	
<# -------------------------------------------------------------------------- #>

<# Can Navigate to www.LabTechSoftware.com #>	

$httprequest = [Net.WebRequest]::Create("http://www.LabTechSoftware.com")
$httprequest.timeout=10000;
$timeout=$false;

try
{
$requestresp = $httprequest.GetResponse()
}
catch 
{
$timeout = $true 
}


if($response.StatusCode -eq 200)
{
$CanAccess = $true;
}
else
{
$CanAccess = $false;
}

wh "Able to browse to http://LabTechSoftware.com: . " -Color 3 -NewLine 1;

if ($CanAccess=$true -and $timeout -ne $true)
	{
	wh "PASS" -Color 2 -NewLine 0;
	}
elseif ($CanAccess=$false -OR $timeout -eq $true)
	{
	wh "Unable to Detect Value" -Color 1 -NewLine 0;
	}
	
<# -------------------------------------------------------------------------- #>
$ElapsedTime = new-timespan $StartTime $(get-date)

wh "" -Color 2 -NewLine 0;
wh "Server Validation Process Complete - Process took: $($ElapsedTime)" -Color 2 -NewLine 0;
wh "" -Color 2 -NewLine 0;
wh "Log file: $env:windir\temp\$($hostname)-LTServerValidationResults.txt" -color 3 -NewLine 0;
$MyStream.close();

Rename-Item $env:windir/temp/$($hostname)-LTServerValidationResults.txtTEMP "$($hostname)-LTServerValidationResults.txt"

<#
write-host "Would you like for me to open the log file for you?  " -nonewline;
write-host "[Y]/[N]" -fore Yellow;
$resp = read-host;

if($resp.ToUpper() -eq "Y") 
{
invoke-item "$env:windir\temp\$($hostname)-LTServerValidationResults.txt" 
} else 
{ 
exit;
}
#>
