<#  
.SYNOPSIS
   	xxxx

.DESCRIPTION  
    xxxx

.NOTES  
    Current Version     	: 1.1
    
    History			        : 1.0 - Posted 9/27/2017 - First iteration - kbennett 

        
    Rights Required		    : Permissions to Add/Edit Objects in Skype o365
                        	: Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                            : MUST USE epiqsystem3.onmicrosoft.com account for Auth
                        
    Future Features     	: Better Error Checking
                            : Variables
                            : Check for existing
                            : Assign License

             
.FUNCTIONALITY
    xxxx
#>

#Variables
$target = "sipfed.online.lync.com"
$DomainController = "P054ADSAMDC02.amer.EPIQCORP.COM"

# Connect to Skype
Function Connect-Lync {
    $LyncServer = "https://lyncws.epiqsystems.com/OcsPowershell"
    If ($Session.ComputerName -like "lyncws.epiqsystems.com") {
        Write-Host "Session already established to Lync" -ForegroundColor Green
    }
    Else {
        Write-Host "Session not made to Lync, creating session now" -ForegroundColor Red
        $script:LyncCredentials = Get-Credential
        $LyncSession = New-PSSession `
        -ConnectionUri $LyncServer `
        -Credential $LyncCredentials 
        Import-PSSession -Session $LyncSession -AllowClobber
    }

}

Function Get-User {
$Script:account = Read-Host -Prompt 'What is the users username (bsmith)?'
$Script:upn = $account+"@epiqsystems.com"
$Script:email = $account+"@epiqsystems3.mail.onmicrosoft.com"
$Script:sip = "SIP:"+$upn

}

# runs the Sync
Function ADSync {
    # Kicks off the AD Azure Sync on the Sync server
    Get-Date
    $session = New-PSSession -ComputerName "P054ADZAGTA01" -Credential $LyncCredential
    Invoke-Command -Session $session -ScriptBlock {Import-Module "C:\Program Files\Microsoft Azure AD Sync\Bin\ADSync\ADSync.psd1"}
    Invoke-Command -Session $session -ScriptBlock {Start-ADSyncSyncCycle -PolicyType Delta}
    Remove-PSSession $session
    
    "Please wait while the Azure Sync is completed ......... Estimate 15 Seconds"

    Start-Sleep -s 16

    #Get-ADSyncScheduler -SyncCycleProgress # If false then run, else wait then check then run
}

# This is the Migrate Function to move the user from OnPrem to o365
Function Migrate-User {
    $Script:upn = $account+"@epiqsystems.com"
    $Script:email = $account+"@epiqsystems3.mail.onmicrosoft.com"
    $Script:sip = "SIP:"+$upn
    Move-CsUser `
        -Identity $upn `
        -domainController $DomainController `
        -Target $target 
 
    Add-ADGroupMember -Identity "UG-o365-License-Skype-P1" -members $account -Server $DomainController
}

# This is the Enable function. If user is not on prem this will create them in o365
Function Enable-Skype {
    Enable-CsUser -Identity $sipData.upn -SipAddress $sip -HostingProviderProxyFqdn sipfed.online.lync.com -DomainController $DomainController
    Add-ADGroupMember -Identity "UG-o365-License-Skype-P1" -members $upn -Server $DomainController
}


Connect-Lync
Get-User
Migrate-User
#Enable-Skype



# ----------------------------------------------------------------------------------------------------------------------

Function FullAuto {
    $Crap = "C:\temp\DTIskypeNew.csv"
    $sipData = Import-Csv $Crap

    forEach ($user in $sipData){
        #Enable-CsUser -Identity $user.upn -SipAddress $user.sip -HostingProviderProxyFqdn sipfed.online.lync.com -DomainController $DomainController
        $Script:Missing = Get-ADUser -Identity $user.upn -Properties Name,SamAccountName,'msRTCSIP-DeploymentLocator' -Server $DomainController | ? {$_.'msRTCSIP-DeploymentLocator' -ne "sipfed.online.lync.com"}
        Add-Content -path ".\Noto365.csv" $Missing
    }
}


Function checkAccount {
    foreach ($:user in $sipData){
       try { $script:username = Get-ADuser $user.upn }
       catch {Add-Content -path ".\NO_AD_Account.csv" $user.upn}
       
    }
}

Function VerifyUser {
    foreach ($:user in $sipData){
       Get-ADUser -Identity $user.upn -Properties Name,SamAccountName,'msRTCSIP-DeploymentLocator' -Server $DomainController | ? {$_.'msRTCSIP-DeploymentLocator' -ne "sipfed.online.lync.com"} | Select SamAccountName, 'msRTCSIP-DeploymentLocator'
       
       }
 }