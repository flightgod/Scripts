<#  
.SYNOPSIS
   	Add User to AD and Create OnPrem Mailbox

.DESCRIPTION  
    This script will Add Users Account to UK AD and Create onPrem Mailbox, assigning groups

.NOTES  
    Current Version     	: 1.0
    
    History			        : 1.0 - Posted 8/28/2017 - First iteration - kbennett 
         
    Rights Required		    : AD Permissions to Add/Edit Objects
                            : Exchange Rights to Add Mailboxes
                        	: Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     	: Better Error Checking

             
.FUNCTIONALITY
    Update Distibution List, Check user exists

#>

<#
Fields to use:

!DisplayName
!UserPrincipalName
!JobTitle (has type of user mixed in)
!Department (if it is a user)
Address
City
State
Zip
Country
BusinessPhone
MobilePhone
Recepient Type (mailbox/owa)
#>

# Script Variables
$DefaultPassword = "Welcomeepiq-24566"
$USServer = "P054ADSAMDC01.amer.EPIQCORP.COM"
$State = "England"
$DomainList = "epiqcorp.com","amer.epiqcorp.com","apac.epiqcorp.com","euro.epiqcorp.com"
$FilePath = ".\DTIGlobal_All_Mailboxes.csv"
$UserOUPath = "OU=Standard,OU=Employees,OU=Corp IT,DC=amer,DC=Epiqcorp,DC=COM"
$SharedOUPath = "OU=Shared Mailboxes,OU=Exchange,OU=Corp IT,DC=amer,DC=Epiqcorp,DC=COM"
$ResourceOUPath = "OU=Resources,OU=Exchange,OU=Corp IT,DC=amer,DC=Epiqcorp,DC=COM"
$DLOUPath = "OU=Distribution Groups,OU=Exchange,OU=Corp IT,DC=amer,DC=Epiqcorp,DC=COM"
$ContactOUPath = "OU=Contacts,OU=Exchange,OU=Corp IT,DC=amer,DC=Epiqcorp,DC=COM"
$ExchangeServer = "http://ET016-EQEXMBX01.amer.epiqcorp.com/PowerShell/"
$ExchangeOnlineSku = "epiqsystems3:EXCHANGEENTERPRISE"

Import-Module ActiveDirectory

# connect to Exchange
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


# Imports CSV File of Users
Function importCSV {
    $Script:NewUserImport = Import-Csv $FilePath
}


# Check the type of user being added
Function checkType {
    # Check if it is a shared mailbox or Resources Mailbox
}

# this is an informational check only. It will not prevent you from creating accounts with the same name at this point
Function checkUser {
    $Script:Continue = ""
    foreach ($User in $NewUserImport) {
        $Name = $User.UserPrincipalName
        forEach ($domain in $DomainList){
            If (Get-ADUser -Server $domain -Filter {UserPrincipalName -like $Name}) {
                write-Host "User $Name Exist in $domain" -ForegroundColor Red
                $Continue = "NO"
                # Get-ADUser $Name -Server $domain
                } Else {
                    Write-Host "User $name doesnt exist in $domain" -ForegroundColor Green
                }
        }
    }
}

# Adds user to AD, Sets all Varaibles from CSV, Along with State and assigns Group Memebership
Function addUser {
    # This is the error Checking if the checkUser found a duplicate
    If ($Continue -notlike "NO"){
        #Run through each user in the list and create accounts
        ForEach ($user in $NewUserImport) {
            $Script:userPrincinpal = $user.samAccountName + "@epiqsystems.com"
            New-ADUser -Name $User.Name `
                -Path $user.ParentOU `
                -SamAccountName  $user.samAccountName `
                -GivenName  $user.GivenName `
                -Surname  $user.Surname `
                -UserPrincipalName  $userPrincinpal `
                -State $State `
                -AccountPassword (ConvertTo-SecureString $DefaultPassword -AsPlainText -Force) `
                -ChangePasswordAtLogon $true  `
                -Enabled $true `
                -Server $USServer -WhatIf
            Add-ADGroupMember "DL-DRS-receiveonly" $user.samAccountName -Server $USServer;
            Get-AdUser $user.samAccountName -Server $USServer
            }
    } Else {
        # This is the error Checking if the checkUser found a duplicate
        Write-host "The Continue Value = NO, Please fix duplicate usernames"
    }
}

# Gets a single user to create an o365 Mailbox
Function GetIndivUser {
    $account = Read-Host -Prompt 'What is the users username (bsmith)?'
    $upn = $account+"@epiqsystems.com"
    $email = $account+"@epiqsystems3.mail.onmicrosoft.com"
    checkUser
}

# Enables the remote Mailbox
Function CreateRemoteMailbox {
    "Mailbox will be created as :", $upn
    # Enables the o365 Mailbox and Turns on Archive for the user
    Enable-RemoteMailbox $account -RemoteRoutingAddress $email
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
    $session = New-PSSession -ComputerName "P054ADZAGTA01"
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

#Script Body
importCSV
checkUser
addUser

