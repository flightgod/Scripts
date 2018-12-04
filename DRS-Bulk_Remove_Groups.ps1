<# 

Script for DRS to remove Groups from list of users

Verson 1.0 - 8/1/18 - kbennett

NOTE - remove the -WhatIf when you are ready to run for realz

#>

#Variables
$OU = "ou=To Be Deleted,ou=DRS,OU=Employees,OU=Corp IT,DC=amer,DC=EPIQCORP,DC=COM"
$ExchangeP1 = "UG-o365-License-Exchange-P1"
$ExchangeP2 = "UG-o365-License-Exchange-P2"
$SkypeP2 = "UG-o365-License-Skype-P2"
$SkypeP1 = "UG-o365-License-Skype-P1"
$SkypeAC = "UG-o365-License-Skype-AudioConf"
$Teams = "UG-o365-License-Teams"
$SharePointP2 = "UG-o365-License-SharePoint-P2"
$SharePointP1 = "UG-o365-License-SharePoint-P1"
$DomainController = "P054ADSAMDC02.amer.EPIQCORP.COM"

# Get Ward Creds
Write-Host "Please enter your ward Creds Next"
$wardCreds = Get-Credential

# Gets all the users that are in the OU and adds to users Variable
$Users = Get-ADUser -Filter * -SearchBase $ou -Server $DomainController

# Does a count of how many users here there for sanity
$users.count
Write-host "users in this OU, they will have thier License Groups Removed" -ForegroundColor Green

# Runs through each name within the variable to start removing the Groups
forEach ($name in $users) {

        #Tells you who it is currently doing
        Write-host "running against " $name.UserPrincipalName -ForegroundColor Blue

        #Removes the member from the Group, even if it is not in the group.
        Remove-ADGroupMember -Identity $ExchangeP1 -Members $users.SamAccountName -Credential $wardCreds -Confirm:$false  -WhatIf
        Remove-ADGroupMember -Identity $SkypeP1 -Members $users.SamAccountName -Credential $wardCreds -Confirm:$false -WhatIf
        Remove-ADGroupMember -Identity $SharePointP1 -Members $users.SamAccountName -Credential $wardCreds -Confirm:$false -WhatIf
        Remove-ADGroupMember -Identity $ExchangeP2 -Members $users.SamAccountName -Credential $wardCreds -Confirm:$false -WhatIf
        Remove-ADGroupMember -Identity $SkypeP2 -Members $users.SamAccountName -Credential $wardCreds -Confirm:$false -WhatIf
        Remove-ADGroupMember -Identity $SharePointP2 -Members $users.SamAccountName -Credential $wardCreds -Confirm:$false -WhatIf
        Remove-ADGroupMember -Identity $SkypeAC -Members $users.SamAccountName -Credential $wardCreds -Confirm:$false -WhatIf
        Remove-ADGroupMember -Identity $TEams -Members $users.SamAccountName -Credential $wardCreds -Confirm:$false -WhatIf

}

Write-Line "All Done!!"