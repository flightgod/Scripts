<#  
.SYNOPSIS
   	Get DL Trace Log Info

.DESCRIPTION  
    This script will search Message Trace Logs for emails sent to the DL listed. This is used to see if a DL is being used
    Or who is sending to a DL for Auth Adding/Updating

.NOTES  
    Current Version     	: 1.0
    
    History			        : 1.0 - Posted 5/16/2017 - First iteration - kbennett 

        
    Rights Required		    : Exchange Permissions 
                            : o365 Powershell Permission
                        	: Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     	: 

.FUNCTIONALITY
    Read MessageTraceLog on Prem / MessageTrace in o365
#>

# Variables
$ExchangeServer = "http://ET016-EQEXMBX01.amer.epiqcorp.com/PowerShell/"
$Date = Get-Date
$Today = $Date | Get-date -Format MM/dd/yyyy
$Yesterday = $Date.AddDays(-1) | Get-Date -Format MM/dd/yyyy
$LastMonth = $Date.AddMonths(-1) | Get-date -Format MM/dd/yyyy
$LastYear = $Date.AddYears(-1) | Get-Date -Format MM/dd/yyyy
$ServerArray = @("ET016-EQEXCHUB1","ET016-EQEXCHUB2","ET008-EQEXCHUB1","ET019-EQMBX01","ET016-EX10HUB1","P054EXCTRNS01","ET016-EX10HUB2","P054EXCTRNS02","P061EXCHUBS01","P061EXCHUBS02")

$DLSearch = "ITTeams@epiqsystems.com"

Function ExchangeConnect # Connects to Exchange
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

Function o365Connect # Connects to O365
{ 
    If ($O365Session.ComputerName -like "ps.outlook.com"){
    Write-Host "Session already established to exchange" -ForegroundColor Green
    }
    Else {
        $mycreds = Get-Credential
        Import-Module MSOnline
        Connect-MsolService -Credential $mycreds
        $O365Session = New-PSSession `
        -ConfigurationName Microsoft.Exchange `
        -ConnectionUri https://ps.outlook.com/PowerShell-LiveID?PSVersion=4.0 `
        -Authentication Basic `
        -AllowRedirection `
        -Credential $mycreds
        Import-PSSession $O365Session
    }
}

Function OnPremTrace {
    ForEach ($name in $ServerArray){
        Get-MessageTrackingLog `
        -start $LastMonth `
        -End $Today `
        -Recipients $DLSearch `
        -Server $name `
        -EventId RECEIVE `
        -ResultSize 99999
    }
}

Function o365Trace {
    Get-MessageTrace -StartDate $LastMonth -EndDate $Today -RecipientAddress $DLSearch
}