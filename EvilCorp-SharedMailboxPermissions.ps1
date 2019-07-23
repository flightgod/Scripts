<#
EvilCorp-SharedMailboxPermissions

Add-RecipientPermission <identity> -AccessRights SendAs -Trustee <user>
Get-RecipientPermission
Remove-RecipientPermission
#>

# Script Variables
param (
$ImportFile = "C:\Temp\GCGEmail.csv",
$DomainController = "P054ADSAMDC02.amer.EvilCorpCORP.COM",
$OU = "OU=Distribution Groups,OU=Exchange,OU=Corp IT,DC=amer,DC=EvilCorpCORP,DC=COM"
)

# Function to connect to o365
Function Connect-o365 {
    $O365URI = "https://outlook.office365.com/powershell-liveid/"
    If ($Session.ComputerName -like "outlook.office365.com") {
        Write-Host "Session already established to exchange" -ForegroundColor Green
    }
    Else {
        Write-Host "Session not made to exchange, creating session now" -ForegroundColor Red
        $script:o365Credential = Get-Credential
        Import-Module MSOnline
        Connect-MsolService -Credential $o365Credential
        $o365Session = New-PSSession `
        -ConfigurationName Microsoft.Exchange `
        -ConnectionUri $O365URI `
        -Authentication Basic `
        -AllowRedirection `
        -Credential $o365Credential
        Import-PSSession $o365Session
    }
}

# Checks permissions for a Mailbox
Function GetAllPermissions {
    $Script:Mailbox = Read-Host "What mailbox do you want to check? (Username)"
    Get-MailboxPermission $Mailbox | `
        Where { ($_.IsInherited -eq $False) -and -not ($_.User -like "NT AUTHORITY\SELF") } 
    Get-RecipientPermission $Mailbox | ft
}

# Gets permissions a user has to which mailboxes - Runs long
Function GetUserPermissions {
    $Script:User = Read-Host "What User do you want to check? (Username)"
    Get-Mailbox -ResultSize Unlimited | Get-MailboxPermission -User $user | Select Identity
}

# Remove permissions from a Mailbox
Function RemovePermissions {
    $Script:Mailbox = Read-Host "What mailbox do you want to Remove Permissions From? (Username)"
    $Script:User = Read-Host "What user do you want to Remove? (Username)"
    Remove-MailboxPermission -Identity $Mailbox -User $User -AccessRights {FullAccess} -Confirm:$false
    Remove-RecipientPermission $Mailbox -AccessRights SendAs -Trustee $User -Confirm:$false
}

# Adds permissions to a mailbox, and by defaults allows automap in Outlook
Function AddPermissionsAutoMap {
    $Script:Mailbox = Read-Host "What mailbox do you want to Add Permissions To? (Username)"
    $Script:User = Read-Host "What user do you want to Add? (Username)"
    Add-MailboxPermission -Identity $Mailbox -User $User -AccessRights {FullAccess}
    Add-RecipientPermission -Identity $Mailbox -AccessRights SendAs -Trustee $User -Confirm:$false

}

# adds permissions to a mailbox, but disables automap in outlook 
Function AddPermissionsNoAutoMap {
    $Script:Mailbox = Read-Host "What mailbox do you want to Add Permissions To? (Username)"
    $Script:User = Read-Host "What user do you want to Add? (Username)"
    Add-MailboxPermission -Identity $Mailbox -User $User -AccessRights {FullAccess} -AutoMapping:$false
    Add-RecipientPermission -Identity $Mailbox -AccessRights SendAs -Trustee $User -Confirm:$false
}


# Menu for this Script
Function Menu {
do
 {
     Show-Menu
     $selection = Read-Host "Please make a selection"
     switch ($selection)
     {
         '1' {
             GetAllPermissions
         } '2' {
             GetUserPermissions
         } '3' {
             AddPermissionsAutoMap
         } '4' {
             AddPermissionsNoAutoMap
         } '5' {
             RemovePermissions
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
    
    Write-Host "1: Press '1' to Check Mailbox Permissions."
    Write-Host "2: Press '2' to Check Users Permissions to Mailboxes (Lengthy)."
    Write-Host ""
    Write-Host "3: Press '3' to Add Permissiosn to a Mailbox."
    Write-Host "4: Press '4' to Add Permissions to a Mailbox wo AutoMap."
    Write-Host ""
    Write-Host "5: Press '5' to Remove Permissions to a Mailbox."
    Write-Host ""
    Write-Host "Q: Press 'Q' to quit."
    Write-Host ""
}

# Main Body of Script
Connect-o365
Menu
