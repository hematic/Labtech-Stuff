#Declare Functions
#######################################################
function Load-DataGridView
{
	Param (
		[ValidateNotNull()]
		[Parameter(Mandatory=$true)]
		[System.Windows.Forms.DataGridView]$DataGridView,
		[ValidateNotNull()]
		[Parameter(Mandatory=$true)]
		$Item,
	    [Parameter(Mandatory=$false)]
		[string]$DataMember
	        )

	$DataGridView.SuspendLayout()
	$DataGridView.DataMember = $DataMember
	
	if ($Item -is [System.ComponentModel.IListSource]`
	-or $Item -is [System.ComponentModel.IBindingList]`
    -or $Item -is [System.ComponentModel.IBindingListView] )
	{
		$DataGridView.DataSource = $Item
	}

	else
	{
		$array = New-Object System.Collections.ArrayList
		
		if ($Item -is [System.Collections.IList])
		{
			$array.AddRange($Item)
		}

		else
		{	
			$array.Add($Item)	
		}

		$DataGridView.DataSource = $array
	}
	
	$DataGridView.ResumeLayout()
}

function ConvertTo-DataTable
{

	[OutputType([System.Data.DataTable])]
	param(
	[ValidateNotNull()]
	$InputObject, 
	[ValidateNotNull()]
	[System.Data.DataTable]$Table,
	[switch]$RetainColumns,
	[switch]$FilterWMIProperties)
	
	if($Table -eq $null)
	{
		$Table = New-Object System.Data.DataTable
	}

	if($InputObject-is [System.Data.DataTable])
	{
		$Table = $InputObject
	}
	else
	{
		if(-not $RetainColumns -or $Table.Columns.Count -eq 0)
		{
			#Clear out the Table Contents
			$Table.Clear()

			if($InputObject -eq $null){ return } #Empty Data
			
			$object = $null
			#find the first non null value
			foreach($item in $InputObject)
			{
				if($item -ne $null)
				{
					$object = $item
					break	
				}
			}

			if($object -eq $null) { return } #All null then empty
			
			#Get all the properties in order to create the columns
			foreach ($prop in $object.PSObject.Get_Properties())
			{
				if(-not $FilterWMIProperties -or -not $prop.Name.StartsWith('__'))#filter out WMI properties
				{
					#Get the type from the Definition string
					$type = $null
					
					if($prop.Value -ne $null)
					{
						try{ $type = $prop.Value.GetType() } catch {}
					}

					if($type -ne $null) # -and [System.Type]::GetTypeCode($type) -ne 'Object')
					{
		      			[void]$table.Columns.Add($prop.Name, $type) 
					}
					else #Type info not found
					{ 
						[void]$table.Columns.Add($prop.Name) 	
					}
				}
		    }
			
			if($object -is [System.Data.DataRow])
			{
				foreach($item in $InputObject)
				{	
					$Table.Rows.Add($item)
				}
				return  @(,$Table)
			}
		}
		else
		{
			$Table.Rows.Clear()	
		}
		
		foreach($item in $InputObject)
		{		
			$row = $table.NewRow()
			
			if($item)
			{
				foreach ($prop in $item.PSObject.Get_Properties())
				{
					if($table.Columns.Contains($prop.Name))
					{
						$row.Item($prop.Name) = $prop.Value
					}
				}
			}
			[void]$table.Rows.Add($row)
		}
	}

	return @(,$Table)	
}

