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


 foreach ($d in $distros)
{
    $DistroName = $d.name
    $group = get-adgroup $distroname -properties proxyaddresses

    set-adgroup $group -add @{proxyaddresses="smtp:" + "your seconday email address here"}
}
#>
# Script Variables
param (
$ImportFile = "C:\Temp\GCGDistro.csv",
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

Function NewDistro {
ForEach ($Script:Distro in $Import){

$NewDisplayName = "DL-" + $Distro.DisplayName
#New-DistributionGroup $Distro.DisplayName `
#    -Alias $Distro.SamAccountname `
#    -DisplayName $NewDisplayName `
#    -Notes "GCG DL" `
#    -OrganizationalUnit $OU `
#    -DomainController $DomainController `
#    -Type Distribution `
    

    $Script:NewDistro = "DL-" + $Distro.DisplayName

 
    $Script:group = get-adgroup $NewDistro -properties proxyaddresses -Server $DomainController
    set-adgroup $group -add @{proxyaddresses="smtp:" +  $Distro.PrimarySMTPAddress} -Credential $UserCredential -Server $DomainController
    set-adgroup $group -add @{Description="GCG DL"} -Credential $UserCredential -Server $DomainController
    $NewDistro
    }


}


ExchangeConnect
ImportList
NewDistro
