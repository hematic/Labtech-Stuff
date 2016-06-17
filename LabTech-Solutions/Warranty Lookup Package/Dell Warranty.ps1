Function Get-DellWarrantyData
    {
        Param
        (
            [Int]$ComputerID,
            [String]$ComputerName,
            [String]$Manufacturer
        )

        [String]$Assettag = (Get-WMIObject -Class "Win32_BIOS" | select SerialNumber).SerialNumber
	    $warrantyinsert = "Insert INTO Warranties (``Computerid``,``Computername``, ``Manufacturer``,``Dell Entitlement Type``,``Start Date``,``End Date``,``Service Level``)"
	    
        $DellWarrantyInfo = New-Object System.Xml.XmlDocument
	    $DellWarrantyInfo.Load("https://api.dell.com/support/v2/assetinfo/warranty/tags?svctags=$assettag&apikey=d676cf6e1e0ceb8fd14e8cb69acd812d")
        $Results = $DellWarrantyInfo.GetAssetWarrantyResponse.GetAssetWarrantyResult.Response.DellAsset.Warranties.Warranty
        Foreach ($Item in $Results)
        {
            $EntitlementType = $item.EntitlementType
            $StartDate = $item.StartDate.substring(0,10)
            $EndDate = $item.EndDate.substring(0,10)
            $ServiceLevel = $item.ServiceLevelDescription

            #Checks to see if it is the first run of the loop to make sure the value statement is well formed.
	        IF ($Statement -eq $NULL)
            { 
   	 	        $Statement = " Values ('$computerid','$computername','$Manufacturer',`'$EntitlementType`',`'$StartDate`',`'$EndDate`',`'$ServiceLevel`')"
            }

	        Else
            {
    	        $Statement = $statement + ",('$computerid','$computername','$Manufacturer',`'$EntitlementType`',`'$StartDate`',`'$EndDate`',`'$ServiceLevel`')"
            }

		}

        $output = $WarrantyInsert + $Statement
        Return $output
    }


Get-DellWarrantyData