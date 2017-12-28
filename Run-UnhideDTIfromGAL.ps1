# Connects to Exchange
Function Connect-Exchange {
    $ExchangeServer = "http://ET016-EQEXMBX01.amer.epiqcorp.com/PowerShell/"
    # If already connected skip - makes it cleaner to look at     
    If ($Session.ComputerName -like "et016-eqexmbx01.amer.epiqcorp.com") {
        Write-Host "Session already established to exchange" -ForegroundColor Green
    }
    Else {
        Write-Host "Session not made to exchange, creating session now" -ForegroundColor Red
        $UserCredential = Get-Credential
        $Session = New-PSSession `
        -ConfigurationName Microsoft.Exchange `
        -ConnectionUri $ExchangeServer `
        -Authentication Kerberos `
        -Credential $UserCredential
        Import-PSSession $Session
    }
}

Connect-Exchange
$OU = "OU=Corp IT,DC=amer,DC=EPIQCORP,DC=COM"
Get-RemoteMailbox -ResultSize Unlimited -OnPremisesOrganizationalUnit $OU | Set-RemoteMailbox -HiddenFromAddressListsEnabled $False




Get-ADUser -SearchBase $ou -filter * -Properties * | where {$_.extensionAttribute13 -notlike "dtiglobal*"} | ft CN, extensionAttribute13 -AutoSize 


$count = Get-RemoteMailbox -ResultSize Unlimited | Where {$_.primarysmtpaddress -like "*2@dtiglobal*"} | select Name, PrimarySmtpAddress >> C:\temp\2s.txt


