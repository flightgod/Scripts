<#  
.SYNOPSIS
   	Script to get values of a distro List

.DESCRIPTION  
    This script gets the "RequreSenderAuthenticationEnabled" Value and the AcceptMessages Only from Senders or Members. If any are present
    it will reset. This should be setup to run weekly/Daily to keep SD from creating restrictive DL's that DTI cant access.

.NOTES  
    Current Version     	: 1.0
    
    History			        : 1.0 - Posted 5/19/2017 - First iteration - kbennett 

        
    Rights Required		    : Exchange Permissions 
                        	: Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     	: Error Checking
                            : Notification or some Sort i guess

.FUNCTIONALITY
    Read / Write Values in a DL Object
#>

# Variables
$ExchangeServer = "http://ET016-EQEXMBX01.amer.epiqcorp.com/PowerShell/"


Function ExchangeConnect 
{
    If ($Session.ComputerName -like "et016-eqexmbx01.amer.epiqcorp.com"){
        Write-Host "Session already established to exchange" -ForegroundColor Green
    }
    Else {
        Write-Host "Session not made to exchange, creating session now" -ForegroundColor Red
        $UserCredential = Get-Credential
        $script:Session = New-PSSession `
        -ConfigurationName Microsoft.Exchange `
        -ConnectionUri $ExchangeServer `
        -Authentication Kerberos `
        -Credential $UserCredential
        Import-PSSession $Session
    }
}


Function GetList {
    # Gets DL with Allow only internal
    $Distro = @()
    $Distro = Get-DistributionGroup -ResultSize Unlimited | Where {$_.RequireSenderAuthenticationEnabled -eq $true} | Select SamAccountName, AcceptMessagesOnlyFrom
    $Distro

    ForEach ($DL in $Distro){
          Set-DistributionGroup $Dl.SamAccountName -RequireSenderAuthenticationEnabled $False -Forceupgrade -bypassSecuritygroupManagerCheck
    }


    # Gets DL with only specific members can send to it
     Get-DistributionGroup -ResultSize Unlimited | Where {$_.AcceptMessagesOnlyFromSendersOrMembers -ne $null}

}

# Main Script Commands
ExchangeConnect