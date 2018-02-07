$ExchangeServer = "http://et016-ex10hub1.amer.epiqcorp.com/PowerShell/"
$DomainController = "P054ADSAMDC02.amer.EPIQCORP.COM"

Function UpdateDlLimitedUser {
$Script:account = Read-Host -Prompt 'What is the users username to add permissions (bsmith)?'
$groups = Get-DistributionGroup DTIEpiqAllEmployees| %{$_.AcceptMessagesOnlyFromSendersOrMembers}
$kcgroups = $groups + $account
Get-DistributionGroup Epiq-All-Contractors| %{$_.AcceptMessagesOnlyFromSendersOrMembers}
Get-DistributionGroup Epiq-All| %{$_.AcceptMessagesOnlyFromSendersOrMembers}
Get-DistributionGroup EagleAllGroup| %{$_.AcceptMessagesOnlyFromSendersOrMembers}


Set-DistributionGroup Epiq-All-Contractors -AcceptMessagesOnlyFromSendersOrMembers $kcgroups
Set-DistributionGroup Epiq-All -AcceptMessagesOnlyFromSendersOrMembers $kcgroups
Set-DistributionGroup EagleAllGroup -AcceptMessagesOnlyFromSendersOrMembers $Groups
}


Function ExchangeConnect {
    If ($Session.ComputerName -like "et016-eqexmbx01.amer.epiqcorp.com"){
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
Function ADSync {
    # Kicks off the AD Azure Sync on the Sync server
    $session = New-PSSession -ComputerName "P054ADZAGTA01" -Credential $UserCredential
    Invoke-Command -Session $session -ScriptBlock {Import-Module "C:\Program Files\Microsoft Azure AD Sync\Bin\ADSync\ADSync.psd1"}
    Invoke-Command -Session $session -ScriptBlock {Start-ADSyncSyncCycle -PolicyType Delta}
    Remove-PSSession $session
    
    "Please wait while the Azure Sync is completed ......... Estimate 15 Seconds"

    Start-Sleep -s 16
}

ExchangeConnect
UpdateDLLimitedUser
ADSyncg


