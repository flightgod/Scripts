<#  
.SYNOPSIS
   	Connect Functions

.DESCRIPTION  
    Functions for Connections

.INSTRUCTIONS
    Call this from your other scripots

.NOTES  
    Current Version     	: 1.0
    
    History			        : 1.0 - Posted 11/29/2017 - First iteration - kbennett 
        
    Rights Required		    : Exchange Permissions to Add/Edit Contacts
				            : AD Permissions to Add/Edit Objects
                        	: Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     	:

.FUNCTIONALITY

#>

# Connect to o365 exchange
### Need to make this an autoLogin ##
Function Connect-o365 {
    $O365URI = "https://outlook.office365.com/powershell-liveid/"
    If ($Session.ComputerName -like "outlook.office365.com") {
        Write-Host "Session already established to exchange" -ForegroundColor Green
    }
    Else {
        Write-Host "Session not made to exchange, creating session now" -ForegroundColor Red
        $script:o365Credential = Get-Credential
        Import-Module MSOnline
        Connect-MsolService -Credential $o365Credential
        $o365Session = New-PSSession `
        -ConfigurationName Microsoft.Exchange `
        -ConnectionUri $O365URI `
        -Authentication Basic `
        -AllowRedirection `
        -Credential $o365Credential
        Import-PSSession $o365Session
    }
}

# Connects to Exchange
## Add check to this so if you are already ward it uses that account ##
Function Connect-Exchange {
    $ExchangeServer = "http://ET016-EQEXMBX01.amer.epiqcorp.com/PowerShell/"
    # If already connected skip - makes it cleaner to look at     
    If ($Session.ComputerName -like "et016-eqexmbx01.amer.epiqcorp.com") {
        Write-Host "Session already established to exchange" -ForegroundColor Green
    }
    Else {
        Write-Host "Session not made to exchange, creating session now" -ForegroundColor Red
        $script:UserCredential = Get-Credential
        $Session = New-PSSession `
        -ConfigurationName Microsoft.Exchange `
        -ConnectionUri $ExchangeServer `
        -Authentication Kerberos `
        -Credential $UserCredential
        Import-PSSession $Session
    }
}

# Connect to Skype
Function Connect-SkypeOnline {
    Write-Host "Session not made to Skype Online, creating session now" -ForegroundColor Red
    $tenant = "epiqsystems3.onmicrosoft.com"
    Import-Module LyncOnlineConnector
    $script:SkypeOnlinecreds = get-credential
    $CSSession = New-CsOnlineSession `
    -Credential $SkypeOnlinecreds `
    -OverrideAdminDomain $tenant
    Import-PSSession $CSSession -AllowClobber
}

# Disconnects Session 
Function Session-Disconnect {
    $s = Get-PSSession
    $s
    Remove-PSSession -Session $s
}



# checks if I already put in my username and password
Function DidIAlreadyLogIn {
    If ($UserCredential.UserName -inotlike "ward_kbennett*"){
        $Script:UserCredential = Get-Credential
    }
}

# Check to see if I am already Ward
# Use with If so then dont need to provide Creds for Normal Exchagne or AD stuff
Function WhoAmI {
    
}

Function Connect-Lync {
    $LyncServer = "https://lyncws.epiqsystems.com/OcsPowershell"
    If ($Session.ComputerName -like "lyncws.epiqsystems.com") {
        Write-Host "Session already established to Lync" -ForegroundColor Green
    }
    Else {
        Write-Host "Session not made to Lync, creating session now" -ForegroundColor Red
        $script:LyncCredential = Get-Credential
        $LyncSession = New-PSSession `
        -ConnectionUri $LyncServer `
        -Credential $LyncCredentials 
        Import-PSSession -Session $LyncSession -AllowClobber
    }

}

