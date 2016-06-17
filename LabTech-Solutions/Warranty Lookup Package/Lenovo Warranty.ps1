Function Get-LenovoWarrantyData
{
    [CmdLetBinding()]
    Param
    (
        [String]$SerialNumber
    )

    #Link Lenovo's website w/ Warranty retrieval form.
    $siteLink = "http://support.lenovo.com/us/en/warrantylookup";

    #Opens IE and grabs the results
    $ie = New-Object -ComObject "InternetExplorer.Application";
    $ie.Visible = $True;

    #Opens Lenovo Page to enter the Serial, inputs the serial, and submits the form.
    $ie.Navigate($siteLink) | Out-Null;
    While ($ie.Busy) { Sleep 10; }
    Sleep 2; 
    $doc = $ie.Document;
    $ele = [System.__ComObject].InvokeMember(“getElementById”,[System.Reflection.BindingFlags]::InvokeMethod, $null, $doc, 'serialCode');
    $ele.Value = $SerialNumber;
    Sleep 2; 
    $btn = [System.__ComObject].InvokeMember(“getElementById”,[System.Reflection.BindingFlags]::InvokeMethod, $null, $doc, 'warrantySubmit');
    $btn.Click();
    While ($ie.Busy) { Sleep 5; }

    
    #Check if Lenovo returned an error(s). 
    $doc = $ie.Document;
    $err = [System.__ComObject].InvokeMember(“getElementById”,[System.Reflection.BindingFlags]::InvokeMethod, $null, $doc, 'verify_tip');
    If ($err.innerText -ne $null) 
    { 
        $ie.Quit() | Out-Null;
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($ie) | Out-Null;
        Remove-Variable ie | Out-Null;
        Return $null; 
    } 

    $loading   = $True;
    $loopCount = 0;
    While($loading -and $loopCount -lt 10)
    {
        #Gets the raw warranty text from the page.
        Sleep 2;
        $doc     = $ie.Document;
        $data    = [System.__ComObject].InvokeMember(“getElementById”,[System.Reflection.BindingFlags]::InvokeMethod, $null, $doc, 'resultDiv');
        $loading = $data.innerText -eq $null;

        $loopCount++;
    }

    #Finds all the upper boundries for all the different warranty types for a device.
    $allWarrartyText = $data.innerText;

    #Prepares some variables that will be used by RegEx static methods during the next For-loop. 
    $RegExOptions = [System.Text.RegularExpressions.RegexOptions]::Multiline;
    $RegExTimeOut = [System.TimeSpan]::FromSeconds(3);

    #Variable to store the results of the warranty lookup. 
    $Results      = [Array]@();

    #Extracts all the data for the respective property of the warranty type.
    $type     = [RegEx]::Match($allWarrartyText,'Warranty Type: [\n|\r]* \b(.+)\b', $RegExOptions, $RegExTimeOut).Groups[1].Value.Trim();
    $status   = [RegEx]::Match($allWarrartyText,'Status: [\n|\r]* \b(.+)\b', $RegExOptions, $RegExTimeOut).Groups[1].Value.Trim();
    $start    = [RegEx]::Match($allWarrartyText,'Start Date: [\n|\r]* \b(.+)\b', $RegExOptions, $RegExTimeOut).Groups[1].Value.Trim();
    $end      = [RegEx]::Match($allWarrartyText,'End Date: [\n|\r]* \b(.+)\b', $RegExOptions, $RegExTimeOut).Groups[1].Value.Trim();
    $dis      = [RegEx]::Match($allWarrartyText,'Description: [\n|\r]*\b(.+\b\.)', $RegExOptions, $RegExTimeOut).Groups[1].Value.Trim();

    $obj = [PSCustomObject][Ordered] @{
        WarrantyType = $type
        Status       = $status
        StartDate    = $start
        EndDate      = $end
        Description  = $dis
    }

    $Results += $obj;

    #Quits IE, disposes the ComObject, and deletes variable for IE. 
    $ie.Quit() | Out-Null;
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($ie) | Out-Null;
    Remove-Variable ie | Out-Null;

    #Return the data back!!!
    Return $Results;
}

Try 
{
    $ERRORLOGPATH = "C:\Windows\Temp\LT_LenovoWarrantyLookupError.log";
    #Grabs the Serial
    $Serial = 'MJDgze4';

    $WarrantyData = Get-LenovoWarrantyData -SerialNumber $Serial
}
Catch 
{
    #Makes a two attempt to retrieve the data just incase browser issues.
    Try
    {
        #Makes an attempt to alog the error to the Window's temp directory.
        $exceptions   = $_;
        Out-File -InputObject $exceptions -LiteralPath $ERRORLOGPATH -ErrorAction SilentlyContinue -Append;

        #Sleep for a minute and try again. 
        Sleep 60;
        $WarrantyData = Get-LenovoWarrantyData -SerialNumber $Serial;
    }
    Catch
    {
        #Makes an attempt to alog the error to the Window's temp directory.
        Out-File "Failed 2 times in a row. Returning `$null. - Serial Number Parameter = $Serial" -Append;
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
        #Insert your code here... Delete these lines.
        #$WarrantyData | FT * -AutoSize;
    } 
    Else
    {
        Write-Host "You fail at life!";
    }

}
