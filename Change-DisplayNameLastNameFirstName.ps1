$OU = "OU=Employees, OU=Corp IT,DC=amer,DC=EPIQCORP,DC=COM"

$search = get-aduser -filter * -SearchBase $OU -properties Name, DisplayName, Surname, GivenName

foreach ($User in $Search) {
   $NewDisplayName = $User.Surname + "," + $user.Givenname
   Set-ADUser -DisplayName $NewDisplayName
}

