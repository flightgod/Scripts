# Test Connection


try {
    Test-Connection -ComputerName P064TMGGTWY01 -Count 100
    } catch {
        $ErrorMessage = $_.Exception.Message
        $FailedItem = $_.Exception.ItemName
        Write-Host $ErrorMessage -ForegroundColor Red
}




Get-CimInstance -ClassName win32_operatingsystem -ComputerName P054TMGGTWY01 | select csname, lastbootuptime