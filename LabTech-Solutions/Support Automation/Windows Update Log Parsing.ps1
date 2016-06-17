<#########################################################################################>
<#
	Windows Update Error Code HashTable
  	Retrieve items like $WUErrorCodes.get_Item("0x80240004")
#>
$ErrorActionPreference = "silentlycontinue"
$WUErrorCodes = @{
	
"0x80240001" = "NO_SERVICE Windows Update Agent was unable to provide the service."
"0x80240002" = "MAX_CAPACITY_REACHED The maximum capacity of the service was exceeded."
"0x80240003" = "UNKNOWN_ID An ID cannot be found."
"0x80240004" = "NOT_INITIALIZED The object could not be initialized."
"0x80240005" = "RANGEOVERLAP The update handler requested a byte range overlapping a previously requested range."
"0x80240006" = "TOOMANYRANGES The requested number of byte ranges exceeds the maximum number (2^31 - 1)."
"0x80240007" = "INVALIDINDEX The index to a collection was invalid."
"0x80240008" = "ITEMNOTFOUND The key for the item queried could not be found."
"0x80240009" = "OPERATIONINPROGRESS Another conflicting operation was in progress. Some operations such as installation cannot be performed twice simultaneously."
"0x8024000A" = "COULDNOTCANCEL Cancellation of the operation was not allowed."
"0x8024000B" = "CALL_CANCELLED Operation was cancelled."
"0x8024000C" = "NOOP No operation was required."
"0x8024000D" = "XML_MISSINGDATA Windows Update Agent could not find required information in the update's XML data."
"0x8024000E" = "XML_INVALID Windows Update Agent found invalid information in the update's XML data."
"0x8024000F" = "CYCLE_DETECTED Circular update relationships were detected in the metadata."
"0x80240010" = "TOO_DEEP_RELATION Update relationships too deep to evaluate were evaluated."
"0x80240011" = "INVALID_RELATIONSHIP An invalid update relationship was detected."
"0x80240012" = "REG_VALUE_INVALID An invalid registry value was read."
"0x80240013" = "DUPLICATE_ITEM Operation tried to add a duplicate item to a list."
"0x80240016" = "INSTALL_NOT_ALLOWED Operation tried to install while another installation was in progress or the system was pending a mandatory restart."
"0x80240017" = "NOT_APPLICABLE Operation was not performed because there are no applicable updates."
"0x80240018" = "NO_USERTOKEN Operation failed because a required user token is missing."
"0x80240019" = "EXCLUSIVE_INSTALL_CONFLICT An exclusive update cannot be installed with other updates at the same time."
"0x8024001A" = "POLICY_NOT_SET A policy value was not set."
"0x8024001B" = "SELFUPDATE_IN_PROGRESS The operation could not be performed because the Windows Update Agent is self-updating."
"0x8024001D" = "INVALID_UPDATE An update contains invalid metadata."
"0x8024001E" = "SERVICE_STOP Operation did not complete because the service or system was being shut down."
"0x8024001F" = "NO_CONNECTION Operation did not complete because the network connection was unavailable."
"0x80240020" = "NO_INTERACTIVE_USER Operation did not complete because there is no logged-on interactive user."
"0x80240021" = "TIME_OUT Operation did not complete because it timed out."
"0x80240022" = "ALL_UPDATES_FAILED Operation failed for all the updates."
"0x80240023" = "EULAS_DECLINED The license terms for all updates were declined."
"0x80240024" = "NO_UPDATE There are no updates."
"0x80240025" = "USER_ACCESS_DISABLED Group Policy settings prevented access to Windows Update."
"0x80240026" = "INVALID_UPDATE_TYPE The type of update is invalid."
"0x80240027" = "URL_TOO_LONG The URL exceeded the maximum length."
"0x80240028" = "UNINSTALL_NOT_ALLOWED The update could not be uninstalled because the request did not originate from a WSUS server."
"0x80240029" = "INVALID_PRODUCT_LICENSE Search may have missed some updates before there is an unlicensed application on the system."
"0x8024002A" = "MISSING_HANDLER A component required to detect applicable updates was missing."
"0x8024002B" = "LEGACYSERVER An operation did not complete because it requires a newer version of server."
"0x8024002C" = "BIN_SOURCE_ABSENT A delta-compressed update could not be installed because it required the source."
"0x8024002D" = "SOURCE_ABSENT A full-file update could not be installed because it required the source."
"0x8024002E" = "WU_DISABLED Access to an unmanaged server is not allowed."
"0x8024002F" = "CALL_CANCELLED_BY_POLICY Operation did not complete because the DisableWindowsUpdateAccess policy was set."
"0x80240030" = "INVALID_PROXY_SERVER The format of the proxy list was invalid."
"0x80240031" = "INVALID_FILE The file is in the wrong format."
"0x80240032" = "INVALID_CRITERIA The search criteria string was invalid."
"0x80240033" = "EULA_UNAVAILABLE License terms could not be downloaded."
"0x80240034" = "DOWNLOAD_FAILED Update failed to download."
"0x80240035" = "UPDATE_NOT_PROCESSED The update was not processed."
"0x80240036" = "INVALID_OPERATION The object's current state did not allow the operation."
"0x80240037" = "NOT_SUPPORTED The functionality for the operation is not supported."
"0x80240038" = "WINHTTP_INVALID_FILE The downloaded file has an unexpected content type."
"0x80240039" = "TOO_MANY_RESYNC Agent is asked by server to resync too many times."
"0x80240040" = "NO_SERVER_CORE_SUPPORT WUA API method does not run on Server Core installation."
"0x80240041" = "SYSPREP_IN_PROGRESS Service is not available while sysprep is running."
"0x80240042" = "UNKNOWN_SERVICE The update service is no longer registered with AU."
"0x80240FFF" = "UNEXPECTED An operation failed due to reasons not covered by another error code."
}

