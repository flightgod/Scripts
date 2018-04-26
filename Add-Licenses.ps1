$DomainController = "P054ADSAMDC02.amer.EPIQCORP.COM"
$GC = "p016Adseqdc02.epiqcorp.com:3268"

$import = "C:\temp\E2_License.csv"
$data = Import-Csv $import

forEach ($user in $data){
    $get= Get-AdUser -Filter "UserPrincipalName -eq '$($user.UserPrincipalName)'" -Server $GC 

    Add-ADGroupMember -Identity "UG-o365-License-Exchange-P2" -Members $get.ObjectGUID -Server $GC -WhatIf
}

# Need this for Sharepoint, BI, Exchange 1 and 2

 $BI = "epiqsystems3:POWER_BI_STANDARD"
 $SkypeP1 = "epiqsystems3:MCOIMP"
 $SharePointP1 = "epiqsystems3:SHAREPOINTSTANDARD"
 $ExchangeE2 = "epiqsystems3:EXCHANGEENTERPRISE"
 $ExchangeE1 = "epiqsystems3:EXCHANGESTANDARD"

Function RemoveLicense {
    foreach ($script:Name in $import){
        $script:username = $Name.EpiqEmail
        Write-Host "Removing $E2LicAssign from $username" -ForegroundColor DarkGreen
        Set-MsolUserLicense `
            -UserPrincipalName $username `
            -RemoveLicenses $E2LicAssign
        AddLicense
    }
}


<#
AccountSkuId                           ActiveUnits WarningUnits ConsumedUnits
------------                           ----------- ------------ -------------
epiqsystems3:STREAM                    1000000     0            3
epiqsystems3:ENTERPRISEPREMIUM         75          0            40
epiqsystems3:SPZA_IW                   10000       0            0
epiqsystems3:EOP_ENTERPRISE_PREMIUM    0           0            0
epiqsystems3:ENTERPRISEPACK            2100        0            1
epiqsystems3:FLOW_FREE                 10000       0            10
epiqsystems3:MICROSOFT_BUSINESS_CENTER 10000       0            3
epiqsystems3:POWERAPPS_VIRAL           10000       0            1
epiqsystems3:EXCHANGESTANDARD          3420        0            3149
epiqsystems3:DYN365_ENTERPRISE_P1_IW   10000       0            2
epiqsystems3:POWER_BI_STANDARD         1000000     0            34
epiqsystems3:EMS                       2100        0            1
epiqsystems3:MCOIMP                    3850        0            1504
epiqsystems3:AX7_USER_TRIAL            10000       0            0
epiqsystems3:SHAREPOINTSTANDARD        3850        0            133
epiqsystems3:EXCHANGEENTERPRISE        3850        0            3494
epiqsystems3:MCOSTANDARD               50          0            1
epiqsystems3:STANDARDPACK              800         0            0


#>