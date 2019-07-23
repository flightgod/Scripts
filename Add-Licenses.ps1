<#
6/12 - Run agains the other domains for P1 and P2 and SharePoint

Add for Each Domain
Look to see if they are already a member

#>

# Variables
$DomainController = "Euro.EvilCorpCORP.COM"
$Domains = "euro.EvilCorpcorp.com,apac.EvilCorpcorp.com"
$GC = "p016Adseqdc02.EvilCorpcorp.com:3268"

$BI = "EvilCorpsystems3:POWER_BI_STANDARD"
$SkypeP1 = "EvilCorpsystems3:MCOIMP"
$SharePointP1 = "EvilCorpsystems3:SHAREPOINTSTANDARD"
$ExchangeE2 = "EvilCorpsystems3:EXCHANGEENTERPRISE"
$ExchangeE1 = "EvilCorpsystems3:EXCHANGESTANDARD"

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
        $script:username = $Name.EvilCorpEmail
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
EvilCorpsystems3:VISIOCLIENT               1           0            1
EvilCorpsystems3:STREAM                    1000000     0            5
EvilCorpsystems3:ENTERPRISEPREMIUM         0           75           15
EvilCorpsystems3:SPZA_IW                   10000       0            0
EvilCorpsystems3:ENTERPRISEPACK            20          0            3
EvilCorpsystems3:FLOW_FREE                 10000       0            34
EvilCorpsystems3:MICROSOFT_BUSINESS_CENTER 10000       0            2
EvilCorpsystems3:POWERAPPS_VIRAL           10000       0            4
EvilCorpsystems3:EXCHANGESTANDARD          6920        200          4153
EvilCorpsystems3:DYN365_ENTERPRISE_P1_IW   10000       0            0
EvilCorpsystems3:POWER_BI_STANDARD         1000000     0            40
EvilCorpsystems3:OFFICESUBSCRIPTION        430         0            406
EvilCorpsystems3:EMS                       0           2100         0
EvilCorpsystems3:MCOIMP                    3850        0            1745
EvilCorpsystems3:AX7_USER_TRIAL            10000       0            0
EvilCorpsystems3:SHAREPOINTSTANDARD        3850        0            577
EvilCorpsystems3:PROJECTPROFESSIONAL       1           0            1
EvilCorpsystems3:EXCHANGEENTERPRISE        4250        0            3630
EvilCorpsystems3:MCOSTANDARD               50          0            13
EvilCorpsystems3:STANDARDPACK              0           800          0


#>
