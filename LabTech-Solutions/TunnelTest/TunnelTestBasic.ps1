$TunnelTestArgs = "/M uswest.mediator.labtechsoftware.com"
$TunnelTestPath = "C:\Users\pmarshall\Documents\TunnelTester\TunnelTest.exe"
$OutputPath = "C:\Users\pmarshall\Documents\TunnelTester\TunnelTest.txt"


Get-Process tunneltest* | Stop-Process -force

$Process = Start-Process "$tunneltestpath" -ArgumentList "$TunnelTestArgs & exit" -NoNewWindow -PassThru -RedirectStandardOutput "$OutputPath"

Write-host "Process ID = $($Process.id)"
Wait-Process -id $Process.ID -timeout 5

if (!$Process.hasExited)
{
	taskkill /T /F /PID $Process.ID
	Return "Mediator testing timed out"
	exit;
}

Else
{
	[String]$Content = Get-Content $OutputPath
	
	If ($Content -like '*Tunnels Connected*' ) { Return 1; Exit; }
	
	Else { Return $Results; Exit; }
}

