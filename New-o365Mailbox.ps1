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
    .\New-o365Mailbox.ps1
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
.TODO
    Create loop for adding more than one user
    Might need to add a proxy address of IRISDS.com
    Maybe add Domain or Domain Controller for Enable-RemoteMailbox to easy find in APAC/EURO
#>
	# Variables
    [String]$ExchangeServer = "http://ET016-EQEXMBX01.amer.epiqcorp.com/PowerShell/"
	[String]$ExchangeOnlineSku = New-MsolLicenseOptions `
		-AccountSkuId `
		epiqsystems3:ENTERPRISEPACK `
		-DisabledPlans `
		RMS_S_ENTERPRISE,`
		OFFICESUBSCRIPTION,`
		MCOSTANDARD,`
		SHAREPOINTWAC,`
		SHAREPOINTENTERPRISE,`
		YAMMER_ENTERPRISE,`
		INTUNE_O365,`
		SWAY,`
		PROJECTWORKMANAGEMENT
	[String]$Account = Read-Host -Prompt 'What is the users username (bsmith)?'
	[String]$Upn = $account+"@epiqsystems.com"
	[String]$Email = $account+"@epiqsystems3.mail.onmicrosoft.com"
    [String]$DomainController = "P054ADSAMDC01.amer.EPIQCORP.COM"


# Connects to Exchange
Function ExchangeConnect 
{
    If ($Session.ComputerName -like "et016-eqexmbx01.amer.epiqcorp.com"){
        Write-Host "Session already established to exchange" -ForegroundColor Green
    }
    Else {
        Write-Host " Prompting for your Local WARD Account"
        Start-Sleep -s 5
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

Function connectO365 
{
# To Connect to o365
Write-Host " Prompting for your o365 WARD Account"
Start-Sleep -s 5

Import-Module MSOnline
$ocred = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri https://outlook.office365.com/powershell-liveid/ -Credential $ocred -Authentication Basic -AllowRedirection
Import-PSSession $Session
Connect-MsolService -Credential $ocred
}

Function createRemoteMailbox
{
"Mailbox will be created as :", $upn

Start-Sleep -s 5

# Enables the o365 Mailbox and Turns on Archive for the user
Enable-RemoteMailbox $account -RemoteRoutingAddress $email -DomainController $domainController
# Enable-RemoteMailbox $upn -Archive
}

Function azureSync
{
"Please wait while the Azure Sync is completed ......... Estimate 15 Seconds"

Start-Sleep -s 15

# Kicks off the AD Azure Sync on the Sync server
$session = New-PSSession -ComputerName "P054ADZAGTA01" -Credential $UserCredential
Invoke-Command -Session $session -ScriptBlock {Import-Module "C:\Program Files\Microsoft Azure AD Sync\Bin\ADSync\ADSync.psd1"}
Invoke-Command -Session $session -ScriptBlock {Start-ADSyncSyncCycle -PolicyType Delta}
Remove-PSSession $session
}

Function setDefaults
{
# Sets IssueWarningQuota to 45GB and set RetainDeletedItemsFor 30 days
Set-Mailbox $account -IssueWarningQuota 45GB -RetainDeletedItemsFor 30.00:00:00

# Turn off Clutter
Get-Mailbox –identity $upn | Set-Clutter -enable $false

# Displays the info for sanity sake
Get-Mailbox $upn | Select DisplayName, WindowsEmailAddress
" User " + $account + " Remote Mailbox created in o365 as " + $upn + "Archive Turned on"
}

Function assignLicense
{
# Setting User Location to US
Set-MsolUser -UserPrincipalName $upn -UsageLocation US

# Setting Licensees
Set-MsolUserLicense -UserPrincipalName $upn -AddLicenses epiqsystems3:ENTERPRISEPACK -LicenseOptions $ExchangeOnlineSku
 
}

# MainBody of Script
ExchangeConnect
createRemoteMailbox
connectO365
azureSync
assignLicense