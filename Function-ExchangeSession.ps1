<#  
.SYNOPSIS
   Function to be called to connect to Exchange

.DESCRIPTION  
    This script can be called to connect to exchange remotely to run Commands

.NOTES  
    Current Version     : 1.0
    
    History				: 1.0 - Posted 4/26/2017 - First iteration - kbennett                      
    
    Rights Required		: Exchange Permissions
                        : Exchange is in OnPrem environment
                        : Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     : Error Checking 
                        : make it look better

.FUNCTIONALITY
    This script can be called to connect to exchange remotely to run Commands
#>

# Connects to Exchange
Function ExchangeConnect 
{
    If ($Session.ComputerName -like "et016-eqexmbx01.amer.epiqcorp.com"){
        Write-Host "Session already established to exchange" -ForegroundColor Green
    }
    Else {
        Write-Host "Session not made to exchange, creating session now" -ForegroundColor Red
        $UserCredential = Get-Credential
        $Session = New-PSSession `
        -ConfigurationName Microsoft.Exchange `
        -ConnectionUri http://ET016-EQEXMBX01.amer.epiqcorp.com/PowerShell/ `
        -Authentication Kerberos `
        -Credential $UserCredential
        Import-PSSession $Session
    }
}

Function DisconnectExchangeSession()
{
Exit-PSSession $Session
}



