<#  
.SYNOPSIS
   	Check Skype AD Attributes

.DESCRIPTION  
    This script Gets all the skype attributes from AD and checks that they are correct. 

.NOTES  
    Current Version     	: 1.1
    
    History			        : 1.0 - Posted 12/04/2018 - First iteration - kbennett 
                            : 1.1 - 1/17/19 - Adding International Domains - kbennett
        
    Rights Required		    : Nothing Special
                        
    Future Features     	: Better Error Checking - Check User, Check domain value

             
.FUNCTIONALITY
    Case, Menu, Get Attributes
#>

#Variables
$Script:Group = "UG-o365-License-Exchange-P2"
$Script:DomainController = "P054ADSAMDC02.amer.EPIQCORP.COM"
$Script:UKDomainController = "P054ADSEUDC01.EURO.EPIQCORP.COM"
$Script:HKDomainController = "P054ADSAPDC01.APAC.EPIQCORP.COM"
$Script:user = Read-Host "Please enter Username (EX JSmith):"

Function GetDomain {
    $script:dc=""
    $Script:Location=""
    $Script:Check =""
    $Script:Location = Read-Host -Prompt 'What domain is the user in (AMER, HK, UK)?'
    $Script:Check = $Location
    Switch ($Check) {
     UK {
        $Script:DC = $UKDomainController
        }
     HK {
        $Script:DC = $HKDomainController
        }
     AMER {
        $Script:DC = $DomainController
        }
    }
    $Check
    $DC
    
}

Function CheckSkypeSettings {

    Write-Host "Checking User: $User"

    $Script:CheckUser = Get-ADUser $User -properties * -Server $DC | Select `
    msRTCSIP-DeploymentLocator, `
    msRTCSIP-FederationEnabled, `
    msRTCSIP-InternetAccessEnabled, ` 
    msRTCSIP-OptionFlags, `
    msRTCSIP-PrimaryHomeServer, `
    msRTCSIP-PrimaryUserAddress, ` 
    msRTCSIP-UserEnabled, `
    UserPrincipalName, `
    Name, `
    proxyAddresses

    $Script:GetExchangeSIP = Get-ADuser $User -Properties proxyAddresses -Server $DC | Select {$_.ProxyAddresses -like "SIP*"}
    
    # IF ($Members -eq $Null){
    #    $Script:members = Get-ADGroupMember -Identity $group -Recursive | Select -ExpandProperty Name
    #} Else {
    #    Write-Host "Members list already populated, I am skipping to save time"
    #}

 

    $Script:Locator = "sipfed.online.lync.com"
    $Script:FedEnabled = "True"
    $Script:InetEnabled = "True"
    $Script:Option = "257"
    $Script:HomeServer = "CN=Lc Services,CN=Microsoft,CN=1:1,CN=Pools,CN=RTC Service,CN=Services,CN=Configuration,DC=EPIQCORP,DC=COM"
    $Script:UserEnabled = "True"
    $Script:PrimaryUserAddress = "sip:" + $CheckUser.UserPrincipalName
    $Script:ExchangeSIP = $GetExchangeSIP.'$_.ProxyAddresses -like "SIP*"'

    If ($CheckUser."msRTCSIP-DeploymentLocator" -eq $Locator) {
        Write-Host "msRTCSIP-DeploymentLocator Correct: $Locator" -ForegroundColor Green
        } Else {
        Write-Host "msRTCSIP-DeploymentLocator is wrong" -ForegroundColor Red
        }

    If ($CheckUser."msRTCSIP-FederationEnabled" -eq $FedEnabled) {
        Write-Host "msRTCSIP-FederationEnabled Correct: $FedEnabled" -ForegroundColor Green
        } Else {
        Write-Host "msRTCSIP-FederationEnabled is wrong" -ForegroundColor Red
        }

    If ($CheckUser."msRTCSIP-InternetAccessEnabled" -eq $InetEnabled) {
        Write-Host "msRTCSIP-InternetAccessEnabled Correct: $InetEnabled" -ForegroundColor Green
        } Else {
        Write-Host "msRTCSIP-InternetAccessEnabled is wrong" -ForegroundColor Red
        }

    If ($CheckUser."msRTCSIP-OptionFlags" -eq $Option) {
        Write-Host "msRTCSIP-OptionFlags Correct: $Option" -ForegroundColor Green
        } Else {
        Write-Host "msRTCSIP-OptionFlags is wrong" -ForegroundColor Red
        }

    If ($CheckUser."msRTCSIP-PrimaryHomeServer" -eq $HomeServer) {
        Write-Host "msRTCSIP-PrimaryHomeServer Correct: $HomeServer" -ForegroundColor Green
        } Else {
        Write-Host "msRTCSIP-PrimaryHomeServer is wrong" -ForegroundColor Red
        }

    If ($CheckUser."msRTCSIP-PrimaryUserAddress" -eq $PrimaryUserAddress) {
        Write-Host "msRTCSIP-PrimaryUserAddress Correct: $PrimaryUserAddress" -ForegroundColor Green
        } Else {
        Write-Host "msRTCSIP-PrimaryUserAddress is wrong" -ForegroundColor Red
        }

    If ($CheckUser."msRTCSIP-UserEnabled" -eq $UserEnabled) {
        Write-Host "msRTCSIP-UserEnabled Correct: $UserEnabled" -ForegroundColor Green
        } Else {
        Write-Host "msRTCSIP-UserEnabled is wrong" -ForegroundColor Red
        }
    If ($ExchangeSIP -eq $PrimaryUserAddress) {
        Write-Host "ExchangeSIP is Correct: $ExchangeSIP" -ForegroundColor Green
        } Else {
        Write-Host "ExchangeSIP is wrong: $ExchangeSIP vs $PrimaryUserAddress" -ForegroundColor Red
        }

   <# If ($members -contains $CheckUser.Name) {
        Write-Host "$user exists in the group $group" -ForegroundColor Green
    } Else {
        Write-Host "$user not exists in the $group" -ForeGroundColor Red
    }#>

}

