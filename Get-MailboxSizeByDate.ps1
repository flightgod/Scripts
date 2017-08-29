<#  
.SYNOPSIS
   

.DESCRIPTION  
    

.NOTES  
    Current Version     : 1.0
    /
    History				: 1.0 - Posted 8/23/2017 - First iteration - kbennett                      
    
    Rights Required		: Exchange Permissions
                        : Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     : Error Checking 
                        : make it look better

.FUNCTIONALITY
    This script can be called to connect to exchange remotely to run Commands
#>

# variables
param (
$path = "C:\temp\output.csv",
$exchangeURI = "http://ET016-EQEXMBX01.amer.epiqcorp.com/PowerShell/",
$exchangeSession = "et016-eqexmbx01.amer.epiqcorp.com"
)


# function to connect to exchange Server
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

# Need to create a Fucntion to Populate a list of users to $List
Function PopulateList {

}

# function to search mailboxes and get size by date range
Function SearchMailboxes {
    ForEach ($user in $List){
        Search-Mailbox `
        -Identity $user `
        -SearchQuery "Received:> $('01/01/2017') and Received:< $('08/23/2017')" `
        -EstimateResultOnly | `
        Export-CSV $path
    }
}



# Script Main Body
ExchangeConnect
PopulateList
SearchMailboxes