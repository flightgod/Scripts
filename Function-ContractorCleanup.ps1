

param (
$ImportFile = "C:\Temp\Term.csv",
$DomainController = "P054ADSAMDC02.amer.EPIQCORP.COM",
$OU = "OU=Distribution Groups,OU=Exchange,OU=Corp IT,DC=amer,DC=EPIQCORP,DC=COM"
)

#$Ward_Creds=Get-Credential

# Function import list of users
Function ImportList {
    $test = Test-Path $ImportFile
    If ($test -eq $true) {
        $script:import = Import-csv $ImportFile
    }
    Else {
        Write-Warning "Something went Wrong: File is missing at $ImportFile"
        Break
    }
}

Function test {

    ForEach ($User in $Import){
        $ID=$user."Employee ID"
        Get-ADuser -filter * -Properties EmployeeID -Server P016ADSAMDC02.amer.epiqcorp.com | Where {$_.EmployeeID -eq $ID} | Select UserPrincipalName, Enabled, EmployeeID

    }
}

Function Find {
    ForEach ($User in $Import){
        $LastName = $user."Legal Name - Last Name"
        $FirstName = $User."Legal Name - First Name"
        $Script:FullName = $Lastname + ", " + $FirstName
        write-Host "Trying: $FullName" -ForegroundColor Green
        $Script:Gotten = Get-ADUser -Filter * -Server $DomainController | Where {$_.Surname -eq $LastName -and $_.GivenName -eq $FirstName}  | Select UserPrincipalName, Enabled, SamAccountName
        
        If ($Gotten -eq $Null) {
            Write-Host "Cant Find: $FullName" -ForegroundColor Red
            out-file -filepath c:\temp\Contractor-cantfind.txt -InputObject $FullName -Encoding ASCII -Width 50 -Append
         } Else {
            Gotten
         }
    }
}

Function Gotten {
    If ($Gotten.Enabled -eq $True) {
        $Gotten
        out-file -filepath c:\temp\Contractor-Found_Removed.txt -InputObject $Gotten -Encoding ASCII -Width 50 -Append
        DeleteGroup
        } Else {
        Write-Host "Account is disabled: $FullName"
        out-file -filepath c:\temp\Contractor-AlreadyDisabled.txt -InputObject $Gotten -Encoding ASCII -Width 50 -Append
    }
}


Function DeleteGroup {

    Remove-ADGroupMember -Identity "UG-o365-License-Exchange-P2" -Member $Gotten.SamAccountName -Confirm:$false -Server $DomainController -Credential $Ward_Creds
    Remove-ADGroupMember -Identity "UG-o365-License-Exchange-P1" -Member $Gotten.SamAccountName -Confirm:$false -Server $DomainController -Credential $Ward_Creds
    Remove-ADGroupMember -Identity "UG-o365-License-Skype-AudioConf" -Member $Gotten.SamAccountName -Confirm:$false -Server $DomainController -Credential $Ward_Creds
    Remove-ADGroupMember -Identity "UG-o365-License-Skype-P2" -Member $Gotten.SamAccountName -Confirm:$false -Server $DomainController -Credential $Ward_Creds

}

#Get-ADPrincipalGroupMembership $Gotten.UserPrincipalName
