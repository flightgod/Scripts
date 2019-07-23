<#
.SYNOPSIS
    For adding users to o365
.DESCRIPTION
    This script should be ran to add new Remote Mailbox to be used within o365, 
    it will also add licenses, will update Location, and kick off AD Azure sync
    It should be ran from an exchange Powershell
.AUTHOR
    Kevin Bennett - 6/01/2016
.EXAMPLE
    .\Add-o365_Mailbox.ps1
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
#>

# Variables
$ExchangeServer = "http://ET016-EQEXMBX01.amer.EvilCorpcorp.com/PowerShell/"
$ExchangeOnlineSku = "EvilCorpsystems3:EXCHANGEENTERPRISE"
$DomainController = "P054ADSAMDC02.amer.EvilCorpCORP.COM"
$DomainController_AP = "ET016-EQAPDC03.APAC.EvilCorpCORP.COM"
$DomainController_UK = "ET016-EQEUDC01.EURO.EvilCorpCORP.COM"

# connect to Exchange
Function ExchangeConnect {
    If ($Session.ComputerName -like "et016-eqexmbx01.amer.EvilCorpcorp.com"){
        Write-Host "Session already established to exchange" -ForegroundColor Green
    }
    Else {
        Write-Host "Session not made to exchange, creating session now" -ForegroundColor Red
        $Script:UserCredential = Get-Credential
        $Script:Session = New-PSSession `
        -ConfigurationName Microsoft.Exchange `
        -ConnectionUri $ExchangeServer `
        -Authentication Kerberos `
        -Credential $UserCredential
        Import-PSSession $Session
    }
}

# This should run to get a list of users
Function GetUsersList {

}

# Gets a single user to create an o365 Mailbox
Function GetIndivUser {
    $Script:account = Read-Host -Prompt 'What is the users username (bsmith)?'
    $Script:upn = $account+"@EvilCorpsystems.com"
    $Script:email = $account+"@EvilCorpsystems3.mail.onmicrosoft.com"
    checkUser
}

# Error checking to see if user exists
Function checkUser {
    Get-ADUser -Identity $account -Server $DomainController
    # If error doesnt Exit go to CreateADAccount

}

# create an AD Account if not found
Function CreateADAccount {
# $DomainController
}

# Enables the remote Mailbox
Function CreateRemoteMailbox {
    "Mailbox will be created as :", $upn
    # Enables the o365 Mailbox and Turns on Archive for the user
    Enable-RemoteMailbox $account -RemoteRoutingAddress $email -DomainController $DomainController
    # Enable-RemoteMailbox $upn -Archive
}

# Assigns the License
Function AssignLic {
    # Setting Licensees
    Set-MsolUserLicense -UserPrincipalName $upn -AddLicenses $ExchangeOnlineSku
}

# runs the Sync
Function ADSync {
    # Kicks off the AD Azure Sync on the Sync server
    $session = New-PSSession -ComputerName "P054ADZAGTA01" -Credential $UserCredential
    Invoke-Command -Session $session -ScriptBlock {Import-Module "C:\Program Files\Microsoft Azure AD Sync\Bin\ADSync\ADSync.psd1"}
    Invoke-Command -Session $session -ScriptBlock {Start-ADSyncSyncCycle -PolicyType Delta}
    Remove-PSSession $session
    
    "Please wait while the Azure Sync is completed ......... Estimate 15 Seconds"

    Start-Sleep -s 15
}

# Sets all the defaults
Function setDefaults {
    
    # Setting User Location to US
    Set-MsolUser -UserPrincipalName $upn -UsageLocation US

    # Sets IssueWarningQuota to 45GB and set RetainDeletedItemsFor 30 days
    Set-Mailbox $account -IssueWarningQuota 45GB -RetainDeletedItemsFor 30.00:00:00

    # Turn off Clutter
    Get-Mailbox –identity $upn | Set-Clutter -enable $false
}

#Script Main body
ExchangeConnect
GetIndivUser
# CreateADAccount
CreateRemoteMailbox
ADSync
Connect-MsolService
AssignLic
setDefaults
