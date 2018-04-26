<#  
.SYNOPSIS
   	Connects to Azure Sync

.DESCRIPTION  
    Connects to Azure Sync and runs a sync

.NOTES  
    Current Version     	: 1.0
    
    History			        : 1.0 - Posted 03/27/2018 - First iteration - kbennett 

        
    Rights Required		    : Permissions to Add/Edit Objects in Exchange
                        	: Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                            : MUST USE epiqsystem3.onmicrosoft.com account for Auth
                        
    Future Features     	: Better Error Checking
                            : Variables
                            : Check for existing
             
.FUNCTIONALITY
    xxxx
#>

#Variables


# Connects to Azure AD Sync Server 
Function Connect-ADSync {
    # Kicks off the AD Azure Sync on the Sync server
    If ($AzureSession.ComputerName -like "P054ADZAGTA01"){
        Write-Host "Session already established to Azure" -ForegroundColor Green

    }
    Else {
        $Script:AzureSession = New-PSSession -ComputerName "P054ADZAGTA01" -Credential $Script:AzureUserCredential
    }
}

#Invokes teh Scripts to start the sync
Function Invoke-Sync {
    Get-Date
    Invoke-Command -Session $AzureSession -ScriptBlock {Import-Module "C:\Program Files\Microsoft Azure AD Sync\Bin\ADSync\ADSync.psd1"}
    Invoke-Command -Session $AzureSession -ScriptBlock {Start-ADSyncSyncCycle -PolicyType Delta}
    Write-Host "Please wait while the Azure Sync is completed ......... Estimate 15 Seconds"

    Start-Sleep -s 16
}

# A good Coder would also disconnect
Function Disconnect-Session {
    Remove-PSSession $AzureSession
}

# Script main body
    Connect-ADSync
    Invoke-Sync