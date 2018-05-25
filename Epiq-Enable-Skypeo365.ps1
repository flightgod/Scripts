<#  
.SYNOPSIS
   	Enable o365 Skype Account

.DESCRIPTION  
    This script will enable a user to have an o365 Skype account and assign them a P1 license for o365 Skype

.NOTES  
    Current Version     	: 1.1
    
    History			        : 1.0 - Posted 3/19/2018 - First iteration - kbennett 
                            : 1.1 - Posted 4/26/2018 - Updated Menu and UK Function - kbennett
                            : 1.2 - Posted 5/25/2018 - Updated Menu and HK Function - kbennett

        
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
$UKDomainController = "EURO.EPIQCORP.COM"
$HKDomainController = "apac.epiqcorp.com"

# Connect to Skype
Function Connect-Lync {
    $LyncServer = "https://lyncws.epiqsystems.com/OcsPowershell"
    If ($LyncSession.ComputerName -like "lyncws.epiqsystems*") {
        Write-Host "Session already established to Lync" -ForegroundColor Green
    }
    Else {
        Write-Host "Session not made to Lync, creating session now" -ForegroundColor Red
        $script:LyncCredentials = Get-Credential
        $script:LyncSession = New-PSSession `
        -ConnectionUri $LyncServer `
        -Credential $LyncCredentials 
        Import-PSSession -Session $LyncSession -AllowClobber
    }

}

# Enable User if no Skype or Lync Already Exists
Function Get-User {
    $Script:account = Read-Host -Prompt 'What is the AMER users username (bsmith)?'
    $Script:upn = $account+"@epiqsystems.com"
    $Script:email = $account+"@epiqsystems3.mail.onmicrosoft.com"
    $Script:sip = "SIP:"+$upn

    Enable-CsUser -Identity $upn -SipAddress $sip -HostingProviderProxyFqdn sipfed.online.lync.com -DomainController $DomainController
    Add-ADGroupMember -Identity "UG-o365-License-Skype-P1" -members $account -Server $DomainController
}

# Enable User if no Skype or Lync Already Exists - for UK
Function Get-User-UK {
    $Script:account = Read-Host -Prompt 'What is the UK users username (bsmith)?'
    $Script:upn = $account+"@epiqsystems.co.UK"
    $Script:email = $account+"@epiqsystems3.mail.onmicrosoft.com"
    $Script:sip = "SIP:"+$upn

    Enable-CsUser -Identity $upn -SipAddress $sip -HostingProviderProxyFqdn sipfed.online.lync.com -DomainController $UKDomainController
    Add-ADGroupMember -Identity "UG-o365-License-Skype-P1" -members $account -Server $UKDomainController
}

# Enable User if no Skype or Lync Already Exists - For APAC
Function Get-User-HK {
    $Script:account = Read-Host -Prompt 'What is the APAC users username (bsmith)?'
    $Script:upn = $account+"@epiqsystems.com.hk"
    $Script:email = $account+"@epiqsystems3.mail.onmicrosoft.com"
    $Script:sip = "SIP:"+$upn

    Enable-CsUser -Identity $upn -SipAddress $sip -HostingProviderProxyFqdn sipfed.online.lync.com -DomainController $HKDomainController
    Add-ADGroupMember -Identity "UG-o365-License-Skype-P1" -members $account -Server $HKDomainController
}

# This is the Migrate Function to move the user from OnPrem to o365
Function Migrate-User {
    $Script:upn = $account+"@epiqsystems.com"
    Move-CsUser `
        -Identity $upn `
        -domainController $DomainController `
        -Target $target 
 
    Add-ADGroupMember -Identity "UG-o365-License-Skype-P1" -members $account -Server $DomainController
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
         }
     }
     pause
 }
 until ($selection -eq 'q')
}

function Show-Menu
{
    param (
        [string]$Title = 'Skype Script'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "1: Press '1' for Enable o365 Skype for AMER User."
    Write-Host "2: Press '2' for Enable o365 Skype for UK User."
    Write-Host "3: Press '3' for Enable o365 Skype for HK USer."
    Write-Host "3: Press '4' for Moving an existing user to o365 from OnPrem."
    Write-Host "Q: Press 'Q' to quit."
}

Connect-Lync
Menu