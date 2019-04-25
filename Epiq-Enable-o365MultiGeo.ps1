<#  
.SYNOPSIS
   	Enable o365 Multi Geo

.DESCRIPTION  
    This script enables an o365 Geo-Locking which enables Data to be stored in a specific Geo Location

.NOTES  
    Current Version     	: 1.0
    
    History			        : 1.0 - Posted 01/08/2019 - First iteration - kbennett 
        
    Rights Required		    : Permissions to Add/Edit Objects in Active Directory
                        	: Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     	: Better Error Checking
                            : Variables
                            : Check for existing
             
.FUNCTIONALITY
    xxxx
#>

#Variables
$Script:DomainController = "P054ADSAMDC02.amer.EPIQCORP.COM"
$Script:UKDomainController = "P054ADSEUDC01.EURO.EPIQCORP.COM"
$Script:HKDomainController = "P054ADSAPDC01.APAC.EPIQCORP.COM"
$date = Get-Date -Format “MM/dd/yyyy"
$Script:UserCredential = Get-Credential

#NEW -------------------------------------------------------------------------
Function GetDomain {
    $script:dc=""
    $Script:DomainLocation=""
    $Script:DomainLocation = Read-Host -Prompt 'What domain is the user in (AMER, HK, UK)?'
    $Script:Location = $DomainLocation
    Switch ($Location) {
     UK {
        $Script:DC = $UKDomainController
        }
     HK {
        $Script:DC = $HKDomainController
        }
     AMER {
        $ScriptDC = $DomainController
        }
    }
    $Location
    $DC
    GetUser
}

#NEW ----------------------------------------------------------------------
Function GetUser {
    $Script:account = Read-Host -Prompt 'What is the users username (bsmith)?'
    $Script:ADValues = Get-ADUser $account -Prop extensionAttribute9 -Server $DC
   
    If ($ADValues.extensionAttribute9 -eq $NULL){
        Get-Location
    } ELSE {
        Write-host "User Has Value: " $ADValues.extensionAttribute9
    }
}

# Runs the Add Amer User Function
Function Add-User-Amer {
    $Script:account = Read-Host -Prompt 'What is the users username (bsmith)?'
    $Script:DC = $DomainController
    $Script:ADValues = Get-ADUser $account -Prop extensionAttribute9 -Server $DC
   
    If ($ADValues.extensionAttribute9 -eq $NULL){
        Get-Location
    } ELSE {
        Write-host "User Has Value: " $ADValues.extensionAttribute9
    }
}

# Runs the Add UK User Function
Function Add-User-UK {
    $Script:account = Read-Host -Prompt 'What is the users username (bsmith)?'
    $Script:DC = $UKDomainController
    $Script:ADValues = Get-ADUser $account -Prop extensionAttribute9 -Server $UKDomainController
   
    If ($ADValues.extensionAttribute9 -eq $NULL){
        Get-Location
    } ELSE {
        Write-host "User Has Value: " $ADValues.extensionAttribute9
    }
}

# Runs the Add HK User Function
Function Add-User-HK {
    $Script:account = Read-Host -Prompt 'What is the users username (bsmith)?'
    $Script:DC = $HKDomainController
    $Script:ADValues = Get-ADUser $account -Prop extensionAttribute9 -Server $DC
   
    If ($ADValues.extensionAttribute9 -eq $NULL){
        Get-Location
    } ELSE {
        Write-host "User Has Value: " $ADValues.extensionAttribute9
    }
}

# Assign License for FTE User
Function Assign-License {
    $script:GroupValue = Get-ADGroup "UG-o365-License-MultiGeo" -server $DomainController
    Add-ADPrincipalGroupMembership $account -MemberOf $GroupValue -Server $DC -Credential $UserCredential
    Write-Host "Assigning MultiGeo License"
    #Logging

}

Function Get-Location {
    $Script:LocationValue = @("NAM","GBR","CAN","AUS","EUR","APC") | `
        Out-GridView -Title "Select Location to assign" -PassThru | `
        Select-Object -ExpandProperty $LocationValue
        Set-Values
}

Function Set-Values {

    Set-ADUser $account -add @{"extensionattribute9"=$LocationValue} -Server $DC -Credential $UserCredential
    Write-host  "Assigning User: " $Account " Location: " $LocationValue
    Assign-License

    }

# remove Values and License to back out what was done
Function Remove-Values {
    
    Set-ADUser $account -clear "extensionattribute9" -Server $DC -Credential $UserCredential
    Write-host  "Removing Value from User: " $Account " Location: " $LocationValue 

}


# A good Coder would also disconnect
Function Disconnect-Session {
    Remove-PSSession $Session
}

# function for logging who is creating Accounts, going to be used to also send emails to new users
Function Logging {
    $script:info = @()
    $script:LogPath = '\\P054EXGRELY01\Logs\NewMultiGeoUserLog.csv'

    $info += New-Object psobject `
                -Property @{`
                    Date=$date; `
                    Name=$account; `
                    Ward=$env:username; `
                    PerferedLocation=$ADValues.extensionAttribute9; `
                    DomainController=$DC}

    $info | Export-Csv $LogPath -Append -NoTypeInformation

}

Function Menu {
do
 {
     Show-Menu
     $selection = Read-Host "Please make a selection"
     switch ($selection)
     {
         '1' {
             Add-User-Amer
         } '2' {
             Add-User-UK
         } '3' {
             Add-User-HK
         } '4' {
            Remove-Values
         }
     }
     pause
 }
 until ($selection -eq 'q')
}

function Show-Menu
{
    param (
        [string]$Title = 'o365 Mailbox Script'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "1: Press '1' to Add AMER User."
    Write-Host "2: Press '2' to Add UK User."
    Write-Host "3: Press '3' to Add HK User."
    Write-Host "4: Press '4' to Remove Values."
    Write-Host "Q: Press 'Q' to quit."
}


# Script Main Body
    Menu
    Disconnect-Session

# Function to deploy to Jump Boxes
# This is for kbennett to easily deploy script changes, do not run because it probably wont work for you
Function Deploy-Script {
   
    $LocalPath = 'c:\Scripts\Epiq-Enable-o365MultiGeo.ps1'
    
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




