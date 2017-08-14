<#  
.SYNOPSIS
   	Updates attribute extensionAttribute10

.DESCRIPTION  
    Script to update fix if users are having azure sync due to account type mismatch

.NOTES  
    Current Version     : 1.0
    
    History				: 1.0 - Posted 8/1/2017 - First iteration - kbennett
      
                            
    
    Rights Required		: Permissions on AD Objects to make changes
                        : Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     : Able to search the whole domain - currently just does amer
                        : Error Checking
                        : Fix more than 1 at a time

.FUNCTIONALITY
    1. Add to the users AD Object -  extensionAttribute10 > nomsazuresync
    2. Run the Azure sync process
    3. check that it is gone
    4. Remove extensionAttribute10 > nomsazuresync
#>

# Variables
$user = Read-Host "What is the user having issues?"
$value = "nomsazuresync"
$DomainController = "P054ADSAMDC02.amer.EPIQCORP.COM"
$DomainController_AP = "ET016-EQAPDC03.APAC.EPIQCORP.COM"
$DomainController_UK = "ET016-EQEUDC01.EURO.EPIQCORP.COM"
$ExchangeServer = "http://ET016-EQEXMBX01.amer.epiqcorp.com/PowerShell/"

# Connects to Exchange
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

Function AddAttribute {
    # should add to check that it is not populated already - error checking
    Get-AdUser $user -Server $DomainController | Set-ADObject -add @{extensionAttribute10=$value} -Credential $UserCredential
}

Function CheckAttribute {
    # Checks that the attribute is there
    $Guser = Get-AdUser $user 
    Get-ADObject -Identity $Guser.ObjectGUID -Server $DomainController -Properties extensionAttribute10
}

Function ClearAttribute {
    # Clears out the Attribute
    Get-AdUser $user -Server $DomainController | Set-ADObject -Clear extensionAttribute10 -Credential $UserCredential
}

Function ConnectToSync {
    # connect to azure sync and sync
    $AADComputer ="P054ADZAGTA01"
    $session = New-PSSession -ComputerName $AADComputer -Credential $UserCredential
    Invoke-Command -Session $session -ScriptBlock {$Test = Get-ADSyncConnectorRunStatus}
    If ($Test.RunState = "Busy") {
        Write-Host " Waiting for Azure sync to be free to kick off"
        Start-Sleep -s 30
    } 
    Write-Host "Running Azure Sync"
    Invoke-Command -Session $session -ScriptBlock {Import-Module -Name 'ADSync'}
    Invoke-Command -Session $session -ScriptBlock {Start-ADSyncSyncCycle -PolicyType Delta}
    Remove-PSSession $session
}

Function WaitForAwhile {
    # Throwing this in to wait for a few minutes then continue on
    # This should wait long enough for Sync to complete and clear everything up - I Hope
    Start-Sleep -s 240
}

# Main Script Body
ExchangeConnect
AddAttribute
CheckAttribute
ConnectToSync
WaitForAwhile
ClearAttribute
ConnectToSync
