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
    12/11/2017 - Added calls to .\.Function-Connect & New E1 license stuff - kbennett
#>

# Variables
$ExchangeOnlineSkuE2 = "epiqsystems3:EXCHANGEENTERPRISE"
$ExchangeOnlineSkuE1 = "epiqsystems3:EXCHANGESTANDARD"
$DomainController = "P054ADSAMDC02.amer.EPIQCORP.COM"
$file = "c:\temp\MSUsersCreated.csv"

# Calls my connect function with all the current connection strings in it
.".\Function-Connect.ps1"


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
        $script:upn = $name.username
        $Status = Get-MsolUser -UserPrincipalName $upn | select UserPrincipalName, UsageLocation, isLicensed, Licenses
        # Setting User Location to US
        Set-MsolUser -UserPrincipalName $upn -UsageLocation US
        Set-MsolUserLicense -UserPrincipalName $upn -AddLicenses $ExchangeOnlineSkuE1    
        Get-MsolUser -UserPrincipalName $upn | select UserPrincipalName, UsageLocation, isLicensed, Licenses
    }
}

# Sets all the defaults
Function setDefaults {
    foreach ($Script:name in $import) {
        $Script:upn = $name.Username +"@epiqsystems.com"
        # Sets IssueWarningQuota to 45GB and set RetainDeletedItemsFor 30 days
        #$defaults = get-mailbox $upn | Select UserPrincipalName, IssueWarningQuota, RetainDeletedItemsFor
        Set-Mailbox $upn -IssueWarningQuota 45GB -RetainDeletedItemsFor 30.00:00:00

        # Turn off Clutter
        Get-Mailbox –identity $upn | Set-Clutter -enable $false
    }
}


#Script Main body
 Connect-o365
 importUsers
 AssignLic
 setDefaults
 #setPermissions
 
 Session-Disconnect