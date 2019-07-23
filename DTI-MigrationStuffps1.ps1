$ExchangeServer = "http://et016-ex10hub1.amer.EvilCorpcorp.com/PowerShell/"
$DomainController = "P054ADSAMDC02.amer.EvilCorpCORP.COM"

Function ExchangeConnect {
    If ($Session.ComputerName -like "et016-eqexmbx01.amer.EvilCorpcorp.com"){
        Write-Host "Session already established to exchange" -ForegroundColor Green
    }
    Else {
        Write-Host "Session not made to exchange, creating session now" -ForegroundColor Red
        $Script:UserCredential = Get-Credential
        $Script:Session = New-PSSession `
        -ConfigurationName Microsoft.Exchange `
        -ConnectionUri $ExchangeServer `
        -Authentication Kerberos `
        -Credential $UserCredential
        Import-PSSession $Session
    }
}

# runs the Sync
Function EvilCorp-ADSync {
    # Kicks off the AD Azure Sync on the Sync server
    Get-Date
    $session = New-PSSession -ComputerName "P054ADZAGTA01" -Credential $UserCredential
    # Invoke-Command -Session $session -ScriptBlock {Get-ADSyncScheduler -SyncCycleProgress}
    Invoke-Command -Session $session -ScriptBlock {Import-Module "C:\Program Files\Microsoft Azure AD Sync\Bin\ADSync\ADSync.psd1"}
    Invoke-Command -Session $session -ScriptBlock {Start-ADSyncSyncCycle -PolicyType Delta}
    Remove-PSSession $session
    
    "Please wait while the Azure Sync is completed ......... Estimate 15 Seconds"

    Start-Sleep -s 16
}

# Runs the Add User Function
Function Add-User {
$Script:account = Read-Host -Prompt 'What is the users username (bsmith)?'
$Script:upn = $account+"@EvilCorpsystems.com"
$Script:email = $account+"@EvilCorpsystems3.mail.onmicrosoft.com"

Enable-RemoteMailbox $account -RemoteRoutingAddress $email -DomainController $DomainController

}

# Runs the Set Limits on the New Mailbox Created Above
Function SetLimits {
    Set-Mailbox $upn -ProhibitSendQuota 95GB -ProhibitSendReceiveQuota 95GB -IssueWarningQuota 90GB 
}


ExchangeConnect

EvilCorp-ADSync