# Script Main
GetDomain
CheckSkypeSettings



# Function to deploy to Jump Boxes
# This is for kbennett to easily deploy script changes, do not run because it probably wont work for you
Function Deploy-Script {
   
    $LocalPath = 'c:\Scripts\Epiq-Check-SkypeSettings.ps1'
    $UserCredential = Get-Credential

    New-PSDrive -Name "Scripts0" -PSProvider "FileSystem" -root '\\TS016-EXTOOLS\C$\Scripts' -Credential $UserCredential
        Copy-Item -Path $LocalPath -Destination 'Scripts0:'
    Remove-PSDrive -Name "Scripts0"

    New-PSDrive -Name "Scripts1" -PSProvider "FileSystem" -root '\\P054CORUTIL01\C$\Scripts' -Credential $UserCredential
        Copy-Item -Path $LocalPath -Destination 'Scripts1:'
    Remove-PSDrive -Name "Scripts1"

    New-PSDrive -Name "Scripts1" -PSProvider "FileSystem" -root '\\P054CORUTIL02\C$\Scripts' -Credential $UserCredential
        Copy-Item -Path $LocalPath -Destination 'Scripts1:'
    Remove-PSDrive -Name "Scripts1"

    New-PSDrive -Name "Scripts2" -PSProvider "FileSystem" -root '\\P054EXGRELY01\C$\Scripts' -Credential $UserCredential
        Copy-Item -Path $LocalPath -Destination 'Scripts2:'
    Remove-PSDrive -Name "Scripts2"

    New-PSDrive -Name "Scripts3" -PSProvider "FileSystem" -root '\\P054EXGRELY02\C$\Scripts' -Credential $UserCredential
        Copy-Item -Path $LocalPath -Destination 'Scripts3:'
    Remove-PSDrive -Name "Scripts3"

}