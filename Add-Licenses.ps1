<#
6/12 - Run agains the other domains for P1 and P2 and SharePoint

Add for Each Domain
Look to see if they are already a member

#>

# Variables
$DomainController = "Euro.EPIQCORP.COM"
$Domains = "euro.epiqcorp.com,apac.epiqcorp.com"
$GC = "p016Adseqdc02.epiqcorp.com:3268"

$BI = "epiqsystems3:POWER_BI_STANDARD"
$SkypeP1 = "epiqsystems3:MCOIMP"
$SharePointP1 = "epiqsystems3:SHAREPOINTSTANDARD"
$ExchangeE2 = "epiqsystems3:EXCHANGEENTERPRISE"
$ExchangeE1 = "epiqsystems3:EXCHANGESTANDARD"

Function Import {
    $import = "C:\temp\E2_License.csv"
    $data = Import-Csv $import
}

Function AddLicenseGroupP2 {
    forEach ($user in $data){
        Get-ADUser -Filter "UserPrincipalName -eq '$($user.UserPrincipalName)'" | `
        % {Add-ADGroupMember -Identity "UG-o365-License-Exchange-P2" -Members $_ -Server $DomainController} 
    }
}

Function AddLicenseGroupP1 {
    forEach ($user in $data){
        Get-ADUser -Filter "UserPrincipalName -eq '$($user.UserPrincipalName)'" | `
        % {add-ADGroupMember -Identity "UG-o365-License-Exchange-P1" -Members $_ -Server $DomainController} 
    }
}


Function RemoveLicense {
    foreach ($script:Name in $import){
        $script:username = $Name.EpiqEmail
        Write-Host "Removing $E2LicAssign from $username" -ForegroundColor DarkGreen
        Set-MsolUserLicense `
            -UserPrincipalName $username `
            -RemoveLicenses $SharePointP1
    }
}


<#
Get-MsolAccountSku
AccountSkuId                           ActiveUnits WarningUnits ConsumedUnits
------------                           ----------- ------------ -------------
epiqsystems3:VISIOCLIENT               1           0            1
epiqsystems3:STREAM                    1000000     0            5
epiqsystems3:ENTERPRISEPREMIUM         0           75           15
epiqsystems3:SPZA_IW                   10000       0            0
epiqsystems3:ENTERPRISEPACK            20          0            3
epiqsystems3:FLOW_FREE                 10000       0            34
epiqsystems3:MICROSOFT_BUSINESS_CENTER 10000       0            2
epiqsystems3:POWERAPPS_VIRAL           10000       0            4
epiqsystems3:EXCHANGESTANDARD          6920        200          4153
epiqsystems3:DYN365_ENTERPRISE_P1_IW   10000       0            0
epiqsystems3:POWER_BI_STANDARD         1000000     0            40
epiqsystems3:OFFICESUBSCRIPTION        430         0            406
epiqsystems3:EMS                       0           2100         0
epiqsystems3:MCOIMP                    3850        0            1745
epiqsystems3:AX7_USER_TRIAL            10000       0            0
epiqsystems3:SHAREPOINTSTANDARD        3850        0            577
epiqsystems3:PROJECTPROFESSIONAL       1           0            1
epiqsystems3:EXCHANGEENTERPRISE        4250        0            3630
epiqsystems3:MCOSTANDARD               50          0            13
epiqsystems3:STANDARDPACK              0           800          0


#>