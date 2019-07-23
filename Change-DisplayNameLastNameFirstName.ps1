$OU = "OU=Employees, OU=Corp IT,DC=amer,DC=EvilCorpCORP,DC=COM"
$DomainController = "P054ADSAMDC02.amer.EvilCorpCORP.COM"

$search = get-aduser -filter * -SearchBase $OU -properties Name, DisplayName, Surname, GivenName, SamAccountName, DistinguishedName -Server $DomainController

# Calls my connect function with all the current connection strings in it
.".\Function-Connect.ps1"

Function ChangeName {
    foreach ($User in $Search) {
        get-ADUser $user.SamAccountName -Properties name, DisplayName, SamAccountName, Surname, GivenName -Server $DomainController | Select Name, DisplayName, SamAccountName
        Rename-ADObject $User.DistinguishedName -NewName $user.Displayname -Credential $UserCredential -Server $DomainController
    }
}


Function ChangeDisplayName {
    foreach ($User in $Search) {
        $Script:DisplayName = $user.Surname +", " + $user.GivenName #Creates Display Name
        Set-ADUser $User -DisplayName $DisplayName -Credential $UserCredential -Server $DomainController

    }
}

DidIAlreadyLogIn
