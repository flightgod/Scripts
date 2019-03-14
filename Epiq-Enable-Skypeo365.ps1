<#  
.SYNOPSIS
   	Enable o365 Skype Account

.DESCRIPTION  
    This script will enable a user to have an o365 Skype account and assign them a P1 license for o365 Skype

.NOTES  
    Current Version     	: 1.6
    
    History			        : 1.0 - Posted 3/19/2018 - First iteration - kbennett 
                            : 1.1 - Posted 4/26/2018 - Updated Menu and UK Function - kbennett
                            : 1.2 - Posted 5/25/2018 - Updated Menu and HK Function - kbennett
                            : 1.3 - Posted 7/10/2018 - Commented out the HK and UK License assign - kbennett
                            : 1.4 - Posted 8/21/2018 - Fixed UK and HK Move Function to work - kbennett
                            : 1.5 - Posted 9/5/2018 - Added Logging - kbennett
                            : 1.6 - Posted 1/21/2019 - Added Domain Check, and Updated for Setting Attributes - kbennett

        
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
        $Global:LyncCredentials = Get-Credential
        $script:sessionOption = New-PSSessionOption -SkipRevocationCheck
        $script:LyncSession = New-PSSession `
        -ConnectionUri $LyncServer `
        -Credential $LyncCredentials `
        -SessionOption $sessionOption
        Import-PSSession -Session $LyncSession -AllowClobber
    }
}


Function Get-Domain {
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
    Get-User
}

# Enable User if no Skype or Lync Already Exists
Function Get-User {
    $Global:User = Read-Host -Prompt 'What is the users username (bsmith)?'

    Set-ADUser -Identity $User -Add @{'msRTCSIP-DeploymentLocator' = "sipfed.online.lync.com"} -Server $DC
    Set-ADUser -Identity $User -Add @{'msRTCSIP-FederationEnabled' = "TRUE"} -Server $DC
    Set-ADUser -Identity $User -Add @{'msRTCSIP-InternetAccessEnabled' = "TRUE"} -Server $DC
    Set-ADUser -Identity $User -Add @{'msRTCSIP-OptionFlags' = "257"} -Server $DC
    Set-ADUser -Identity $User -Add @{'msRTCSIP-PrimaryHomeServer' = "CN=Lc Services,CN=Microsoft,CN=1:1,CN=Pools,CN=RTC Service,CN=Services,CN=Configuration,DC=EPIQCORP,DC=COM"} -Server $DomainController
    Set-ADUser -Identity $User -Add @{'msRTCSIP-PrimaryUserAddress' = "sip:$User@epiqsystems.com"} -Server $DC
    Set-ADUser -Identity $User -Add @{'msRTCSIP-UserEnabled' = "TRUE"} -Server $DC

    $Global:email = $user.Mail
    $Global:sip = "$user@epiqsystems.com"


    Write-Host "Changes made to AD account.  Wait for at least 45 minutes before testing."  -foregroundcolor green
    Read-Host -Prompt "Press Enter to exit"
    Logging

}

# Function to do another user on same domain
Function Do-Again {
    $Script:Again=$NULL
    $Again = Read-Host -Promp 'Do you wnat to add another user on same domain? (Y/N)'
    Switch ($Again) {
        Y {
            Get-User
           }
        N {
            
            }
     } 

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
             Get-Domain
         } '2' {
             .\Epiq-Check-SkypeSettings.ps1
         } '3' {
             Show-Menu
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
    
    Write-Host "1: Press '1' for Enable o365 Skype for User."
    Write-Host "2: Press '2' for Check Skype Settings for a user."
    Write-Host "3: Press '3' for xxxxx."
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
                    Name=$user; `
                    UPN=$upn; `
                    Ward=$LyncCredentials.UserName; `
                    RoutingAddress=$email; `
                    SIP=$sip; `
                    DomainController=$DC}

    $info | Export-Csv $LogPath -Append -NoTypeInformation

}

#Connect-Lync
Menu
Disconnect-Session