Function Do-Regex
{
	[CmdletBinding()]
	param (
		[Parameter(Mandatory = $True, ValueFromPipeline = $True)]
		[string]$Regex,
		[Parameter(Mandatory = $True, ValueFromPipeline = $True)]
		[string]$MatchData)
	
	$TempRegexResults = [regex]::matches($MatchData, $Regex)
	
	If ($TempRegexResults -ne $null)
	{
		$RegexResult = "$($TempRegexResults.groups[1].value)"
		Return $RegexResult
	}
	
	Else { Return 'Regex Failed' }
}

Function Write-Log
{
	Param
		(
		[string]$strMessage
	)

	$Path = "$($env:windir)/temp/WULResults.txt"
	[string]$strDate = get-date
	Out-file -FilePath $Path -InputObject $strMessage -Append
}


<#########################################################################################>

<#Check 1.0 - Pulls all "Caller IDs" from the Windows Update Log that are NOT "LabTech".#>
<#
	Components that can write to this log:
	
		AGENT- Windows Update agent
		AU- Automatic Updates is performing this task
		AUCLNT- Interaction by AU with the logged on user
		CDM- Device Manager
		CMPRESS- Compression agent
		COMAPI- Windows Update API
		DRIVER- Device driver information
		DTASTOR- Handles database transactions
		DWNLDMGR- Creates and monitors download jobs
		EEHNDLER- Expression handler used to evaluate update applicability
		HANDLER- Manages the update installers
		MISC- General service information
		OFFLSNC- Detect available updates when not connected to the network
		PARSER- Parses expression information
		PT- Synchronizes updates information to the local datastore
		REPORT- Collects reporting information
		SERVICE- Startup/Shutdown of the Automatic Updates service
		SETUP- Installs new versions of the Windows Update client when available
		SHUTDWN- Install at shutdown feature
		WUREDIR- The Windows Update redirector files
		WUWEB- The Windows Update ActiveX control
#>

$CallerIDs = Get-Content $env:windir\windowsupdate.log | Where-Object { $_ -like '*CallerID*' -or $_ -like '*ClientID*' -and $_ -notlike '*LabTech*' -and $_ -notlike '*Windows System Health Agent Search*'}

IF ($CallerIDs)
{
	$CallerIDstemp = $CallerIDs -split '\t+'
	
	Foreach ($ID in $CallerIDstemp)
	{
		$objCallerIDs +=
		@([pscustomobject]@{ Date = $CallerIDstemp[0]; Time = $CallerIDstemp[1]; Component = $CallerIDstemp[4]; Text = $CallerIDstemp[5] })
	}
	Write-Log "*************************************************";
	Write-Log "**********BEGIN BAD CALLER AND CLIENT IDS********";
	Write-Log "*************************************************";
	Write-Log ""
	
	$objCallerIDs | select -uniq | Format-Table -Wrap -AutoSize | Out-file -FilePath "$($env:windir)/temp/WULResults.txt" -Append
	
	Write-Log ""
	Write-Log "*************************************************";
	Write-Log "**********END BAD CALLER AND CLIENT IDS**********";
	Write-Log "*************************************************";
	Write-Log ""
}

