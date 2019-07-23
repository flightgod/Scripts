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

param (
$exchangeURI = "http://ET016-EQEXMBX01.amer.EvilCorpcorp.com/PowerShell/",
$exchangeSession = "et016-eqexmbx01.amer.EvilCorpcorp.com"
)


# function to connect to Exchange Server
Function ExchangeConnect 
{
    If ($Session.ComputerName -like $exchangeSession){
        Write-Host "Session already established to exchange" -ForegroundColor Green
    }
    Else {
        Write-Host "Session not made to exchange, creating session now" -ForegroundColor Red
        $UserCredential = Get-Credential
        $Session = New-PSSession `
        -ConfigurationName Microsoft.Exchange `
        -ConnectionUri $exchangeURI `
        -Authentication Kerberos `
        -Credential $UserCredential
        Import-PSSession $Session
    }
}

# Function to Disconnect to Exchange Server
Function DisconnectExchangeSession()
{
Exit-PSSession $Session
}



