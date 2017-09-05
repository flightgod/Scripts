<#
.SYNOPSIS
    Part 2 For adding users to o365
.DESCRIPTION
    This script add licenses, will update Location, and Default Settings for o365 Mailbox
    
.AUTHOR
    Kevin Bennett - 6/01/2016
.EXAMPLE
    .\Create-UserWith365_Mailbox_Part2.ps1
.SYNTAX
    No special Syntax
.ALIASES
    No Alias
.LINK
    NA
.PARAMETER 1
    No Additonal Parameters enabled
.PARAMETER 2
    No Additonal Parameters enabled
.NOTE
    10/01/2016 - Added the AD Azure Sync
    10/12/2016 - Adjusted for post IRIS Migration, Removed forward to IRISDS.COM & Permissions
    05/09/2017 - Adding Licenses to Disable for new o365 Products
    08/30/2017 - Working to fully integrate for DTI import - kbennett
#>

# Variables
$ExchangeOnlineSku = "epiqsystems3:EXCHANGEENTERPRISE"
$DomainController = "P054ADSAMDC02.amer.EPIQCORP.COM"
$file = "c:\temp\ADUsers.csv"



# Import List
Function importUsers {
    $test = Test-Path $file
    If ($test -eq $true) {
        $script:import = Import-csv $file
    }
    Else {
        Write-Warning "Something went Wrong: Import File is missing at $file"
        Break
    }
 }

# Assigns the License
Function AssignLic {
    foreach ($Script:name in $import) {
    $Script:upn = $name.Username +"@epiqsystems.com"
    # Connect-MsolService -Credential $o365Credential

    $Status = Get-MsolUser -UserPrincipalName $upn | select UserPrincipalName, UsageLocation, isLicensed, Licenses
    # Setting User Location to US
    IF ($status.UsageLocation -eq "US"){
        # Write-Host "Location for $upn set to US" -ForegroundColor Green
     } Else { 
        Write-Host "Setting $UPN Location to US"  -ForegroundColor Green
        Set-MsolUser -UserPrincipalName $upn -UsageLocation US

    }
    IF ($status.isLicensed -eq $False){
        Write-Host "Setup License - " $status.UserPrincipalName  -ForegroundColor Green
        Set-MsolUserLicense -UserPrincipalName $upn -AddLicenses $ExchangeOnlineSku    
    }
    Get-MsolUser -UserPrincipalName $upn | select UserPrincipalName, UsageLocation, isLicensed, Licenses
    }
}

# Sets all the defaults
Function setDefaults {
    foreach ($Script:name in $import) {
        $Script:upn = $name.Username +"@epiqsystems.com"
        # Sets IssueWarningQuota to 45GB and set RetainDeletedItemsFor 30 days
        #$defaults = get-mailbox $upn | Select UserPrincipalName, IssueWarningQuota, RetainDeletedItemsFor
        #Set-Mailbox $upn -IssueWarningQuota 45GB -RetainDeletedItemsFor 30.00:00:00

        # Turn off Clutter
        Get-Mailbox –identity $upn | Set-Clutter -enable $false
    }
}

Function setPermissions {
    foreach ($Script:name in $import) {    
        $Script:upn = $name.Username +"@epiqsystems.com"
        #setPermissions
        $permTest = Get-MailboxPermission $upn | where {$_.user -like "svc_o365Migration*"}
        If ($permTest.user -eq "SVC_O365Migration@epiqsystems.com"){
            write-Host "Permissions exist $upn "-ForegroundColor Green
        } Else {
            write-Host "Setting Permissions $upn"-ForegroundColor Yellow
        Add-MailboxPermission -Identity $upn -User svc_o365Migration -AccessRights FullAccess
        }

    }
}

Function Connect-o365 {
    If ($o365Session.ComputerName -like "ps.outlook.com") -and ($o365Session.State -eq "Active") {
        Write-Host "Session already established to exchange" -ForegroundColor Green
    }
    Else {
        Write-Host "Session not made to exchange, creating session now" -ForegroundColor Red
        Import-Module MSOnline
        Connect-MsolService -Credential $o365Credential
        $Script:o365Session = New-PSSession `
        -ConfigurationName Microsoft.Exchange `
        -ConnectionUri https://ps.outlook.com/PowerShell-LiveID?PSVersion=4.0 `
        -Authentication Basic `
        -AllowRedirection `
        -Credential $o365Credential 
        Import-PSSession $o365Session
    }

}

# checks if I already put in my username and password
If ($o365Credential.UserName -inotlike "ward_kbennett*"){
    $Script:o365Credential = Get-Credential
}

#Script Main body
 Connect-o365 $o365Credential
 importUsers
 AssignLic
 setDefaults
 setPermissions