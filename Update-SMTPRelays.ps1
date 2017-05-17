<#  
.SYNOPSIS
   	Copy Receive Connector Authorized IP's

.DESCRIPTION  
    This script gets the Auth IP's on the 2007 Hub Servers and writes them to 2010 Servers

.NOTES  
    Current Version     	: 1.0
    
    History			        : 1.0 - Posted 5/15/2017 - First iteration - kbennett 

        
    Rights Required		    : Exchange Permissions 
                        	: Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     	: 

.FUNCTIONALITY
    Read / Write Exchange Receive Connector
#>

# Variables
$ExchangeServer = "http://ET016-EQEXMBX01.amer.epiqcorp.com/PowerShell/"
$ServerArray = @(`
                "P054EXCTRNS01\Relay - Hub1",`
                "P054EXCTRNS02\Relay - Hub2",`
                "ET016-EX10HUB1\Relay - Hub1",`
                "ET016-EX10HUB2\Relay - Hub2",`
                "ET016-EQEXCHUB2\Internal Relay - Hub2")

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
        -ConnectionUri $ExchangeServer `
        -Authentication Kerberos `
        -Credential $UserCredential
        Import-PSSession $Session
    }
}

# Function to test connection - want to use this to trim list
Function TestServer{
    ForEach ($IP in $RecvConnNew)
    {
        $Status = Test-Connection $IP -Count 1 2>> C:\Scripts\BadIP.csv
    }
}


# Get Current List of IP
Function GetCurrentIP{
    $RecvConnNew = (Get-ReceiveConnector "ET016-EQEXCHUB1\Internal Relay - Hub1").RemoteIPRanges
}


# Set to list of current IP on each Relay
Function CopyIP {
    ForEach ($Server in $ServerArray)
    {
        set-ReceiveConnector -Identity $Server -RemoteIPRanges $RecvConnNew
        Write-Host "Writting to:" $Server -ForegroundColor Green
    }
}



# Main Script Commands
#ExchangeConnect
GetCurrentIP
CopyIP $ServerArray
