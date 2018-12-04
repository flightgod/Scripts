<#  
.SYNOPSIS
   	Enable o365 Mailbox

.DESCRIPTION  
    This script enables an o365 Mailbox for new users when they are created. It will also add them to the P2 License Group and
    Set thier quota Limits

.NOTES  
    Current Version     	: 1.3
    
    History			        : 1.0 - Posted 03/27/2018 - First iteration - kbennett 
                            : 1.1 - Posted 08/21/2018 - Added License Funtion - kbennett
                            : 1.2 - Posted 08/27/2018 - Added Push Function - kbennett
                            : 1.3 - Posted/Published 08/31/2018 - Added Logging - kbennett

        
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
$ExchangeServer = "http://et016-ex10hub1.amer.epiqcorp.com/PowerShell/"
$DomainController = "P054ADSAMDC02.amer.EPIQCORP.COM"
$UKDomainController = "P016ADSEUDC01.EURO.EPIQCORP.COM"
$HKDomainController = "ET016-EQAPDC03.apac.epiqcorp.com"
$date = Get-Date -Format “MM/dd/yyyy"


#Connect to Exchange
Function ExchangeConnect {
    If ($Session.ComputerName -like "et016-ex10hub1.amer.epiqcorp.com"){
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

# Runs the Add Amer User Function
Function Add-User-Amer {
    $Script:account = Read-Host -Prompt 'What is the users username (bsmith)?'
    $Script:upn = $account+"@epiqsystems.com"
    $Script:email = $account+"@epiqsystems3.mail.onmicrosoft.com"
    $Script:DC = $DomainController

    Enable-RemoteMailbox $account -RemoteRoutingAddress $email -DomainController $DC
    
    Write-host "Adding user " $upn
}

# Runs the Add UK User Function
Function Add-User-UK {
    $Script:account = Read-Host -Prompt 'What is the users username (bsmith)?'
    $Script:upn = $account+"@epiqsystems.co.uk"
    $Script:email = $account+"@epiqsystems3.mail.onmicrosoft.com"
    $Script:DC = $UKDomainController 

    Enable-RemoteMailbox $account -RemoteRoutingAddress $email -DomainController $DC
    
    Write-host "Adding user " $upn
}

# Runs the Add HK User Function
Function Add-User-HK {
    $Script:account = Read-Host -Prompt 'What is the users username (bsmith)?'
    $Script:upn = $account+"@epiqsystems.com.hk"
    $Script:email = $account+"@epiqsystems3.mail.onmicrosoft.com"
    $Script:DC = $HKDomainController

    Enable-RemoteMailbox $account -RemoteRoutingAddress $email -DomainController $DC

    Write-host "Adding user " $upn
}

# Assign License for FTE User
Function Assign-License-FTE {
    $script:GroupValue = Get-ADGroup "UG-o365-License-Exchange-P2" -server $DomainController
    Add-ADPrincipalGroupMembership $account -MemberOf $GroupValue -Server $DC
    Write-Host "Assigning P2 License to User"
    Logging
    #SetLimits-FTE
}

# Assign License for LDE User
Function Assign-License-LDE {
    $script:GroupValue = Get-ADGroup "UG-o365-License-Exchange-P1" -server $DomainController
    Add-ADPrincipalGroupMembership $account -MemberOf $GroupValue -Server $DC
    Write-Host "Assigning P1 License to User"
    Logging
    #SetLimits-LDE
}

# Runs the Set Limits on the New Mailbox Created for FTE
Function SetLimits-FTE {
    Set-Mailbox $upn -ProhibitSendQuota 95GB -ProhibitSendReceiveQuota 95GB -IssueWarningQuota 90GB -DomainController $DomainController
    Write-Host "Setting P2 Epiq Standard Limits on Mailbox"
}

# Runs the Set Limits on the New Mailbox Created LDE
Function SetLimits-LDE {
    Set-Mailbox $upn -ProhibitSendQuota 45GB -ProhibitSendReceiveQuota 45GB -IssueWarningQuota 40GB -DomainController $DomainController
    Write-Host "Setting P1 Epiq Standard Limits on Mailbox"
}

# A good Coder would also disconnect
Function Disconnect-Session {
    Remove-PSSession $Session
}

# function for logging who is creating Accounts, going to be used to also send emails to new users
Function Logging {
    $script:info = @()
    $script:LogPath = '\\P054EXGRELY01\Logs\NewMailUserLog.csv'

    $info += New-Object psobject `
                -Property @{`
                    Date=$date; `
                    Name=$account; `
                    UPN=$upn; `
                    Ward=$UserCredential.UserName; `
                    RoutingAddress=$email; `
                    ExchangeLicense=$GroupValue.Name; `
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
             Assign-License-FTE
         } '5' {
             Assign-License-LDE
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
    Write-Host "4: Press '4' to Assign License for FTE."
    Write-Host "5: Press '5' to Assign License for LDE."
    Write-Host "Q: Press 'Q' to quit."
}

# Script Main Body
    ExchangeConnect
    Menu
    Disconnect-Session

# Function to deploy to Jump Boxes
# This is for kbennett to easily deploy script changes, do not run because it probably wont work for you
Function Deploy-Script {
   
    $LocalPath = 'c:\Scripts\Epiq-Enable-o365Mailbox.ps1'

    New-PSDrive -Name "Scripts0" -PSProvider "FileSystem" -root '\\TS016-EXTOOLS\C$\Scripts' -Credential $UserCredential
        Copy-Item -Path $LocalPath -Destination 'Scripts0:'
    Remove-PSDrive -Name "Scripts0"

    New-PSDrive -Name "Scripts1" -PSProvider "FileSystem" -root '\\P054CORUTIL01\C$\Scripts' -Credential $UserCredential
        Copy-Item -Path $LocalPath -Destination 'Scripts1:'
    Remove-PSDrive -Name "Scripts1"

    New-PSDrive -Name "Scripts2" -PSProvider "FileSystem" -root '\\P054EXGRELY01\C$\Scripts' -Credential $UserCredential
        Copy-Item -Path $LocalPath -Destination 'Scripts2:'
    Remove-PSDrive -Name "Scripts2"

    New-PSDrive -Name "Scripts3" -PSProvider "FileSystem" -root '\\P054EXGRELY02\C$\Scripts' -Credential $UserCredential
        Copy-Item -Path $LocalPath -Destination 'Scripts3:'
    Remove-PSDrive -Name "Scripts3"

}

