$computers = Get-Content -Path 'ComputerList.txt'
foreach ($computer in $computers) {
    $ols = gwmi -Class win32_process -ComputerName $computer | ? { $_.name -eq 'Outlook.exe' }
    foreach ($ol in $ols) { $ol.terminate() | Out-Null }
    Start-Sleep 5
    $ostFiles = gwmi -ComputerName $computer -Query "Select * from CIM_DataFile Where Drive = 'C:' and Extension = 'ost'" 
    foreach ($ostFile in $ostFiles) { $ostFile.rename($ostFile.name + '.old') | Out-Null }
    
    Start-Sleep 2
    Invoke-WmiMethod -ComputerName $computer -Class Win32_Process -Name Create -ArgumentList "c:\Program Files\Microsoft Office\Office14\outlook.exe"
    }
