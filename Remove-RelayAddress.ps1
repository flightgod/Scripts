<#  
.SYNOPSIS
   	Remove Receive Connector Authorized IP's

.DESCRIPTION  
    This script will remove IP address from SMTP Relay

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
$Relay1 = "HUB1\Internal Relay - Hub1"
$Relay2 =  "HUB2\Internal Relay - Hub2"
$ExchangeServer = "http://MBX01.amer.domain.com/PowerShell/"
$ServerArray = @("HUB1\Internal Relay - Hub1", "HUB2\Internal Relay - Hub2")

# Connects to Exchange
Function ExchangeConnect 
{
    If ($Session.ComputerName -like "mbx01.amer.domain.com"){
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


#Remove IP from Connector
Function RemoveIP {
    # Here I need to get the list of bad IP's and put in $IPAddress
    $IPAddress = Read-Host "Enter IP to Remove"
    # Go get the complete list in the Connector
    IPFormatCheck
    $RcvConnectors = (Get-ReceiveConnector $Relay1).RemoteIPRanges
    # Calls to function to check if IP exists in List
    IPPresentCheck
      # Prompt to continue
    Write-Host "Are you sure you would like to remove " -NoNewLine
    Write-Host $IPAddress -ForegroundColor Green -NoNewLine
    $IPAddressCont = Read-Host " from the receive connectors? (Y/N)"  
    IF ($IPAddressCont -eq "y"){
        foreach ($Server in $ServerArray) {
            Write-Host "Removing IP Address:" $IPAddress " from " $Server -ForegroundColor Cyan
            # Removes IP from Array
            $RcvConnectors.Remove($IPAddress)
            # Puts new array in Relay
            Set-ReceiveConnector $Server -RemoteIPRanges $RcvConnectors
        }
    }
    Else {
        Break
    }
    # Run Again?
    RunAgain
   }

# Test that IP is correct Format
Function IPFormatCheck {
    $pattern = '^(?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)$'
    $IPOK = $IPAddress -match $pattern
    IF ($IPOK -eq $false) {
        Write-Warning ("IP Address {0} is not a valid IPv4 address." -f $IPAddress)
        RunAgain
    }
    ELSE{
        Write-host "IP Address"$ipAddress "is valid." -ForegroundColor Green
    }
}

# See if the IP is in the Connector Currently
Function IPPresentCheck {
    if ($RcvConnectors -contains $ipAddress) {
	    Write-host -foregroundcolor green "$ipAddress exists in $Relay1"
	} 
    else {
		Write-host -foregroundcolor yellow "$ipAddress Is not Present $Relay1"
        RunAgain
	}
}

Function RunAgain {
$YNRunAgain = Read-Host "Do you want to run the Remove IP Process again (Y/N) "
    IF ($YNRunAgain -eq "y"){
        RemoveIP
    } 
    Else {
        Break
    }    
}


# Main Script 
ExchangeConnect
RemoveIP
