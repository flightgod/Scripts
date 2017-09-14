$IE=new-object -com internetexplorer.application
$IE.navigate2("https://www.mixcloud.com/archwisp/def-con-25-defcon-parties-mix/")
$IE.visible=$true

Get-Process | ? { $_.ProcessName -eq 'iexplore' }
Start-Sleep 25
$IE.Quit()