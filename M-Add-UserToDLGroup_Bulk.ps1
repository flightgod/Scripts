<#
 Create Distribution List

 
 
 -Alias
 -DisplayName
 -DomainController
 -OrganizationalUnit
 -Members
 -ManagedBy
 -Type <Distribution | Security>]
 -RequireSenderAuthenticationEnabled <$true | $false>]


 $Distro.DisplayName = Displayname
 $Distro.PrimarySMTPAddress
 $Distro.SamAccountname = Alias
 #>
# Script Variables
param (
$ImportFile = "C:\Temp\DLGroupMembers.csv",
$DomainController = "P054ADSAMDC02.amer.EPIQCORP.COM",
$OU = "OU=Distribution Groups,OU=Exchange,OU=Corp IT,DC=amer,DC=EPIQCORP,DC=COM"
)


# Connects to Exchange
Function ExchangeConnect {
    # Function Variables
    $ExchangeSession = "et016-eqexmbx01.amer.epiqcorp.com"
    $ExchangeServer = "http://ET016-EQEXMBX01.amer.epiqcorp.com/PowerShell/"

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
        $User.Group
        $User.UserName 
        Add-ADGroupMember -Identity $User.Group -Members $User.UserName -Server $DomainController -Credential $UserCredential
    }
}

ExchangeConnect
ImportList
AddUser