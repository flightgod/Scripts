$OU = "DC=amer,DC=EvilCorpcorp,DC=com"

<#$Count = Get-ADUser -Filter * -SearchBase $OU -Properties EmployeeID | `
Where-Object {$_.Enabled -eq $false} | `
Select-Object SAMAccountName, EmployeeID `
| Export-Csv -Path C:\temp\disabled.csv -NoTypeInformation
#>

$Count = Get-ADUser -Filter * -SearchBase $OU -Properties EmployeeID | `
Where-Object {$_.Enabled -eq $false} | `
Select-Object SAMAccountName, EmployeeID
