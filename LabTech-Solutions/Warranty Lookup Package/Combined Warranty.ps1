Function WarrantyCheck
{

            Function DellWarranty
            {
                #Dell stores Asset Tags in the BIOS S/N field.
	            $assettag = (Get-WMIObject -Class "Win32_BIOS" | select SerialNumber).SerialNumber 
	            #Builds the first part of the insert for the DellWarranties table.
	            $WarrantyInsert = "REPLACE INTO DellWarranties (ComputerID,ComputerName,ServiceLevelDescription,EntitlementType,WarrantyStart,WarrantyEnd)"
	            $DellWarrantyInfo = New-Object System.Xml.XmlDocument
	            $DellWarrantyInfo.Load("https://api.dell.com/support/v2/assetinfo/warranty/tags?svctags=$assettag&apikey=d676cf6e1e0ceb8fd14e8cb69acd812d")
                #Creates an XML object and then loads the reply from the web server into that object.
	            $Results = $DellWarrantyInfo.GetAssetWarrantyResponse.GetAssetWarrantyResult.Response.DellAsset.Warranties.Warranty | % {
                #ForEach loop to pull the values for each listed warranty.
                $EntitlementType = $_.EntitlementType
                $ServiceLevelDescription = $_.ServiceLevelDescription
                $StartDate = $_.StartDate.substring(0,10)
                $EndDate = $_.EndDate.substring(0,10)
                #Checks to see if it is the first run of the loop to make sure the value statement is well formed.
	            IF ($Statement -eq $NULL){ 
   	 	            $Statement = " Values ('%computerid%','%computername%',`'$ServiceLevelDescription`',`'$EntitlementType`',`'$StartDate`',`'$EndDate`')"}
	            Else{
    	            $Statement = $statement + ",('%computerid%','%computername%',`'$ServiceLevelDescription`',`'$EntitlementType`',`'$StartDate`',`'$EndDate`')"}
		            }
                $output = $WarrantyInsert + $Statement
                Return $output

            }

            Function LenovoWarranty
            {
            
                #Builds the first part of the insert for the DellWarranties table.
		        $WarrantyInsert = "REPLACE INTO LenovoWarranties (ComputerID,ComputerName,WarrantyEnd)"
		        #Grabs the Model
		        $currentType = (Get-WmiObject Win32_ComputerSystem).Model
		        #Grabs the Serial
		        $currentSerial = (Get-WmiObject Win32_Bios).SerialNumber
		        #Specifies the warranty lookup page and pulls the page into the $results variable.
		        $URL = "https://csp.lenovo.com/ibapp/il/WarrantyStatus.jsp?&serial=$currentSerial&type=$currentType"
		        $results = Invoke-RestMethod -Uri $URL -TimeoutSec 15;
				If($Results){       
					#"End Date:&nbsp;" is the last part of the file before the Warranty Date
        			#We split the file here so that we can easily pull out the Warranty date without Reg-Ex.
       				$Split = $results -split "End Date:&nbsp;</b>"
       					If($Split[1])
       						{
             	 				$char = $Split[1].IndexOf("</td>");
              					$EndDate = $Split[1].Substring(0,$char);
			  					$Statement = " Values ('%computerid%','%computername%',`'$EndDate`')"
                                $output = $WarrantyInsert + $Statement
			  					Return $output
              				}
       					else{
              					$Output = "No end date detected!";
              					Return $output
       						}	
	   						}
	   					else{
	   							$Output = "No data returned from Rest method attempt";
       							Return $output
							}
            
            
            }

            Function HPWarranty
            {
				$WarrantyInsert = "REPLACE INTO HPWarranties (ComputerID,ComputerName,WarrantyEnd)"
				#Grabs the Model
			    $Model = (Get-ItemProperty "HKLM:\HARDWARE\DESCRIPTION\System\BIOS").systemsku
				#Grabs the Serial
				$Serial = (Get-WmiObject Win32_Bios).SerialNumber
				#Builds the link
				$link = "http://h10025.www1.hp.com/ewfrf/wc/weInput?cc=us&lc=en"
				#Opens IE and grabs the results
				$ie = new-object -com "InternetExplorer.Application"
				$ie.navigate($link)
				$ie.visible = $false
				while($ie.busy) {sleep 1}
				$ie.Document.getElementByID('serialnum').value = $Serial
				$ie.Document.getElementByID('prodname').value = $Model
				$ie.Document.getElementByID('Continue').Click()
				While($ie.Document.URL –notlike ‘*http://h10025.www1.hp.com/ewfrf/wc/weResults*’) { sleep 1 }
				[string]$Contents = $ie.Document.body.innerHTML;
				$Precursor = $Contents.IndexOf("&nbsp;(YYYY-MM-DD)");
				$EndDate = $Contents.Substring($Precursor-10,10);
				$Statement = " Values ('%computerid%','%computername%',`'$EndDate`')"
                $output = $WarrantyInsert + $Statement
                Return $output
			}

            Function WarrantyReturn
            {

                Param (
                    [STRING]$Output
                )
                #Combines the insert and value statements for a complete SQL insert.
				out-file -filepath C:\Windows\Temp\Warranty.txt -InputObject $Output
	            Write-Output $Manufacturer
            
            }

    #This section defines the Manufacturer which allows us to decide what else to do.
    $Manufacturer = (Get-WMIObject -Class "Win32_BIOS" | select Manufacturer).Manufacturer

    IF($Manufacturer -eq "Dell")
    {
       WarrantyReturn DellWarranty
    }

    IF($Manufacturer -eq "Lenovo")
    {
        WarrantyReturn LenovoWarranty
    }

    IF($Manufacturer -eq "Hewlett-Packard")
    {
        WarrantyReturn HPWarranty
    }     



}

WarrantyCheck

