<#  
.SYNOPSIS
   	Enable o365 Mailbox

.DESCRIPTION  
    This script enables an o365 Mailbox for new users when they are created. It will also add them to the P2 License Group and
    Set thier quota Limits

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
$ExchangeServer = "http://et016-ex10hub1.amer.epiqcorp.com/PowerShell/"
$DomainController = "P054ADSAMDC02.amer.EPIQCORP.COM"

#Connect to Exchange
Function ExchangeConnect {
    If ($Session.ComputerName -like "et016-ex10hub1.amer.epiqcorp.com"){
        Write-Host "Session already established to exchange" -ForegroundColor Green
    }
    Else {
        Write-Host "Session not made to exchange, creating session now" -ForegroundColor Red
        $Script:UserCredential = Get-Credential
        $Script:Session = New-PSSession `
        -ConfigurationName Microsoft.Exchange `
        -ConnectionUri $ExchangeServer `
        -Authentication Kerberos `
        -Credential $UserCredential
        Import-PSSession $Session
    }
}

# Runs the Add User Function
Function Add-User {
    $Script:account = Read-Host -Prompt 'What is the users username (bsmith)?'
    $Script:upn = $account+"@epiqsystems.com"
    $Script:email = $account+"@epiqsystems3.mail.onmicrosoft.com"

    Enable-RemoteMailbox $account -RemoteRoutingAddress $email -DomainController $DomainController
    Add-ADGroupMember -Identity "UG-o365-License-Exchange-P1" -members $account -Server $DomainController
    #Write-host "Please add user to proper License AD Group per thier role manually"
    Write-host "Adding user " $upn
    #SetLimits
}

# Runs the Set Limits on the New Mailbox Created Above
Function SetLimits {
    Set-Mailbox $upn -ProhibitSendQuota 95GB -ProhibitSendReceiveQuota 95GB -IssueWarningQuota 90GB -DomainController $DomainController
    Write-Host "Setting Epiq Standard Limits on Mailbox"
    Read-Host "Press any key to exit..."

}

# A good Coder would also disconnect
Function Disconnect-Session {
    Remove-PSSession $Session
}

# Script Main Body
    ExchangeConnect
    Add-User
    #Disconnect-Session