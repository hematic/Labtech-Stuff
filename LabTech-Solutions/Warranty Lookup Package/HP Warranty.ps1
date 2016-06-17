Function Get-HPWarrantyData
{
    [CmdLetBinding()]
    Param
    (
        [String]$SerialNumber
    )

    #Link HP's website w/ Warranty retrieval form.
    $siteLink = "http://h20564.www2.hp.com/hpsc/wc/public/home";

    #Opens IE and grabs the results
    $ie = New-Object -ComObject "InternetExplorer.Application";
    $ie.Visible = $True;

    #Opens HP Page to enter the Serial, inputs the serial, and submits the form.
    $ie.Navigate($siteLink) | Out-Null;
    While ($ie.Busy) { Sleep 10; }
    Sleep 2; 
    $doc = $ie.Document;
    $ele = [System.__ComObject].InvokeMember(“getElementById”,[System.Reflection.BindingFlags]::InvokeMethod, $null, $doc, 'serialNumber0');
    $ele.Value = $SerialNumber;
    Sleep 2 | Out-Null;
    $btn = @([System.__ComObject].InvokeMember(“getElementsByName”,[System.Reflection.BindingFlags]::InvokeMethod, $null, $doc, 'submitButton'))[0];
    $btn.Click();
    While ($ie.Busy) { Sleep 10; }

    #Check if HP returned an error(s). 
    $doc = $ie.Document;
    $err = @([System.__ComObject].InvokeMember(“getElementsByClassName”,[System.Reflection.BindingFlags]::InvokeMethod, $null, $doc, 'hpui-form-errors'));
    If ([int]$err.Count -gt 0) 
    { 
        $ie.Quit() | Out-Null;
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($ie) | Out-Null;
        Remove-Variable ie | Out-Null;
        Return $null; 
    } 
 
    #Goes to the details page of the warranty.
    $doc = $ie.Document;
    $ie.Navigate('http://h20564.www2.hp.com/hpsc/wc/public/viewDetails?index=0') | Out-Null;
    While ($ie.Busy) { Sleep 10; }

    #Retrieves the warranty data as plan text and parses it.
    $doc = $ie.Document;
    $allWarrartyHTML = [System.__ComObject].InvokeMember(“getElementById”,[System.Reflection.BindingFlags]::InvokeMethod, $null, $doc, 'introBlock');

    #Finds all the upper boundries for all the different warranty types for a device.
    $allWarrartyText = $allWarrartyHTML.innerText.Replace("`r", "").Split("`n");

    $sectionsBounderies = @();
    For($i=0; $i -lt $allWarrartyText.Count; $i++)
    {
        If($allWarrartyText[$i] -match 'Service type:')
        {
            $sectionsBounderies += $i;
        }
    }
    $sectionsBounderies += $allWarrartyText.Count;

    #Prepares some variables that will be used by RegEx static methods during the next For-loop. 
    $RegExOptions = [System.Text.RegularExpressions.RegexOptions]::Multiline;
    $RegExTimeOut = [System.TimeSpan]::FromSeconds(3);

    #Variable to store the results of the warranty lookup. 
    $Results      = @();

    #Goes through each warranty type for the device and retrieves its data.
    For($i=0; $i -lt $sectionsBounderies.Count - 1; $i++)
   {
        #Finds the upper and lower boundery for each warranty type.
        $upperBoundary = [int]$sectionsBounderies[$i];
        $lowerBoundary = [int]$sectionsBounderies[$i+1]-1;
        $warrantyLines = $allWarrartyText[$upperBoundary..$lowerBoundary];

        #Converts the text of data for an individual warranty type into a single string but maintains it structions for regexing purposes.
        $warrantyText = [String]::Join("`n",$warrantyLines);

        #Extracts all the data for the respective property of the warranty type.
        $type     = [RegEx]::Match($warrantyText,'Service type: +(.+?)\n', $RegExOptions, $RegExTimeOut).Groups[1].Value.Trim();
        $status   = [RegEx]::Match($warrantyText,'Status: +(.+?)\n', $RegExOptions, $RegExTimeOut).Groups[1].Value.Trim();
        $start    = [RegEx]::Match($warrantyText,'Start date: +(.+?)\n', $RegExOptions, $RegExTimeOut).Groups[1].Value.Trim();
        $end      = [RegEx]::Match($warrantyText,'End date: +(.+?)\n', $RegExOptions, $RegExTimeOut).Groups[1].Value.Trim();
        $level    = [RegEx]::Match($warrantyText,'Service level: +([\w \n]+?^\n)', $RegExOptions, $RegExTimeOut).Groups[1].Value.Trim();;
        $level    = [String]::Join(", ", $level.Split("`n"));
        $delivery = [RegEx]::Match($warrantyText,'Deliverables: +([\w \n]+)', $RegExOptions, $RegExTimeOut).Groups[1].Value.Trim()
        $delivery = [String]::Join(", ", $delivery.Split("`n"));

        $obj = [PSCustomObject][Ordered] @{
            ServiceType  = $type
            Status       = $status
            StartDate    = $start
            EndDate      = $end
            ServiceLevel = $level
            Deliverables = $delivery
        }

        $Results += $obj;

        #Cleans up variables so that the data from one warranty type doesn't bleed into the next if problems occurs. 
        Remove-Variable upperBoundary, lowerBoundary, warrantyLines, warrantyText, type, status, start, end, level, delivery, obj | Out-Null;
    }

    #Quits IE, disposes the ComObject, and deletes variable for IE. 
    $ie.Quit() | Out-Null;
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($ie) | Out-Null;
    Remove-Variable ie | Out-Null;

    #Return the data back!!!
    Return $Results;
}

