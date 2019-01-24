<#  
.SYNOPSIS
   	Create Contact

.DESCRIPTION  
    This script creates a new contact

.NOTES  
    Current Version     	: 1.0
    
    History			        : 1.0 - Posted 12/04/2018 - Kbennett

        
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
$DomainController = "P054ADSAMDC02.amer.EPIQCORP.COM"
$OU = "OU=Contacts,OU=Exchange,OU=Corp IT,DC=amer,DC=EPIQCORP,DC=COM"
$date = Get-Date -Format “MM/dd/yyyy"
$ExchangeServer = "http://P054EXCTRNS01.amer.epiqcorp.com/PowerShell/"


#Connect to Exchange
Function ExchangeConnect {
    If ($Session.ComputerName -like "P054EXCTRNS01.amer.epiqcorp.com"){
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

Function GetInfo {
    $Script:ContactName = Read-Host -Prompt "Enter the Contact Display Name"
    $Script:ExternalAddress = Read-Host -Prompt "Enter Contacts External Email"
    CheckContact
}


Function CreateContact {
    New-MailContact -name $ContactName `
    -ExternalEmailAddress $ExternalAddress `
    -confirm:$false `
    -OrganizationalUnit $ou `
    -DomainController $DomainController
    Logging

}

Function CheckContact {
    Write-Host "Checking for an existing Contact with that Email Address"
    $script:checkingContact = Get-Contact -ResultSize unlimited | Where {$_.WindowsEmailAddress -eq $ExternalAddress}
    If ($checkingContact -eq $Null) {
        Write-Host "No exiting Contact Found, Now creating" -ForegroundColor Green
        CreateContact
    } Else {
        Write-Host "Error: Exiting Contact found with email $ExternalAddress, Halting Script" -ForegroundColor Red 
    }
}

# function for logging who is creating Accounts, going to be used to also send emails to new users
Function Logging {
    $script:info = @()
    $script:LogPath = '\\P054EXGRELY01\Logs\NewMailContactLog.csv'

    $info += New-Object psobject `
                -Property @{`
                    Date=$date; `
                    Name=$ContactName; `
                    Address=$ExternalAddress; `
                    Admin=$env:USERNAME; `
                    Platform=$env:COMPUTERNAME}

    $info | Export-Csv $LogPath -Append -NoTypeInformation

}

#MainBody of Script
ExchangeConnect
GetInfo
