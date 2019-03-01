<#

Get list of users that are not syncing with AD because of Value
See if a user is set to not sync
Set a user to not sync
Remove a not sync value from a user

#>

$DomainController = "P054ADSAMDC02.amer.EPIQCORP.COM"
$UKDomainController = "P054ADSEUDC01.EURO.EPIQCORP.COM"
$HKDomainController = "P054ADSAPDC01.APAC.EPIQCORP.COM"

# Get which domain the user will be in
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
}




# Get the User
Function Get-User {
    $Script:User = Read-Host -Prompt 'What is the users username (bsmith)?'
    $script:CheckedUser = Get-ADUser $user -Properties extensionAttribute10 -Server $dc | Select UserPrincipalName, extensionAttribute10
}

Function CheckForAll {
 Get-ADUser -Filter * -properties extensionAttribute10 | ? {$_.extensionAttribute10 -eq "nomsazuresync" -and $_.SamAccountName -inotlike "*_*"} | Select UserPrincipalName
}

Function Check-UserSetting {
    If ($CheckedUser.extensionAttribute10 -eq $Null) {
        Write-Host "Attribute not set for user " $CheckedUser.UserPrincipalName -ForegroundColor Yellow
    } Else {
        Write-Host "Attribute Set as " $CheckedUser.extensionAttribute10 -ForegroundColor Blue
    }

}

Function Set-UserBlock {
    Get-Domain
    Get-User

    Set-ADUser -Identity $User -Add @{'extensionAttribute10' = "nomsazuresync"} -Server $DC

    Write-Host "Changes made to AD account.  Wait for at least 45 minutes before testing."  -foregroundcolor green
    Read-Host -Prompt "Press Enter to exit"
    #Logging

}

Function Remove-UserBlock {
    Get-Domain
    Get-User
    Set-ADUser -Identity $User -remove @{'extensionAttribute10' = "nomsazuresync"} -Server $DC
    Write-Host "Changes made to AD account.  Wait for at least 45 minutes before testing."  -foregroundcolor green
    Read-Host -Prompt "Press Enter to exit"
    #Logging
}


Function Menu {
do
 {
     Show-Menu
     $selection = Read-Host "Please make a selection"
     switch ($selection)
     {
         '1' {
             CheckForAll
         } '2' {
             Get-Domain
             Get-User
             Check-UserSetting
         } '3' {
            Set-UserBlock
         } '4' {
            Remove-UserBlock
         } '5' {
            
         }
     }
     pause
 }
 until ($selection -eq 'q')
}

Function Show-Menu
{
    param (
        [string]$Title = 'o365 Sync Menu'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "1: Press '1' for Check who is disabled to sync."
    Write-Host "2: Press '2' for Check if user is disabled."
    Write-Host "3: Press '3' for Add Sync Block to user."
    Write-Host "4: Press '4' for remove block from user."
    Write-Host "5: Press '5' for xxxx."
    Write-Host "Q: Press 'Q' to quit."
}

Menu