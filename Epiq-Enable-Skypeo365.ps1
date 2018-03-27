<#  
.SYNOPSIS
   	Enable o365 Skype Account

.DESCRIPTION  
    This script will enable a user to have an o365 Skype account and assign them a P1 license for o365 Skype

.NOTES  
    Current Version     	: 1.0
    
    History			        : 1.0 - Posted 3/19/2018 - First iteration - kbennett 

        
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

# Connect to Skype
Function Connect-Lync {
    $LyncServer = "https://lyncws.epiqsystems.com/OcsPowershell"
    If ($LyncSession.ComputerName -like "lyncws.epiqsystems*") {
        Write-Host "Session already established to Lync" -ForegroundColor Green
    }
    Else {
        Write-Host "Session not made to Lync, creating session now" -ForegroundColor Red
        $script:LyncCredentials = Get-Credential
        $scripot:LyncSession = New-PSSession `
        -ConnectionUri $LyncServer `
        -Credential $LyncCredentials 
        Import-PSSession -Session $LyncSession -AllowClobber
    }

}

# Enable User if no Skype or Lync Already Exists
Function Get-User {
$Script:account = Read-Host -Prompt 'What is the users username (bsmith)?'
$Script:upn = $account+"@epiqsystems.com"
$Script:email = $account+"@epiqsystems3.mail.onmicrosoft.com"
$Script:sip = "SIP:"+$upn

Enable-CsUser -Identity $upn -SipAddress $sip -HostingProviderProxyFqdn sipfed.online.lync.com -DomainController $DomainController
Add-ADGroupMember -Identity "UG-o365-License-Skype-P1" -members $account -Server $DomainController

}

# This is the Migrate Function to move the user from OnPrem to o365
Function Migrate-User {
    $Script:upn = $account+"@epiqsystems.com"
    $Script:email = $account+"@epiqsystems3.mail.onmicrosoft.com"
    $Script:sip = "SIP:"+$upn
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

<# Manual Runs

Connect-Lync
Get-User
Migrate-User

#>