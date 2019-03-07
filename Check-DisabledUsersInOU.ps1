$OU = "OU=Standard,OU=Employees,OU=Corp IT,DC=amer,DC=epiqcorp,DC=com"

Get-ADUser -Filter * -SearchBase $OU -Properties EmployeeID | `
Where-Object {$_.Enabled -eq $false} | `
Select-Object SAMAccountName, EmployeeID `
| Export-Csv -Path C:\temp\disabled.csv -NoTypeInformation