Else
{
	Write-Log "*************************************************"
	Write-Log "*********No Bad Caller IDs Detected**************"
	Write-Log "*************************************************"
	Write-Log ""
}

<#########################################################################################>

<#Check 2.0 - Pulls any WSUS Information from the Log.#>

$WSUSInfo = Get-Content $env:windir\windowsupdate.log | Where-Object {$_ -like '*WSUS*' -and $_ -notlike '*NULL*'}

If($WsusInfo)
{
	$WSUSInfotemp = $WSUSInfo -split '\t+'
	Foreach($Entry in $WSUSInfostemp)
	{
		$objWSUSInfo += 
		@([pscustomobject]@{Date = $WSUSInfostemp[0]; Time = $WSUSInfostemp[1]; PID = $WSUSInfostemp[2]; TID = $WSUSInfostemp[3];Component = $WSUSInfostemp[4];Text = $WSUSInfostemp[5]})
	}
	Write-Log "*************************************************"
	Write-Log "**********BEGIN BAD WSUS ENTRIES*****************"
	Write-Log "*************************************************"
	Write-Log ""
	
	$objWSUSInfo | select -uniq | Format-Table -Wrap -AutoSize | Out-file -FilePath "$($env:windir)/temp/WULResults.txt" -Append
	
	Write-Log ""
	Write-Log "*************************************************"
	Write-Log "**********END BAD WSUS ENTRIES*******************"
	Write-Log "*************************************************"
	Write-Log ""
}

Else
{
	Write-Log "*************************************************"
	Write-Log "*********No Bad WSUS Entries Detected************"
	Write-Log "*************************************************"
	Write-Log ""
}

<#########################################################################################>

<#Check 3.0 - Pulls any HResult Information from the Log.#>

$HResultErrors = Get-Content $env:windir\windowsupdate.log | Where-Object { $_ -like '*hr=*' -and $_ -notlike 'hr=0x0 '}

IF ($HResultErrors)
{
	$HResultErrorstemp = $HResultErrors -split '\t+'
	
	Foreach ($Result in $HResultErrorstemp)
	{
		$objHResultInfo +=
		@([pscustomobject]@{ Date = $HResultErrorstemp[0]; Time = $HResultErrorstemp[1]; Component = $HResultErrorstemp[4]; Text = $HResultErrorstemp[5]; HrefCode = ''; Explanation = ''; })
	}
	
	Foreach ($Hresult in $objHResultInfo)
	{
		$DoRegexReturn = Do-Regex -regex "(?:hr=)([0-9]x[0-9]{1,8})" -MatchData $Hresult.text
		
		
		If ($DoRegexReturn -eq 'Regex Failed')
		{
			$Hresult.hrefcode = 'HREF REGEX FAILED'
			$Hresult.explanation = 'HREF REGEX FAILED'
		}
		
		ElseIf ($DoRegexReturn -eq '0x0' -or $DoRegexReturn -eq '0x00000000')
		{
			$Hresult.hrefcode = $DoRegexReturn
			$Hresult.explanation = 'NOT AN ERROR'
		}
		
		Else
		{
			$Hresult.hrefcode = $DoRegexReturn
			$Explanation = $WUErrorCodes.Item($DoRegexReturn)
			If ($Explanation) { $Hresult.explanation = $Explanation }
			Else { $Hresult.explanation = 'Unable to determine the meaning of this Href error code.' }
		}
		
	}
	Write-Log "*************************************************"
	Write-Log "**********BEGIN HRESULT ENTRIES******************"
	Write-Log "*************************************************"
	Write-Log ""
	
	$objHResultInfo | select -uniq | Format-Table -Wrap -AutoSize | Out-file -FilePath "$($env:windir)/temp/WULResults.txt" -Append;
	
	Write-Log ""
	Write-Log "*************************************************"
	Write-Log "**********END HRESULT ENTRIES********************"
	Write-Log "*************************************************"
	Write-Log ""
}

Else
{
	Write-Log "*************************************************"
	Write-Log "*********No HREF Errors Detected*****************"
	Write-Log "*************************************************"
	Write-Log ""
}

RETURN 'SUCCESS'