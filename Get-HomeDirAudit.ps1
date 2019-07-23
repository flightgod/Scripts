Function Load-List

{

$global:list = @() ; Write-host "Enter items:" ;do { $line = (Read-Host " ") ; if ($line -ne '') {$global:list += $line}} until ($line -eq '')

}
Load-List


foreach($dir in $list) { 

#Get-NTFSAccess -Path Z:\$dir
#Get-ACL z:\$dir | Format-list -Property PSChildName, AccessToString

$i = Get-ACL z:\$dir|ConvertTo-Csv
$null, $null, $ni = $i
Add-Content -Path .\homeaudit.csv -Value $ni

}

