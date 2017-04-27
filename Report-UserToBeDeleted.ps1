$import = Import-csv .\List.csv
$Domain = "amer.epiqcorp.com"
$NewPath = "OU=Delete,OU=Exchange-Team,DC=amer,DC=EPIQCORP,DC=COM"

foreach ($Name in $import){

 $Info = Get-ADUser -Identity $Name.Name -Properties * | Select Name, Title, l, Department, TelephoneNumber, MobilePhone, StreetAddress, City, State, PostalCode 
 
 $info | Export-Csv .\newList.txt -Append -NoTypeInformation


 
}