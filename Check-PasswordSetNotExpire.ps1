
$Server = P016ADSUCDC01.uscust.local
$Server = P016ADSACDC01.apcust.local
$Server = P016ADSCCDC01.cacust.local
$Server = Q061ADSDQDC01.dqscust.local
$Server = P016ADSECDC01.eucust.local


# Gets List, Tries to hide some common ones
$Creds = Get-Credential
Get-ADUser -Server $Server -Credential $Creds -Filter {PasswordNeverExpires -eq $True} |`
Where {$_.Name -notlike "svc*" -and $_.Name -notlike "EQR*" -and $_.Name -notlike "ER*" -and $_.Name -notlike "Review*"} | `
Select Name

# Same as above but gets only those that are enabled
Get-ADUser -Server $Server -Credential $Creds -Filter {PasswordNeverExpires -eq $True} |`
Where {$_.Name -notlike "svc*" -and $_.Name -notlike "EQR*" -and $_.Name -notlike "ER*" -and $_.Name -notlike "Review*"  -and $_.Enabled -eq $True} | `
Select Name


# set an individual to expire
$user = twuertz
Get-ADUser -Server P016ADSUCDC01.uscust.local -Credential $Creds -Identity $user | Set-ADUser -PasswordNeverExpires $False

