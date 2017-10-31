<#  
.SYNOPSIS
   	xxxx

.DESCRIPTION  
    xxxx

.NOTES  
    Current Version     	: 1.1
    
    History			        : 1.0 - Posted 9/27/2017 - First iteration - kbennett 

        
    Rights Required		    : Permissions to Add/Edit Objects in Exchange
                        	: Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     	: Better Error Checking
                            : Variables
                            : Check for existing

             
.FUNCTIONALITY
    xxxx
#>

#Variables
$username = "rsweeney@epiqsystems.com"
$dc = "P054ADSAMDC01.amer.EPIQCORP.COM"
$target = "sipfed.online.lync.com"
$url = "https://admin1a.online.lync.com/HostedMigration/hostedmigrationservice.svc"
$tenant = "epiqsystems3.onmicrosoft.com"

# Connect to Skype
Function ConnectSkype {
    Import-Module LyncOnlineConnector
    $script:creds = get-credential
    $CSSession = New-CsOnlineSession -Credential $creds -OverrideAdminDomain $tenant
    Import-PSSession $CSSession -AllowClobber
}

Function Migrate {
    Move-CsUser `
        -Identity $username `
        -domainController $dc `
        -Target $target `
        -HostedMigrationOverrideUrl $url `
        -Credential $creds
    Grant-CsClientPolicy -Identity $username -PolicyName ClientPolicyNoSaveIMNoArchiving 

}

Function Enable {
    Enable-CsUser `
        -Identity $Username `
        -SipAddress "sip:sthawari@epiqsystems.com" `
        -HostingProviderProxyFqdn $target
}

Function GetUser {
    Get-CSUser $username

}

ConnectSkype
Migrate