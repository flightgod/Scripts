$ExchangeServer = "http://et016-ex10hub1.amer.epiqcorp.com/PowerShell/"
$DomainController = "P054ADSAMDC02.amer.EPIQCORP.COM"

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

Function Add-User {
$Script:account = Read-Host -Prompt 'What is the users username (bsmith)?'
$Script:upn = $account+"@epiqsystems.com"
$Script:email = $account+"@epiqsystems3.mail.onmicrosoft.com"

Enable-RemoteMailbox $account -RemoteRoutingAddress $email -DomainController $DomainController
}

ADSync


# ------------------------------------------------

$file = "C:\Temp\DistributionList - DTI.csv"

# Checks that the file is there, then imports it
Function ImportFile {
    $test = Test-Path $file
    If ($test -eq $true) {
        $script:import = Import-csv $file
    }
    Else {
        Write-Warning "Something went Wrong: DTI Import File is missing at $file"
        Break
    }
}

ImportFile

 foreach ($Name in $import){
    Set-DistributionGroup `
        -Identity $name.SamAccountName `
        -EmailAddresses $Name.EmailAddress `
        -EmailAddressPolicyEnabled $false
}



#----------------------------------------------
Function SetLimits {
    Set-Mailbox June.Coyle@epiqsystems.com -ProhibitSendQuota 95GB -ProhibitSendReceiveQuota 95GB -IssueWarningQuota 90GB 
}

# ----------------------------
# Function UnhideGAL 
Function UnHideGal {
    Get-DistributionGroup -OrganizationalUnit "OU=Corp IT,DC=Amer,DC=EpiqCorp,DC=Com" -ResultSize Unlimited | Set-DistributionGroup -HiddenFromAddressListsEnabled $false

}


