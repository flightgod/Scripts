# Script Variables
param (
$ImportFile = "C:\Temp\NewEmail.csv",
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


# Function import list of users
Function ImportList {
    $test = Test-Path $ImportFile
    If ($test -eq $true) {
        $script:import = Import-csv $ImportFile
    }
    Else {
        Write-Warning "Something went Wrong: File is missing at $ImportFile"
        Break
    }
}



Function AddUser {
    ForEach ($Script:User in $Import){

        $alias1 = $user.domainSam + "@domain.com"
        $alias2 = $user.domainSam + "@domain1.com"
        Get-RemoteMailbox -Identity $User.EpiqSam -DomainController $DomainController
        Set-ADUser `
        -Identity $User.domainsam `
        -add @{"extensionattribute13" = $user.newEmail} -Credential $UserCredential
    }
}



Function SetLimits {
    ForEach ($Script:User in $Import){
        Set-RemoteMailbox $User.domainsam -ProhibitSendQuota 95GB -ProhibitSendReceiveQuota 95GB -IssueWarningQuota 90GB 
    }
}


ExchangeConnect
ImportList
setLimits


# Set-ADUser –Identity $ThisUser -add @{"extensionattribute1"="MyString"}
