$OU = "OU=Employees, OU=Corp IT,DC=amer,DC=EPIQCORP,DC=COM"

$search = get-aduser -filter * -SearchBase $OU -properties Name, DisplayName, Surname, GivenName

foreach ($User in $Search) {
   
   get-ADUser $user.SamAccountName -Properties name, DisplayName, SamAccountName, Surname, GivenName
   Rename-ADObject $User.DistinguishedName -NewName $user.Displayname -Credential $UserCredential
}
