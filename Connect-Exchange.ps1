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


# Connects to Exchange
Function Connect-Exchange {
$ExchangeServer = "http://ET016-EQEXMBX01.amer.epiqcorp.com/PowerShell/"
    # If already connected skip - makes it cleaner to look at     
    If ($Session.ComputerName -like "et016-eqexmbx01.amer.epiqcorp.com") {
        Write-Host "Session already established to exchange" -ForegroundColor Green
    }
    Else {
        Write-Host "Session not made to exchange, creating session now" -ForegroundColor Red
        $UserCredential = Get-Credential
        $Session = New-PSSession `
        -ConfigurationName Microsoft.Exchange `
        -ConnectionUri $ExchangeServer `
        -Authentication Kerberos `
        -Credential $UserCredential
        Import-PSSession $Session
    }
}

