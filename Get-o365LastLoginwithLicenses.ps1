Function Connect-o365 {
    $O365URI = "https://outlook.office365.com/powershell-liveid/"
    If ($Session.ComputerName -like "outlook.office365.com") {
        Write-Host "Session already established to exchange" -ForegroundColor Green
    }
    Else {
        Write-Host "Session not made to exchange, creating session now" -ForegroundColor Red
        $script:o365Credential = Get-Credential
        Import-Module MSOnline
        Connect-MsolService -Credential $o365Credential
        $o365Session = New-PSSession `
        -ConfigurationName Microsoft.Exchange `
        -ConnectionUri $O365URI `
        -Authentication Basic `
        -AllowRedirection `
        -Credential $o365Credential
        Import-PSSession $o365Session
    }
}

connect-o365

Get-MsolUser -All |
  Where {$_.IsLicensed -eq $true } |
    Foreach {Get-MailboxStatistics $_.UserPrincipalName |
    Select DisplayName,UsageLocation,@{n="Licenses Type";e={$_.Licenses.AccountSKUid}},Email,LastLogonTime} | 
  Export-Csv -Path C:\Temp\Test.csv -NoTypeInformation


  Get-ADUser -filter * | Where {$_.pwdLastSet -eq $NULL} | Select SamAccountName, UserPrincipalName, pwdLastSet, whenCreated
