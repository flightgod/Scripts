<#  
.SYNOPSIS
   	Update Out of Office for a User

.DESCRIPTION  
    This script will Update the out of office for a specific user

.NOTES  
    Current Version     	: 1.1
    
    History			        : 1.0 - Posted 9/27/2017 - First iteration - kbennett 

        
    Rights Required		    : Permissions to Add/Edit Objects in Exchange
                        	: Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     	: Better Error Checking
                            : Variables
                            : Check for existing

             
.FUNCTIONALITY
    Update User Mailbox Settings
#>

# Connects to Exchange
Function ExchangeConnect {
    # Function Variables
    $ExchangeSession = "servername.domain.com"
    $ExchangeServer = "http://servername.domain.com/PowerShell/"

    If ($Session.ComputerName -like $ExchangeSession){
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


Function UpdateOutOfOffice {
    Set-MailboxAutoReplyConfiguration testbennettamer@domain.com `
    –AutoReplyState Enabled `
    –ExternalMessage “Hello,<br><br>

    Thank you for your email. This is a test email box and not monitored.<br><br>

    Best,<br>
    Kbennett
    ” `
    –InternalMessage “Hello,<br><br>

    Thank you for your email. This is a test email box and not monitored.<br><br>

    Best,<br>
    Kbennett
    ” 
}
