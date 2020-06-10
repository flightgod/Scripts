# Script Variables
param (
$ImportFile = "C:\Temp\GCGEmail.csv",
$DomainController = "server.amer.domain.COM",
$OU = "OU=Distribution Groups,OU=Exchange,OU=Corp IT,DC=amer,DC=domain,DC=COM"
)


# Connects to Exchange
Function ExchangeConnect {
    # Function Variables
    $ExchangeSession = "mbx01.amer.domain.com"
    $ExchangeServer = "http://MBX01.amer.domain.com/PowerShell/"

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


ForEach ($entry in $pull){
$user = $entry.SamAccountName
$NewRemoteRoutingAddress = $user + "@domain.mail.onmicrosoft.com"
$NewRemoteRoutingAddress
Set-RemoteMailbox $user -RemoteRoutingAddress $NewRemoteRoutingAddress
Get-remotemailbox $user | select RemoteRoutingAddress
}

$Pull > c:\temp\Pull.txt


$Pull2 = get-remotemailbox -ResultSize Unlimited | ? {$_.RemoteRoutingAddress -like "*.microsoft.com"} | Select SamAccountname, RemoteRoutingAddress
