# Script Variables
param (
$ImportFile = "C:\Temp\GCGEmail.csv",
$DomainController = "P054ADSAMDC02.amer.EvilCorpCORP.COM",
$OU = "OU=Distribution Groups,OU=Exchange,OU=Corp IT,DC=amer,DC=EvilCorpCORP,DC=COM"
)


# Connects to Exchange
Function ExchangeConnect {
    # Function Variables
    $ExchangeSession = "et016-eqexmbx01.amer.EvilCorpcorp.com"
    $ExchangeServer = "http://ET016-EQEXMBX01.amer.EvilCorpcorp.com/PowerShell/"

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

        $alias1 = $user.EvilCorpSam + "@gardencitygroup.com"
        $alias2 = $user.EvilCorpSam + "@gcginc.com"
        Get-RemoteMailbox -Identity $User.EvilCorpSam -DomainController $DomainController
        Set-ADUser `
        -Identity $User.EvilCorpSam `
        -add @{"extensionattribute13" = $user.GCGEmail} -Credential $UserCredential
    }
}



Function SetLimits {
    ForEach ($Script:User in $Import){
        Set-RemoteMailbox $User.EvilCorpSam -ProhibitSendQuota 95GB -ProhibitSendReceiveQuota 95GB -IssueWarningQuota 90GB 
    }
}


ExchangeConnect
ImportList
setLimits


# Set-ADUser –Identity $ThisUser -add @{"extensionattribute1"="MyString"}