Function Update-CWTicketStatus
{

    [cmdletbinding()]
    
    param
    (
    	[Parameter(Mandatory = $true,Position = 0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [ValidateNotNullorEmpty()]
		[INT]$TicketID
    )

    Begin
    {
        [string]$BaseUri     = "$CWServerRoot" + "$Codebase" + "apis/3.0/service/tickets/$ticketID"
        [string]$Accept      = "application/vnd.connectwise.com+json; version=v2015_3"
        [string]$ContentType = "application/json"

        $Headers=@{
            'X-cw-overridessl' = "True"
            "Authorization"="Basic $encodedAuth"
            }
        
        $Body= @"
        [
        {"op" : "replace", "path": "/status/id", "value": "11066"}
        ]
"@
     }
    
    Process
    {      
        $JSONResponse = Invoke-RestMethod -URI $BaseURI -Headers $Headers -Body $Body -ContentType $ContentType -Method Patch
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

Function Update-CWTicketResource
{

    [cmdletbinding()]
    
    param
    (
    	[Parameter(Mandatory = $true,Position = 0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [ValidateNotNullorEmpty()]
		[INT]$TicketID
    )

    Begin
    {
        [string]$BaseUri     = "$CWServerRoot" + "$Codebase" + "apis/3.0/schedule/entries/"
        [string]$Accept      = "application/vnd.connectwise.com+json; version=v2015_3"
        [string]$ContentType = "application/json"

        $Headers=@{
            'X-cw-overridessl' = "True"
            "Authorization"="Basic $encodedAuth"
            }
        
        $Body= @"
        {
            "objectid" : $Ticketid,
            "member" : {"identifier" : "$env:username"},
            "type"   : {"identifier" : "S"}
        }

"@
     }
    
    Process
    {      
        $JSONResponse = Invoke-RestMethod -URI $BaseURI -Headers $Headers -Body $Body -ContentType $ContentType -Method Post
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

Function Get-CWTicket
{
    [cmdletbinding()]
    
    param
    (
    	[Parameter(Mandatory = $true,Position = 0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [ValidateNotNullorEmpty()]
		[INT]$TicketID
    )

    Begin
    {
    [string]$BaseUri     = "$CWServerRoot" + "$Codebase" + "apis/3.0/service/tickets/$ticketID"
    [string]$Accept      = "application/vnd.connectwise.com+json; version=v2015_3"
    [string]$ContentType = "application/json"

    $Headers=@{
        'X-cw-overridessl' = "True"
        "Authorization"="Basic $encodedAuth"
        }
     }
    
    Process
    {   
        Try
        {   
            $JSONResponse = Invoke-RestMethod -URI $BaseURI -Headers $Headers  -ContentType $ContentType -Method Get
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

function Claim-Ticket
{

    $TicketData = Get-CWTicket -TicketID $Script:TicketID

    If(!$TicketData)
    {
        Write-verbose "Well Fuck. So. Bad news..that ticket doesn't exist. Ticketid = $Script:Ticketid"
        $richTextBox1.Text += "Lookup of ticket $Script:TicketID failed.`n"
        Return "Failure"
    }

    Else
    {
        If(!$TicketData.resources)
        {
             $richTextBox1.Text += "No Resource currently assigned to ticket id $Script:TicketID`n"

            #Changing the ticket Status to assigned.
            $ChangeStatus = Update-cwticketStatus -TicketID $Script:TicketID

            if($ChangeStatus.status.id -ne $Script:AssignedCode)
            {
	            $richTextBox1.Text += "Failed to update the ticket status to assigned.`n"
	            Return "Failure"
            }

            Else
            {
	            $richTextBox1.Text += "Status updated to assigned. for ticket $Script:TicketID`n"
	        }

            $ClaimTicket = Update-CWTicketResource -TicketID $Script:TicketID

            If($($ClaimTicket.member.identifier) -eq $env:USERNAME)
            {
                $richTextBox1.Text += "Ticket $Script:TicketID claimed for user $Env:username`n"
                Return "Success"
            }

            Else
            {
                $richTextBox1.Text += "Claiming Ticket $Script:TicketID FAILED for user $Env:username`n"
                Return "Failure"
            }
        }

        Else
        {
            $richTextBox1.Text += "Ticket $Script:TicketID was claimed by $($TicketData.resources) already.`n"
            Return "Success"
        }
    }


}

function Open-Ticket
{
    Param
    (
        [Parameter(Mandatory = $true,Position = 0,ValueFromPipeline,ValueFromPipelineByPropertyName)]
        [ValidateNotNullorEmpty()]
		[String]$TicketLink
    )

    #Start-Process is used because it attaches to the default browser. 
    #If an instance is open it makes a new tab.
    #If no instance is open it makes a new window.
    Start-Process $Script:Ticketlink
    $richTextBox1.Text += "Ticket $Script:TicketID has been opened.`n"
}


#Variable Declarations
######################################################
$ErrorActionPreference = 'Continue'
$VerbosePreference = 'SilentlyContinue'
[PSCustomObject]$Tickets = ''
[String]$CWServerRoot = "https://api-na.myconnectwise.net/"
[String]$CodeBase = (Invoke-RestMethod -uri 'http://api-na.myconnectwise.net/login/companyinfo/connectwise').codebase
[String]$Script:AssignedCode = '11066'
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

#This section will prevent a pop-up with an empty datagrid view if one 
#machine is slow to load and someone else claimed the ticket already.
If ($Tickets -eq $False)
{
    write-output "Nothing to see here"
    exit;
}

#Declare the Form and Properties
#######################################################
$form1 = New-Object System.Windows.Forms.Form
$form1.Text = "SERVER DOWN TICKET NOTIFIER"
$form1.Size = New-Object System.Drawing.Size(700,325)
$form1.StartPosition = "CenterScreen"
$form1.KeyPreview = $True
$form1.MaximumSize = $form1.Size
$form1.MinimumSize = $form1.Size
#######################################################

#Declare the DataGridView
#######################################################
$dataGridView1 = New-Object System.Windows.Forms.DataGridView
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 550
$System_Drawing_Size.Height = 100
$dataGridView1.Size = $System_Drawing_Size
$dataGridView1.DataBindings.DefaultDataSourceUpdateMode = 0
$dataGridView1.Name = "dataGrid1"
$dataGridView1.DataMember = ""
$dataGridView1.TabIndex = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 10
$System_Drawing_Point.Y = 10
$dataGridView1.Location = $System_Drawing_Point
$dataGridView1.SelectionMode = "FullRowSelect"
$dataGridView1.readonly = $True
$dataGridView1.multiselect = $False
$datagridview1.add_Click($datagridview1_Click)
$form1.Controls.Add($DataGridView1)

#Define values that are loaded when clicking on a row.
$datagridview1_Click={
	$Script:Ticketlink     = $($dataGridView1.SelectedRows.cells[0].formattedValue)
    $Script:TicketSubject  = $($dataGridView1.SelectedRows.cells[1].formattedValue)
    $Script:TicketID       = $($dataGridView1.SelectedRows.cells[2].formattedValue)
    $Script:TicketCompany  = $($dataGridView1.SelectedRows.cells[3].formattedValue)
}

#Declare the buttons
#######################################################

#This button claims a ticket.
$Claim_Button = new-object System.Windows.Forms.Button
$Claim_Button.Location = new-object System.Drawing.Size(575,20)
$Claim_Button.Size = new-object System.Drawing.Size(80,30)
$Claim_Button.Text = "Claim Ticket"
$Claim_Button.Add_MouseHover({$Claim_Button.backcolor = [System.Drawing.Color]::CornflowerBlue})
$Claim_Button.Add_MouseLeave({$Claim_Button.backcolor = [System.Drawing.Color]::White})
$Claim_Button.Add_Click({Claim-Ticket -TicketID $Script:TicketID})
$Form1.Controls.Add($Claim_Button)

#This button opens a web link to a ticket.
$WebLink_Button = new-object System.Windows.Forms.Button
$WebLink_Button.Location = new-object System.Drawing.Size(575,60)
$WebLink_Button.Size = new-object System.Drawing.Size(80,30)
$WebLink_Button.Text = "Web Link"
$WebLink_Button.Add_MouseHover({$WebLink_Button.backcolor = [System.Drawing.Color]::CornflowerBlue})
$WebLink_Button.Add_MouseLeave({$WebLink_Button.backcolor = [System.Drawing.Color]::White})
$WebLink_Button.Add_Click({Open-Ticket -TicketLink $Script:Ticketlink})
$Form1.Controls.Add($WebLink_Button)

#Declare the RichTextBox that output goes into
$richTextBox1 = New-Object System.Windows.Forms.RichTextBox
$richTextBox1.Text = ''
$richTextBox1.TabIndex = 2
$richTextBox1.Name = 'richTextBox1'
$richTextBox1.Font = New-Object System.Drawing.Font("Courier New",10,0,3,0)
$System_Drawing_Size = New-Object System.Drawing.Size
$System_Drawing_Size.Width = 550
$System_Drawing_Size.Height = 155
$richTextBox1.Size = $System_Drawing_Size
$richTextBox1.DataBindings.DefaultDataSourceUpdateMode = 0
$System_Drawing_Point = New-Object System.Drawing.Point
$System_Drawing_Point.X = 10
$System_Drawing_Point.Y = 120
$richTextBox1.Location = $System_Drawing_Point
 
$form1.Controls.Add($richTextBox1)

#Builds the object that is going to get converted and displayed in the datagridview.
ForEach($Ticket in $Tickets)
{
    $Script:SelectTicketData += New-Object PSObject -Property @{
	    TicketID = [String]$Ticket.id;
	    Title = [String]$Ticket.summary;
	    Company = [String]$Ticket.company.identifier
	    Link = "https://cw.connectwise.net/v4_6_release/services/system_io/Service/fv_sr100_request.rails?service_recid=$($Ticket.id)&companyName=ConnectWise";
    }
}

#Does the work of converting the object and loading the data in the DGV.    
$ConvertedData = ConvertTo-DataTable -InputObject $SelectTicketData
Load-DataGridView -DataGridView $datagridview1 -Item $ConvertedData

#Sort the Columns in the order we want to display them.
$DataGridView1.Columns[1].DisplayIndex = 2   #Makes Title Third
$DataGridView1.Columns[2].DisplayIndex = 0   #Makes TicketID First
$DataGridView1.Columns[3].DisplayIndex = 1   #Makes Company Second

#Hide the Link to the Ticket
$datagridview1.columns[0].visible = $False

#Autosize the columns to not look dumb.
$datagridview1.columns[1].autosizemode = [System.Windows.Forms.DataGridViewAutoSizeColumnMode]::AllCells
$datagridview1.columns[2].autosizemode = [System.Windows.Forms.DataGridViewAutoSizeColumnMode]::AllCells
$datagridview1.columns[3].autosizemode = [System.Windows.Forms.DataGridViewAutoSizeColumnMode]::AllCells

#Setting default values for the buttons in case the user never clicks a row.
$Script:Ticketlink     = $($dataGridView1.Rows[0].Cells[0].FormattedValue)
$Script:TicketSubject  = $($dataGridView1.Rows[0].Cells[1].FormattedValue)
$Script:TicketID       = $($dataGridView1.Rows[0].Cells[2].FormattedValue)
$Script:TicketCompany  = $($dataGridView1.Rows[0].Cells[3].FormattedValue)

[void] $form1.ShowDialog()