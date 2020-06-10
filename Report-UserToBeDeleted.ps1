$import = Import-csv .\List.csv
$Domain = "amer.domain.com"
$NewPath = "OU=Delete,OU=Exchange-Team,DC=amer,DC=domain,DC=COM"

foreach ($Name in $import){

 $Info = Get-ADUser -Identity $Name.Name -Properties * | Select Name, Title, l, Department, TelephoneNumber, MobilePhone, StreetAddress, City, State, PostalCode 
 
 $info | Export-Csv .\newList.txt -Append -NoTypeInformation


 
}
