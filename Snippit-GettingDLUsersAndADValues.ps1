# Used to get Group Members and their AD Values.

$List = Get-ADGroupMember "UG-o365-license-exchange-p2" | Select SamAccountName

$script:info = @()
ForEach ($user in $List){
    $WithoutID = Get-ADUser $user.SamAccountName -Properties EmployeeID | Where {$_.EmployeeID -eq $Null} | Select UserPrincipalName
     
     $info += $WithoutID
}


$All = Get-ADGroupMember "Epiq-All" | Select SamAccountName