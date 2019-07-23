<#  
.SYNOPSIS
   	Connect Functions

.DESCRIPTION  
    Functions for Connections

.INSTRUCTIONS
    Call this from your other scripots

.NOTES  
    Current Version     	: 1.0
    
    History			        : 1.0 - Posted 5/1/2017 - First iteration - kbennett 
        
    Rights Required		    : Exchange Permissions to Add/Edit Contacts
				            : AD Permissions to Add/Edit Objects
                        	: Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     	:

.FUNCTIONALITY

#>

Function Connect-o365 {
    $o365Credential = Get-Credential
    Import-Module MSOnline
    Connect-MsolService -Credential $o365Credential
    $o365Session = New-PSSession `
    -ConfigurationName Microsoft.Exchange `
    -ConnectionUri https://outlook.office365.com/powershell-liveid/ `
    -Authentication Basic `
    -AllowRedirection `
    -Credential $o365Credential
    Import-PSSession $o365Session

}

Function Session-Disconnect {
    # Disconnects Session 
    $s = Get-PSSession
    $s
    Remove-PSSession -Session $s
}
