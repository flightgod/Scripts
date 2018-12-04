<#

Pass 1
Zero Read, Received and Sent
- Remove o365 License
- Disabled AD
- Move AD to disabled OU
- Update notes in AD


Pass 2
Zero Read, Sent, But have Recieved Emails
- Remove o365 License (* after 14 days)
- Disable AD
- Move AD to Disable OU
- Update Notes in AD

TODO - Run Cleanup1 again and look for users not in amer.

#>
#Variables
$Pass1 = "Zero Read, Sent, Received Email - 10/11 - kbennett"
$Pass2 = "Zero Read, Sent, Have received Email - 10/15 - kbennett - Enable if needed and remove this Note"
$Domain = "P054adsamdc02.amer.epiqcorp.com"
$DisabledOU = "OU=Disabled,OU=Employees,OU=Corp IT,DC=amer,DC=EPIQCORP,DC=COM"
$DataFile = "c:\temp\LicenseCleanup3.csv"
$SucessLog = "c:\temp\LicenseSuccesssLog.csv"
$FailLog = "c:\temp\LicenseFailLog.csv"

$WardCreds = Get-Credential

# Get List of users by UPN
	$Script:import = Import-csv $DataFile

#Run Function
Function Run {
    foreach ($Script:User in $Import){
        $Script:Info = Get-ADUSer -Filter "UserPrincipalName -eq '$($User.UPN)'"
        Set-ADUser -identity $Info.SamAccountName -Description $Pass2 -Server $Domain -Credential $WardCreds -Confirm:$false
        Disable-ADAccount -Identity $Info.SamAccountName -Server $Domain -Credential $WardCreds -Confirm:$false
        #Remove-ADGroupMember "UG-o365-License-Exchange-P1" -member $Info.SamAccountName  -Server $Domain -Credential $WardCreds -Confirm:$false
        #Remove-ADGroupMember "UG-o365-License-Exchange-P2" -member $Info.SamAccountName  -Server $Domain -Credential $WardCreds -Confirm:$false
        #Remove-ADGroupMember "UG-o365-License-Skype-AudioConf" -member $Info.SamAccountName  -Server $Domain -Credential $WardCreds -Confirm:$false
        #Remove-ADGroupMember "UG-o365-License-Skype-P1" -member $Info.SamAccountName  -Server $Domain -Credential $WardCreds -Confirm:$false
        #Remove-ADGroupMember "UG-o365-License-Skype-P2" -member $Info.SamAccountName  -Server $Domain -Credential $WardCreds -Confirm:$false
        #Move-ADObject $Info.DistinguishedName -TargetPath $DisabledOU -Server $Domain -Credential $WardCreds -Confirm:$false
        $info.Name
    }
}

# Update Notes
Function AddNotes {
    foreach ($User in $Import){
        Set-ADUser -identity $User.UPN -Description $Pass1 -Server $Domain
    }
}

# Move Account to OU
 Function Move{
    foreach ($User in $Import){
        Move-ADObject $User.UPN -Server $Domain -TargetPath $DisabledOU
    }
}

# Disable Account
Function Disable {
    foreach ($User in $Import){
        Disable-ADAccount -Identity $User.UPN
    }

}

# Remove License Group
Function RemoveGroup {
    foreach ($user in $Import) {
        Remove-ADGroupMember $User.LicenseGroup -member $User.UPN
    }
}

# ------------------------------------------------ 
# Error checking to see if user exists
Function checkUser {
     foreach ($Script:name in $import){
     $Script:Info = Get-ADUSer -Filter "UserPrincipalName -eq '$($name.UPN)'"
     $script:FullName = $name.UPN
     Try{
            $Second = Get-ADUser $info.SamAccountName -Server $domain
            write-Host "User $FullName Exist in $domain" -ForegroundColor Green
            #Run
        }
        Catch {   
            Write-Host "User $Fullname doesn't exist in $domain" -ForegroundColor Red

        }
        }
    Add-Content "c:\temp\LicenseSuccesssFail.csv" $array
}

Function Logging {
  # Log what we did
    $Log = $name.UPN
    Add-Content "c:\temp\LicenseSuccesssFail.csv" $log
  
  
    $script:info = @()
    $script:LogPath = '\\P054EXGRELY01\Logs\NewMailUserLog.csv'

    $info += New-Object psobject `
                -Property @{`
                    Date=$date; `
                    Name=$account; `
                    UPN=$upn; `
                    Ward=$UserCredential.UserName; `
                    RoutingAddress=$email; `
                    ExchangeLicense=$GroupValue.Name; `
                    DomainController=$DC}

    $info | Export-Csv $FailLog -Append -NoTypeInformation

}



