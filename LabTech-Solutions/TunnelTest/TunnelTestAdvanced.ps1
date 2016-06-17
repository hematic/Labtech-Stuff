$MediatorServers +=
@([pscustomobject]@{
	Name = "US East";
	Args = "/E /M mediator.labtechsoftware.com";
	Value = "";
})
$MediatorServers +=
	@([pscustomobject]@{
		Name = "US West";
		Args = "/E /M uswest.mediator.labtechsoftware.com";
		Value = "";
	})
$MediatorServers +=
	@([pscustomobject]@{
		Name = "Europe";
		Args = "/E /M eu.mediator.labtechsoftware.com";
		Value = "";
	})
$MediatorServers +=
	@([pscustomobject]@{
		Name = "Australia";
		Args = "/E /M au.mediator.labtechsoftware.com";
		Value = "";
	})



$TunnelTestPath = "C:\Users\pmarshall\Documents\TunnelTester\TunnelTest.exe"
$LogPath = "C:\Users\pmarshall\Documents\TunnelTester\TunnelTest.txt"

$SuccessRegexes = "(Tunnels Connected)", "(Tunnels Pings Received [1-9])", "(TCP Tests Success all data recieved Whole)", "(UDP Tests Success all data recieved Whole)", "(Socks Tests Success)", "(HTTP Proxy Tests Success)"
$RegexResults = @()

Foreach ($Mediator in $MediatorServers)
{
    Get-Process tunneltest* | Stop-Process -force

    $Process = Start-Process "$TunnelTestPath" -ArgumentList "$($Mediator.Args) & exit" -NoNewWindow -PassThru -RedirectStandardOutput "$LogPath"

    Write-host "Process ID = $($Process.id)"
    Wait-Process -id $Process.ID -timeout 30

    if (!$Process.hasExited)
    {
	    taskkill /T /F /PID $Process.ID
	    $Mediator.value = "Mediator testing timed out"
	}

    Else
    {
	    [String]$Contents = Get-Content "$LogPath"
        
        $RegexResults = @()
	
	    Foreach ($Regex in $SuccessRegexes) { $RegexResults += ([regex]::matches($Contents, "$Regex")).groups[1].value }
	
	    If ($RegexResults.length -eq 6) { [INT]$Mediator.value = 1;}
	
	    Else { $Mediator.value = $Results; }
    }

}

If (($Mediatorservers.value | Measure-Object -sum).sum -eq 4){Return 1; exit;}
Else {Return $Mediatorservers }