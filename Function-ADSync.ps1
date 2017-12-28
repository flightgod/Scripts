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

ADSync