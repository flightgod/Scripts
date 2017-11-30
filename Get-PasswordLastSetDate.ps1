$OU = "OU=Corp IT,DC=amer,DC=EPIQCORP,DC=COM"

$Search = get-aduser -filter * -SearchBase $OU -properties Name, userPrincipalName, passwordlastset `
|ft name, userPrincipalName, passwordlastset | Out-String -Width 4096 `
| Out-File "c:\temp\LastPasswordChange.txt"

#$Search >> "c:\temp\LastPasswordChange.txt" 