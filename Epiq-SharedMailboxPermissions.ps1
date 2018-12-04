# Script Variables
param (
$ImportFile = "C:\Temp\GCGEmail.csv",
$DomainController = "P054ADSAMDC02.amer.EPIQCORP.COM",
$OU = "OU=Distribution Groups,OU=Exchange,OU=Corp IT,DC=amer,DC=EPIQCORP,DC=COM"
)

. "c:\scripts\function-Connect.ps1"

Connect-o365


Function GetAllPermissions {
    Get-MailboxPermission HSI_Questions | `
        Where { ($_.IsInherited -eq $False) -and -not ($_.User -like "NT AUTHORITY\SELF") } | `
        Select Identity,user,AccessRights
}

Function GetUserPermissions {
    Get-Mailbox -ResultSize Unlimited | Get-MailboxPermission -User username | Select Identity
}


Function RemovePermissions {
    remove-mailboxpermission -Identity HSI_Questions -User gcg_test -AccessRights {FullAccess} -Confirm:$false
}

Function AddPermissionsAutoMap {
    Add-MailboxPermission -Identity HSI_Questions -User gcg_test -AccessRights {FullAccess}

}

Function AddPermissionsNoAutoMap {
    Add-MailboxPermission -Identity HSI_Questions -User gcg_test -AccessRights {FullAccess} -AutoMapping:$false

}