<#  
.SYNOPSIS
   	Add User to AD Functions

.DESCRIPTION  
    Functions for Adding a user to AD

.INSTRUCTIONS
    Call this from your other scripots

.NOTES  
    Current Version     	: 1.0
    
    History			        : 1.0 - Posted 11/29/2017 - First iteration - kbennett 
        
    Rights Required		    : Exchange Permissions to Add/Edit Contacts
				            : AD Permissions to Add/Edit Objects
                        	: Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     	:

.FUNCTIONALITY

.TODO

#>

Connect-Exchange # calls from the .function-connect.ps1

Function Add-User {
    $Script:account = Read-Host -Prompt 'What is the users username (bsmith)?'
    $Script:upn = $account+"@EvilCorpsystems.com"
    $Script:email = $account+"@EvilCorpsystems3.mail.onmicrosoft.com"

    Enable-RemoteMailbox $account -RemoteRoutingAddress $email -DomainController $DomainController
}

ADSync

Session-Disconnect # Cleans up our PSSessions from Function-connect
