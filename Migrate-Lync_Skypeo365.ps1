<#  
.SYNOPSIS
   	xxxx

.DESCRIPTION  
    xxxx

.NOTES  
    Current Version     	: 1.1
    
    History			        : 1.0 - Posted 9/27/2017 - First iteration - kbennett 

        
    Rights Required		    : Permissions to Add/Edit Objects in Skype o365
                        	: Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                            : MUST USE epiqsystem3.onmicrosoft.com account for Auth
                        
    Future Features     	: Better Error Checking
                            : Variables
                            : Check for existing
                            : Assign License

             
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

# This is the Migrate Function to move the user from OnPrem to o365
Function Migrate {
    Move-CsUser `
        -Identity $username `
        -domainController $dc `
        -Target $target `
        -HostedMigrationOverrideUrl $url `
        -Credential $creds
    Grant-CsClientPolicy -Identity $username -PolicyName ClientPolicyNoSaveIMNoArchiving 

}

# This is the Enable function. If user is not on prem this will create them in o365
Function Enable {
    Enable-CsUser `
        -Identity $Username `
        -SipAddress "sip:sthawari@epiqsystems.com" `
        -HostingProviderProxyFqdn $target
}

# Gets a users info from the Lync/Skype Database
Function GetUser {
    Get-CSUser $username

}

ConnectSkype
Migrate