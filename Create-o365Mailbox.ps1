<#
.SYNOPSIS
    For Creating o365 Remote Mailbox - to be ran by Account Management / Service Desk
.DESCRIPTION
    using this script to create a new o365 mailbox and assign license by the service desk or Account managment
.AUTHOR
    Kevin Bennett - 12/11/2016
.EXAMPLE
    (Just Run it, it will ask for user and License version)
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
    12/11/2017 - Finishing up and ready for testing

.TODO
    Loop it if they want to add more than one. Or add an array if more than one. 
#>

# Variables
$DomainController = "P054ADSAMDC02.amer.EPIQCORP.COM"
$ExchangeOnlineSkuE2 = "epiqsystems3:EXCHANGEENTERPRISE" # E2 License - outlook/owa
$ExchangeOnlineSkuE1 = "epiqsystems3:EXCHANGESTANDARD" # E1 License - OWA Only


# Calls my connect function with all the current connection strings in it
.".\Function-Connect.ps1"

# Enables the remote Mailbox
Function CreateRemoteMailbox {
    $Script:account = Read-Host -Prompt 'What is the users username (bsmith)?'
    $Script:upn = $account+"@epiqsystems.com"
    $Script:email = $account+"@epiqsystems3.mail.onmicrosoft.com"
    Enable-RemoteMailbox $account -RemoteRoutingAddress $email -DomainController $DomainController

}

# runs the Sync
Function ADSync {
    # Kicks off the AD Azure Sync on the Sync server
    $session = New-PSSession -ComputerName "P054ADZAGTA01" -Credential $UserCredential
    Invoke-Command -Session $session -ScriptBlock {Import-Module "C:\Program Files\Microsoft Azure AD Sync\Bin\ADSync\ADSync.psd1"}
    Invoke-Command -Session $session -ScriptBlock {Start-ADSyncSyncCycle -PolicyType Delta}
    Remove-PSSession $session
    
    "Please wait while the Azure Sync is completed ......... Estimate 60 Seconds"

    Start-Sleep -s 60
}

# Assigns the License
## Need to ask here if it is an OWAOnly or Outlook License ##
Function AssignLic {
        # Need to do a check here on what License to use
        Write-Host "Setting Location and License to E1" + $upn
        # Setting User Location to US
        Set-MsolUser -UserPrincipalName $upn -UsageLocation US
        Set-MsolUserLicense -UserPrincipalName $upn -AddLicenses $ExchangeOnlineSkuE1    
        Get-MsolUser -UserPrincipalName $upn | select UserPrincipalName, UsageLocation, isLicensed, Licenses
        SetDefaults
}

# Sets all the defaults
Function setDefaults {
        # Need an IF THEN here depending on which License is used
        Write-host "Setting Defaults: " + $upn
        # Sets IssueWarningQuota to 45GB and set RetainDeletedItemsFor 30 days
        Set-Mailbox $upn -IssueWarningQuota 45GB -RetainDeletedItemsFor 30.00:00:00
        Write-host "Turning off Clutter" + $upn
        # Turn off Clutter
        Get-Mailbox –identity $upn | Set-Clutter -enable $false
        # Should we add an archive also?
}


#Script Main body
 Connect-Exchange # calls from the .function-connect.ps1
 CreateRemoteMailbox
 ADSync #once done it does an AD Sync to get it all to o365
 Session-Disconnect # Cleans up our PSSessions from Function-connect

 Write-Host "Now we need to run the second part to assign license to the above users and set defaults" -ForegroundColor Green
 
 Connect-o365 # calls from the .function-connect.ps1
 AssignLic #Assigns licenses and then Defaults for each user
 Session-Disconnect # Cleans up our PSSessions from Function-connect

 Function TestingSwitch {
 $Script:Type = Read-Host -Prompt 'Which License Type (1/2) - 1: OWAOnly 2:Outlook?'
         switch ($Type){
            1 {$Type = $ExchangeOnlineSkuE1}
            2 {$Type = $ExchangeOnlineSkuE2}
        }
        $Type
 }