Try 
{
    $ERRORLOGPATH = "C:\Windows\Temp\LT_HPWarrantyLookupError.log";
    #Grabs the Model & Serial
    #$Model = 'B0L93PA';
    $Serial = 'AUB823001H';

    $WarrantyData = Get-HPWarrantyData -SerialNumber $Serial
}
Catch 
{
    #Since sometimes for reason beyond our control, HP site will not process correctly. Therefore, 
    #... we make a second attempt to retrieve the data.
    Try
    {
        #Makes an attempt to alog the error to the Window's temp directory.
        $exceptions   = $_;
        Out-File -InputObject $exceptions -LiteralPath $ERRORLOGPATH -ErrorAction SilentlyContinue -Append;

        #Sleep for a minute and try again. 
        Sleep 60;
        $WarrantyData = Get-HPWarrantyData -SerialNumber $Serial;
    }
    Catch
    {
        #Makes an attempt to alog the error to the Window's temp directory.
        Out-File "Failed 2 times a row. Returning `$null. - Serial Number Parameter = $Serial" -Append;
        $exceptions   = $_;
        Out-File -InputObject $exceptions -LiteralPath $ERRORLOGPATH -ErrorAction SilentlyContinue -Append;
        $WarrantyData = $null;
    }
}
Finally
{
    
    #Checks if any $WarrantyData is $null before processing the data.
    IF ($WarrantyData -ne $null)
    {
        $warrantyinsert = "Insert INTO Warranties (``Computerid``,``Computername``, ``Manufacturer``, ``HP Service Type``,``HP Status``,``Start Date``,``End Date``,``Service Level``,``Deliverables``) VALUES "

        For($i=0; $i -lt $warrantydata.Count; $i++)
        {
            $WarrantyProps = "('" + $ComputerID + "','" + $ComputerName + "','" + $Manufacturer + "','" + $WarrantyData[$i].servicetype + "','" + $WarrantyData[$i].status + "','" + $WarrantyData[$i].startdate + "','" + $WarrantyData[$i].enddate + "','" + $WarrantyData[$i].servicelevel + "','" + $WarrantyData[$i].deliverables + "'" + ')'
            $WarrantyValues = $WarrantyValues + ',' + $WarrantyProps
            $insert = $warrantyinsert + $WarrantyValues
    
        }
    } 
    Else
    {
        Write-Host "You fail at life!";
    }

}
