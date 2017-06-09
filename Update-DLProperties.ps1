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

# Gets DL with Allow only internal
Function GetListLimited {
    Write-Host "Checking for Groups that are set to only accept email from internal users"
    $Script:Distro = @()
    $Distro = Get-DistributionGroup -ResultSize Unlimited | Where {$_.RequireSenderAuthenticationEnabled -eq $true} | Select SamAccountName, AcceptMessagesOnlyFrom
    If ($Distro -eq $NULL){
        Write-Host "No Groups Found"
    } 
    Else {
        Write-host "Found:"
        $Distro
        #SetListLimitedOff
    }
}

# Sets DL with Allow Only Internal On to Off
Function SetListLimitedOff {
    ForEach ($DL in $Distro){
        Write_host "Setting Value to False on the above DL's"
        Set-DistributionGroup $Dl.SamAccountName -RequireSenderAuthenticationEnabled $False -Forceupgrade -bypassSecuritygroupManagerCheck
    }
}

# Gets DL with only specific members can send to it
Function GetListMembers {
    write-host "Checking for Groups that only allow specific members to send to it"
    $PermittedToSend = Get-DistributionGroup -ResultSize Unlimited | Where {$_.AcceptMessagesOnlyFromSendersOrMembers -ne $null}
    $PermittedToSend.count
    $PermittedToSend
}

# Main Script Commands
ExchangeConnect
GetListLimited
GetListMembers