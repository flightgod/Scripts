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
$ExchangeServer = "http://P054EXCTRNS02.amer.epiqcorp.com/PowerShell/"
$DomainController = "P054ADSAMDC02.amer.EPIQCORP.COM"
$Script:UKDomainController = "P054ADSEUDC01.EURO.EPIQCORP.COM"
$Managed = "o365Questions@epiqglobal.com"
$MasterDL = "Epiq-All"

#Function to List out current users with permission and count
Function CheckDLLimitedUser {
    $Groups = Get-DistributionGroup $MasterDL | select AcceptmessagesOnlyFromSendersOrMembers
    $groups.AcceptMessagesOnlyFromSendersOrMembers
    $groups.AcceptMessagesOnlyFromSendersOrMembers.Count
}

#Function to get the new user and update the Distribution Groups
Function AddDlLimitedUser {
    $Script:account = Read-Host -Prompt 'What is the users username to add permissions (bsmith)?'
    $Script:GettingDN = Get-ADUser $account
    Set-DistributionGroup $MasterDL -AcceptMessagesOnlyFrom  @{Add=$GettingDN.DistinguishedName}
    #UpdateDLLimitedUserAll
}

Function RemoveDlLimtedUser {
    $Script:account = Read-Host -Prompt 'What is the users username to add permissions (bsmith)?'
    $Script:GettingDN = Get-ADUser $account
    Set-DistributionGroup $MasterDL -AcceptMessagesOnlyFrom   @{Remove=$GettingDN.DistinguishedName}
}

#Function to Update All Limited User DL to same permissions
Function UpdateDLLimitedUserAll {
$Groups = Get-DistributionGroup $MasterDL | select AcceptmessagesOnlyFromSendersOrMembers
$kcgroups = $groups.AcceptMessagesOnlyFromSendersOrMembers

Set-DistributionGroup Epiq-All-Contractors -AcceptMessagesOnlyFromSendersOrMembers $kcgroups -ManagedBy $Managed
Set-DynamicDistributionGroup Epiq-All-APAC -AcceptMessagesOnlyFromSendersOrMembers $kcGroups -ManagedBy $Managed
Set-DistributionGroup EagleAllGroup -AcceptMessagesOnlyFromSendersOrMembers $kcGroups -ManagedBy $Managed
Set-DistributionGroup TeamAll -AcceptMessagesOnlyFromSendersOrMembers $kcGroups -ManagedBy $Managed
Set-DistributionGroup Engagement2 -AcceptMessagesOnlyFromSendersOrMembers $kcGroups -ManagedBy $Managed
Set-DistributionGroup Epiq-All-UK-Associates -DomainController $UKDomainController -AcceptMessagesOnlyFromSendersOrMembers $kcgroups
Set-DynamicDistributionGroup Epiq-All-UK -AcceptMessagesOnlyFromSendersOrMembers $kcgroups

}

#Function to Connect to Exchange
Function ExchangeConnect {
    If ($Session.ComputerName -like "P054EXCTRNS02.amer.epiqcorp.com"){
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


Function Menu {
do
 {
     Show-Menu
     $selection = Read-Host "Please make a selection"
     switch ($selection)
        {
          '1' {
            CheckDLLimitedUser
        } '2' {
            AddDlLimitedUser
        } '3' {
            RemoveDlLimtedUser
        } '4' {
            UpdateDLLimitedUserAll
        } '5' {
            ADSync
        }
     }
     pause
 }
 until ($selection -eq 'q')
}

function Show-Menu
{
    param (
        [string]$Title = 'All Distro Menu'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "1: Press '1' to Check List of User Access to Send"
    Write-Host "2: Press '2' to Add User Access to Send"
    Write-Host "3: Press '3' to Remove User Access to Send"
    Write-Host "4: Press '4' to Update All Limited DL to Same Permissions"
    Write-Host "5: Press '5' to Run AD Azure Sync"
    Write-Host "Q: Press 'Q' to quit."
}

ExchangeConnect
Menu


# Function to deploy to Jump Boxes
# This is for kbennett to easily deploy script changes, do not run because it probably wont work for you
Function Deploy-Script {
   
    $LocalPath = 'c:\Scripts\Update-DLAllowSendPermissions.ps1'
    
    $UserCredential = Get-Credential

    New-PSDrive -Name "Scripts0" -PSProvider "FileSystem" -root '\\TS016-EXTOOLS\C$\Scripts' -Credential $UserCredential
        Copy-Item -Path $LocalPath -Destination 'Scripts0:'
    Remove-PSDrive -Name "Scripts0"

    New-PSDrive -Name "Scripts1" -PSProvider "FileSystem" -root '\\P054CORUTIL01\C$\Scripts' -Credential $UserCredential
        Copy-Item -Path $LocalPath -Destination 'Scripts1:'
    Remove-PSDrive -Name "Scripts1"

    New-PSDrive -Name "Scripts1" -PSProvider "FileSystem" -root '\\P054CORUTIL02\C$\Scripts' -Credential $UserCredential
        Copy-Item -Path $LocalPath -Destination 'Scripts1:'
    Remove-PSDrive -Name "Scripts1"

    New-PSDrive -Name "Scripts2" -PSProvider "FileSystem" -root '\\P054EXGRELY01\C$\Scripts' -Credential $UserCredential
        Copy-Item -Path $LocalPath -Destination 'Scripts2:'
    Remove-PSDrive -Name "Scripts2"

    New-PSDrive -Name "Scripts3" -PSProvider "FileSystem" -root '\\P054EXGRELY02\C$\Scripts' -Credential $UserCredential
        Copy-Item -Path $LocalPath -Destination 'Scripts3:'
    Remove-PSDrive -Name "Scripts3"

}