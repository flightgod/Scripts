Import-Module LyncOnlineConnector
$creds = get-credential
$CSSession = New-CsOnlineSession -Credential $creds -OverrideAdminDomain epiqsystems3.onmicrosoft.com
Import-PSSession $CSSession -AllowClobber


Move-CsUser -Identity kbennett@epiqsystems.com -domainController P054ADSAMDC01.amer.EPIQCORP.COM -Target sipfed.online.lync.com -HostedMigrationOverrideUrl https://admin1a.online.lync.com/HostedMigration/hostedmigrationservice.svc -Credentials $cred

