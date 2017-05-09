<#  
.SYNOPSIS
   	Update o365 Settings

.DESCRIPTION  
    This script updates the o365 settings of users

.NOTES  
    Current Version     	: 1.0
    
    History			        : 1.0 - Posted 5/9/2017 - First iteration - kbennett 

        
    Rights Required		    : Exchange Permissions to Add/Edit Mailbox
				            : o365 Permissions for powershell and updating users permissions
                        	: Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     	: Better Error Checking
                            : Should probably just run through all users and check the settings are correct and change if they are not

.FUNCTIONALITY
    Add Contacts, Update User Defined Field, List old Users
#>



Function UpdateSettings {
# Enable Archive
$archiveOn = Get-RemoteMailbox $user
If ($archiveOn.ArchiveStatus -eq "Active"){
    Write-Host $user "Already has archive enabled" -ForegroundColor Green
    }
    Else {
     write-host "Enabling Arcvhive for:" $user
     Enable-RemoteMailbox $user -Archive
    }
# Turn off Clutter
$clutterOn = Get-Clutter -Identity $UserInfo.UserPrincipalName 
If ($clutterOn.isEnabled -eq $False){
    Write-Host $user "does not have Clutter enabled" -ForegroundColor Green
    }
    Else {
        Write-Host "Clutter is on, turning off for:" $user
        Set-Clutter -Identity $UserInfo.UserPrincipalName -enable $false 
    }
}

Function GetUsers {
$list = @() 
Write-host "Enter Users Email Address to Enable o365 Licenses:" 
do 
{
    $line = (Read-Host " ")
    if ($line -ne '') 
        {
            $list += $line
         }
} 
until ($line -eq '')

    ForEach ($user in $list){
        $UserInfo = Get-MsolUser -UserPrincipalName $User
        UpdateSettings
    }

}


Get-Users # or maybe set to all o365 users with license and mailbox?