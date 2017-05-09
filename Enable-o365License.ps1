<#  
.SYNOPSIS
   	Enable o365 License for Migration

.DESCRIPTION  
    This script Reads the List of users to migrate to o365 and enables thier licensing and location Correctly

.NOTES  
    Current Version     	: 1.0
    
    History			        : 1.0 - Posted 5/9/2017 - First iteration - kbennett 

        
    Rights Required		    : Exchange Permissions to Add/Edit Mailbox
				            : o365 Permissions for powershell and updating users permissions
                        	: Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     	: Better Error Checking

.FUNCTIONALITY
    Add Contacts, Update User Defined Field, List old Users
#>


# Variables
$ExchangeOnlineSku = New-MsolLicenseOptions `
    -AccountSkuId `
    epiqsystems3:ENTERPRISEPACK `
    -DisabledPlans `
    Deskless, `
    FLOW_O365_P2, `
    POWERAPPS_O365_P2, `
    TEAMS1, `
    PROJECTWORKMANAGEMENT, `
    SWAY, `
    INTUNE_O365, `
    YAMMER_ENTERPRISE, `
    RMS_S_ENTERPRISE, `
    OFFICESUBSCRIPTION, `
    MCOSTANDARD, `
    SHAREPOINTWAC, `
    SHAREPOINTENTERPRISE

Function Connecto365 {
# To Connect to o365
#Import-Module MSOnline
#$url = "https://ps.outlook.com/PowerShell-LiveID?PSVersion=5.1.14393.1066"
#$ocred = Get-Credential
#$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri $url -Credential $ocred -Authentication Basic -AllowRedirection
#Import-PSSession $Session


Connect-MsolService

}

Function GetUsers {
$list = @() 
Write-host "Enter Users Email Address to Enable o365 Licenses:" 
do 
{
    $line = (Read-Host " ")
    if ($line -ne '') 
        {
            $list += $line
         }
} 
until ($line -eq '')

    ForEach ($user in $list){
        $UserInfo = Get-MsolUser -UserPrincipalName $User
        EnableLicense
    }


}

Function EnableLicense {
    # Setting User Location to US
    If ($UserInfo.UsageLocation -eq "US"){
        Write-Host $user "Location Already Set" -ForegroundColor Green
    }
    Else {
        Write-Host "Adding Location for:" $user
        Set-MsolUser -UserPrincipalName $user -UsageLocation US
    }
    If ($UserInfo.IsLicensed -eq $True){
        Write-Host $user "Already Licensed" -ForegroundColor Green
    }
    # applying license
    Else {
        Write-Host "Adding License for:" $user
        Set-MsolUserLicense -UserPrincipalName $Userinfo.UserPrincipalName -AddLicenses epiqsystems3:ENTERPRISEPACK -LicenseOptions $ExchangeOnlineSku
    }
    
}


# Script Body
Connecto365
GetUsers
