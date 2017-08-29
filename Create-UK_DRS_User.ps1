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


# Script Variables
$DefaultPassword = "Welcomeepiq-24566"
$UkServer = "P064ADSEUDC02.euro.epiqcorp.com"
$State = "England"
$DomainList = "epiqcorp.com","amer.epiqcorp.com","apac.epiqcorp.com","euro.epiqcorp.com"
$FilePath = ".\NewUsers.csv"


Import-Module ActiveDirectory

# Imports CSV File of Users
Function importCSV {
    $Script:NewUserImport = Import-Csv $FilePath
}


# this is an informational check only. It will not prevent you from creating accounts with the same name at this point
Function checkUser {
    $Script:Continue = ""
    foreach ($User in $NewUserImport) {
        $Name = $User.samAccountName
        forEach ($domain in $DomainList){
            If (Get-ADUser -Server $domain -Filter {samAccountName -eq $Name}) {
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
            $Script:userPrincinpal = $user.samAccountName + "@epiqsystems.co.uk"
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
                -Server $UkServer
            Add-ADGroupMember "DL-DRS-receiveonly" $user.samAccountName -Server $UkServer;
            Get-AdUser $user.samAccountName -Server $UkServer
            }
    } Else {
        # This is the error Checking if the checkUser found a duplicate
        Write-host "The Continue Value = NO, Please fix duplicate usernames"
    }
}


#Script Body
importCSV
checkUser
addUser

