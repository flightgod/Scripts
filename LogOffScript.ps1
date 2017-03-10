Function Load-List

{

$global:list = @() ; Write-host "Enter items:" ;do { $line = (Read-Host " ") ; if ($line -ne '') {$global:list += $line}} until ($line -eq '')

}
Load-List
#$ServerList = $list
Write-host "Enter UserName: ";$username = (Read-Host " ")
foreach($Server in $list) { 
$session = ((quser /server:$Server | ? { $_ -match $username }) -split ' +')[2]
Write-Host "Working on $Server for User: $username with SessionID: $session"
Logoff $session /server:$server

}