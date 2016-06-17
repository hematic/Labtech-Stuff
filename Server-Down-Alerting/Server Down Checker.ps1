#Declare Functions
#######################################################
Function Get-CWTickets
{

    Begin
    {
        [string]$BaseUri     = "$CWServerRoot" + "$Codebase" + "apis/3.0/service/tickets/$ticketID"
        [string]$Accept      = "application/vnd.connectwise.com+json; version=v2015_3"
        [string]$ContentType = "application/json"

        $Headers=@{
        'X-cw-overridessl' = "True"
        "Authorization"="Basic $encodedAuth"
        }

        $Body = @{
        "conditions" = "board/name = 'LT-Partner Support' AND type/name = 'Infrastructure' AND subType/name = 'Server Down' AND status/name = 'Code Red'"
         
        }
     }

    Process
    {   
        Try
        {   
            $JSONResponse = Invoke-RestMethod -URI $BaseURI -Headers $Headers -Body $Body  -ContentType $ContentType -Method Get
        }

        Catch
        {
            $ErrorMessage = $_.exception.message
        }

    }
    
    End
    {
        If($JSONResponse)
        {
            Return $JSONResponse
        }

        Else
        {
            Return $False
        }
    }
}

#Variable Declarations
######################################################
$ErrorActionPreference = 'Continue'
$VerbosePreference = 'SilentlyContinue'
[PSCustomObject]$Tickets = ''
[String]$CWServerRoot = "https://api-na.myconnectwise.net/"
[String]$CodeBase = (Invoke-RestMethod -uri 'http://api-na.myconnectwise.net/login/companyinfo/connectwise').codebase
[String]$Script:AssignedCode = '5790'
[Array]$Script:SelectTicketData = @()

#Credentials
#######################################################
$Global:CWInfo = New-Object PSObject -Property @{
Company = 'connectwise'
PublicKey = '4hc35v3aNRTjib9W'
PrivateKey = 'yLubF4Kfz4gWKBzU'
}
[string]$Authstring  = $CWInfo.company + '+' + $CWInfo.publickey + ':' + $CWInfo.privatekey
$encodedAuth = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes(($Authstring)));

#Gather the Tickets to display
######################################################
$Tickets = Get-CWTickets

If($Tickets -eq $False)
{
    Return 'No Tickets'
    exit;
}

Else
{
    Return 'Tickets Found'
    exit;
}