# Test Connection


try {
    Test-Connection -ComputerName server -Count 100
    } catch {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Write-Host $ErrorMessage -ForegroundColor Red
}




Get-CimInstance -ClassName win32_operatingsystem -ComputerName server | select csname, lastbootuptime
