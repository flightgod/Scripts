<#  
.SYNOPSIS
   	Enable o365 Skype Account

.DESCRIPTION  
    This script will enable a user to have an o365 Skype account and assign them a P1 license for o365 Skype

.NOTES  
    Current Version     	: 1.5
    
    History			        : 1.0 - Posted 3/19/2018 - First iteration - kbennett 
                            : 1.1 - Posted 4/26/2018 - Updated Menu and UK Function - kbennett
                            : 1.2 - Posted 5/25/2018 - Updated Menu and HK Function - kbennett
                            : 1.3 - Posted 7/10/2018 - Commented out the HK and UK License assign - kbennett
                            : 1.4 - Posted 8/21/2018 - Fixed UK and HK Move Function to work - kbennett
                            : 1.5 - Posted 9/5/2018 - Added Logging - kbennett

        
    Rights Required		    : Permissions to Add/Edit Objects in Skype o365
                        	: Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                            : MUST USE epiqsystem3.onmicrosoft.com account for Auth
                        
    Future Features     	: Better Error Checking
                            : Variables
                            : Check for existing


             
.FUNCTIONALITY
    connect to Lync Server, Add Lync Account, Assign user to an AD Group
#>

#Variables
$target = "sipfed.online.lync.com"
$DomainController = "P054ADSAMDC02.amer.EPIQCORP.COM"
$UKDomainController = "P016ADSEUDC01.EURO.EPIQCORP.COM"
$HKDomainController = "ET016-EQAPDC03.apac.epiqcorp.com"
$date = Get-Date -Format “MM/dd/yyyy"

# Connect to Skype
Function Connect-Lync {
    $LyncServer = "https://lyncws.epiqsystems.com/OcsPowershell"
    If ($LyncSession.ComputerName -like "lyncws.epiqsystems*") {
        Write-Host "Session already established to Lync" -ForegroundColor Green
    }
    Else {
        Write-Host "Session not made to Lync, creating session now" -ForegroundColor Red
        $script:LyncCredentials = Get-Credential
        $script:sessionOption = New-PSSessionOption -SkipRevocationCheck
        $script:LyncSession = New-PSSession `
        -ConnectionUri $LyncServer `
        -Credential $LyncCredentials `
        -SessionOption $sessionOption
        Import-PSSession -Session $LyncSession -AllowClobber
    }
}

# Enable User if no Skype or Lync Already Exists
Function Get-User {
    $Script:account = Read-Host -Prompt 'What is the AMER users username (bsmith)?'
    $Script:upn = $account+"@epiqsystems.com"
    $Script:email = $account+"@epiqsystems3.mail.onmicrosoft.com"
    $Script:sip = "SIP:"+$upn
    $Script:DC = $DomainController

    Enable-CsUser -Identity $upn -SipAddress $sip -HostingProviderProxyFqdn sipfed.online.lync.com -DomainController $DC
    $script:GroupValue = Get-ADGroup "UG-o365-License-Skype-P2" -server $DomainController
    Add-ADGroupMember -Identity $GroupValue -members $account -Server $DC -Credential $LyncCredentials 
    Logging

}

# Enable User if no Skype or Lync Already Exists - for UK
Function Get-User-UK {
    $Script:account = Read-Host -Prompt 'What is the UK users username (bsmith)?'
    $Script:upn = $account+"@epiqsystems.co.uk"
    $Script:email = $account+"@epiqsystems3.mail.onmicrosoft.com"
    $Script:sip = "SIP:"+$upn
    $Script:DC = $UKDomainController

    Enable-CsUser -Identity $upn -SipAddress $sip -HostingProviderProxyFqdn sipfed.online.lync.com -DomainController $DC
    # Write-Host "Please add to Group UG-o365-Licenses-Skype-P2 manually"
    $script:GroupValue = Get-ADGroup "UG-o365-License-Skype-P2" -server $DomainController
    Add-ADPrincipalGroupMembership $account -MemberOf $GroupValue -Server $DC
    Logging
}

# Enable User if no Skype or Lync Already Exists - For APAC
Function Get-User-HK {
    $Script:account = Read-Host -Prompt 'What is the APAC users username (bsmith)?'
    $Script:upn = $account+"@epiqsystems.com.hk"
    $Script:email = $account+"@epiqsystems3.mail.onmicrosoft.com"
    $Script:sip = "SIP:"+$upn
    $Script:DC = $HKDomainController

    Enable-CsUser -Identity $upn -SipAddress $sip -HostingProviderProxyFqdn sipfed.online.lync.com -DomainController $DC
    # Write-Host "Please add to Group UG-o365-Licenses-Skype-P2 manually"
    $script:GroupValue = Get-ADGroup "UG-o365-License-Skype-P2" -Server $DomainController
    Add-ADPrincipalGroupMembership $account -MemberOf $GroupValue -Server $DC
    Logging
}

# This is the Migrate Function to move the user from OnPrem to o365
Function Migrate-User {
    Move-CsUser `
        -Identity $upn `
        -domainController $DC `
        -Target $target 
 }

# This is for Adding Audio Conferincing for Skype
Function Enable-AudoConference {
    $Script:account = Read-Host -Prompt 'What is the AMER users username (bsmith)?'
    $script:GroupValue2 = Get-ADGroup "UG-o365-License-Skype-AudioConf"
    Add-ADPrincipalGroupMembership $account -MemberOf $GroupValue2 -Server $DC
}

# A good coder would always disconnect
Function Disconnect-Session {
    Remove-PSSession $LyncSession
}

Function Menu {
do
 {
     Show-Menu
     $selection = Read-Host "Please make a selection"
     switch ($selection)
     {
         '1' {
             Get-User
         } '2' {
             GEt-User-UK
         } '3' {
             Get-User-HK
         } '4' {
            Migrate-User
         } '5' {
            Enable-AudoConference
         }
     }
     pause
 }
 until ($selection -eq 'q')
}

Function Show-Menu
{
    param (
        [string]$Title = 'Epiq o365 Skype Script'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "1: Press '1' for Enable o365 Skype for AMER User."
    Write-Host "2: Press '2' for Enable o365 Skype for UK User."
    Write-Host "3: Press '3' for Enable o365 Skype for HK User."
    Write-Host "4: Press '4' for Moving an existing user to o365 from OnPrem."
    Write-Host "5: Press '5' for Adding Skype Audio Conference to user."
    Write-Host "Q: Press 'Q' to quit."
}

# function for logging who is creating Accounts, going to be used to also send emails to new users
Function Logging 
{
    $script:info = @()
    $script:LogPath = '\\P054EXGRELY01\Logs\NewSkypeUserLog.csv'

    $info += New-Object psobject `
                -Property @{`
                    Date=$date; `
                    Name=$account; `
                    UPN=$upn; `
                    Ward=$LyncCredentials.UserName; `
                    RoutingAddress=$email; `
                    SIP=$sip; `
                    DomainController=$DC}

    $info | Export-Csv $LogPath -Append -NoTypeInformation

}

Connect-Lync
Menu
Disconnect-Session

# Function to deploy to Jump Boxes
# This is for kbennett to easily deploy script changes, do not run because it probably wont work for you
Function Deploy-Script {

    $UserCredential = Get-Credential
    $LocalPath = 'c:\Scripts\Epiq-Enable-Skypeo365.ps1'


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

