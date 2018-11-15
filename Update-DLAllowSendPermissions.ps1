<#
.SYNOPSIS
   	o365 Tasks

.DESCRIPTION  
    This script will give a menu of all the o365 Tasks the Service Desk or Account Management can do in o365 and 
    make it easier for them to complete

.NOTES  
    Current Version     	: 1.0
    
    History			        : 1.0

        
    Rights Required		    : Permissions to Add/Edit Objects in o365
                        	: Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     	: Add o365 Mailbox
                            : Add o365 Skype Account
                            : Assign Licenses
                            : Forward Email
                            : Assign Full and Send AS Permissions to Shared Mailboxes
                            : Remove Licenses
                            : Check Status of Accounts
             
.FUNCTIONALITY
    connect to o365 .... 


#>
# Variables
$ExchangeServer = "http://et016-ex10hub1.amer.epiqcorp.com/PowerShell/"
$DomainController = "P054ADSAMDC02.amer.EPIQCORP.COM"
$UKDC = "p016ADSEUDC01.euro.epiqcorp.com"
$Managed = "o365Questions@epiqglobal.com"

#Function to get the new user and update the Distribution Groups
Function UpdateDlLimitedUser {
$Script:account = Read-Host -Prompt 'What is the users username to add permissions (bsmith)?'
$groups = Get-DistributionGroup DTIEpiqAllEmployees| %{$_.AcceptMessagesOnlyFromSendersOrMembers}
$kcgroups = $groups
#Get-DistributionGroup Epiq-All-Contractors| %{$_.AcceptMessagesOnlyFromSendersOrMembers}
#Get-DistributionGroup Epiq-All| %{$_.AcceptMessagesOnlyFromSendersOrMembers}
#Get-DynamicDistributionGroup Epiq-All-Apac| %{$_.AcceptMessagesOnlyFromSendersOrMembers}
#Get-DistributionGroup EagleAllGroup| %{$_.AcceptMessagesOnlyFromSendersOrMembers}
#Get-DistributionGroup TeamAll| %{$_.AcceptMessagesOnlyFromSendersOrMembers}
#Get-DistributionGroup Engagement2| %{$_.AcceptMessagesOnlyFromSendersOrMembers}
#Get-DistributionGroup DL-UKAllAssociates -DOmainController $UKDC| %{$_.AcceptMessagesOnlyFromSendersOrMembers}
$groups


Set-DistributionGroup Epiq-All-Contractors -AcceptMessagesOnlyFromSendersOrMembers $kcgroups -ManagedBy $Managed
Set-DistributionGroup Epiq-All -AcceptMessagesOnlyFromSendersOrMembers $kcgroups -ManagedBy $Managed
Set-DynamicDistributionGroup Epiq-All-APAC -AcceptMessagesOnlyFromSendersOrMembers $Groups -ManagedBy $Managed
Set-DistributionGroup EagleAllGroup -AcceptMessagesOnlyFromSendersOrMembers $Groups -ManagedBy $Managed
Set-DistributionGroup TeamAll -AcceptMessagesOnlyFromSendersOrMembers $Groups -ManagedBy $Managed
Set-DistributionGroup Engagement2 -AcceptMessagesOnlyFromSendersOrMembers $Groups -ManagedBy $Managed
Set-DistributionGroup DL-UKAllAssociates -DomainController $UKDC -AcceptMessagesOnlyFromSendersOrMembers $groups -ManagedBy $Managed
}


Function ExchangeConnect {
    If ($Session.ComputerName -like "et016-eqexmbx01.amer.epiqcorp.com"){
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

# runs the Sync
Function ADSync {
    # Kicks off the AD Azure Sync on the Sync server
    $session = New-PSSession -ComputerName "P054ADZAGTA01" -Credential $UserCredential
    Invoke-Command -Session $session -ScriptBlock {Import-Module "C:\Program Files\Microsoft Azure AD Sync\Bin\ADSync\ADSync.psd1"}
    Invoke-Command -Session $session -ScriptBlock {Start-ADSyncSyncCycle -PolicyType Delta}
    Remove-PSSession $session
    
    "Please wait while the Azure Sync is completed ......... Estimate 15 Seconds"

    Start-Sleep -s 16
}

ExchangeConnect
UpdateDLLimitedUser
ADSync

