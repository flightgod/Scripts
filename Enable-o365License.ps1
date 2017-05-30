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

# Modules
Import-Module .\Connect-o365.ps1


Function EnableLicense {
    # Setting User Location to US
    If ($UserInfo.UsageLocation -eq "US"){
        Write-Host $user.User "Location Already Set" -ForegroundColor Green
    }
    Else {
        Write-Host "Adding Location for:" $user.User
        Set-MsolUser -UserPrincipalName $user.User -UsageLocation US
    }
    If ($UserInfo.IsLicensed -eq $True){
        Write-Host $user.User "Already Licensed" -ForegroundColor Green
    }
    # applying license
    Else {
        Write-Host "Adding License for:" $user.User
        Set-MsolUserLicense -UserPrincipalName $Userinfo.UserPrincipalName -AddLicenses epiqsystems3:ENTERPRISEPACK -LicenseOptions $ExchangeOnlineSku
    }
    
}

Function ImportUsers {
    $File = "c:\temp\LicUsers.csv"
    $script:import = Import-csv $file
            ForEach ($user in $import){
                $UserInfo = Get-MsolUser -UserPrincipalName $user.User
                EnableLicense 
            }

}
# Script Body
Connect-o365
ImportUsers
