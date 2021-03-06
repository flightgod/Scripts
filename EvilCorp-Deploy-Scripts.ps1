<#  
.SYNOPSIS
   	Script Deploy Menu

.DESCRIPTION  
    This is the Menu and Functionality to deploy the scripts to all the Jump Boxes

.NOTES  
    Current Version     	: 1.0
    
    History			        : 1.0 - Posted 1/21/2019 - Kbennett

        
    Rights Required		    : Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                            : MUST USE ward account for Authentication
                        
    Future Features     	: Check for Existing
                            : Drop if Password is wrong to keep from Locking out
             
.FUNCTIONALITY
    xxxx
#>

param (
    [string]$Title = 'Deploy Scripts',
    
    $Script:LocalScriptPath = "c:\scripts\",
    $Script:PSScript = $NULL,
    $JumpBox = @(
        '\\TS016-EXTOOLS\C$\Scripts',
        '\\P054CORUTIL01\C$\Scripts',
        '\\P054CORUTIL02\C$\Scripts',
        '\\P054EXGRELY01\C$\Scripts',
        '\\P054EXGRELY02\C$\Scripts')

)



# Function to deploy to Jump Boxes
# This is for kbennett to easily deploy script changes, do not run because it probably wont work for you
Function Deploy-Script {
    $x = 0
    $JBName,$DriveDesitnation,$DriveName = $NULL
    $Script:LocalPath = $LocalScriptPath + $PSScript
    $script:UserCredential = Get-Credential
    
    ForEach ($Server in $JumpBox) {
        $DriveName = "Script"+$x
        $JBName = $JumpBox.Item($x)
        $DriveDesitnation = $Drivename + ":"
        New-PSDrive -Name $DriveName -PSProvider "FileSystem" -root $JBName -Credential $UserCredential
            Copy-Item -Path $LocalPath -Destination $JBName
        Remove-PSDrive -Name $DriveName
        $x = $x + 1
    }
   
}

Function Menu {
do
 {
     Show-Menu
     $selection = Read-Host "Please make a selection"
     switch ($selection)
     {
        '1' {
            $PSScript = "EvilCorp-MainMenu.ps1"
            Deploy-Script
        } '2' {
            $PSScript = "EvilCorp-ExchangeAdminSubMenu.ps1"
            Deploy-Script
        } '3' {
            $PSScript = "EvilCorp-Check-SkypeSettings.ps1"
            Deploy-Script
        } '4' {
            $PSScript = "EvilCorp-Enable-o365Mailbox.ps1"
            Deploy-Script
        } '5' {
            $PSScript = "EvilCorp-Enable-MultiGeo.ps1"
            Deploy-Script
        } '6' {
            $PSScript = "EvilCorp-Enable-Skypeo365.ps1"
            Deploy-Script
        } '7' {
            $PSScript = "EvilCorp-NewMailContact.ps1"
            Deploy-Script
        } '8' {
            $PSScript = "Function-ADSync.ps1"
            Deploy-Script
        } '9' {
            $PSScript = "EvilCorp-Deploy-Scripts.ps1"
            Deploy-Script
        } '10' {
            $PSScript = "EvilCorp-SharedMailboxPermissions.ps1"
            Deploy-Script
        }
     }
     pause
 }
 until ($selection -eq 'q')
}

function Show-Menu
{
    Clear-Host
    Write-Host "================== $Title ==================="
    Write-Host ""
    Write-Host "** ONLY USED BY EXCHANGE ADMINS - PLEASE DONT USE **" -ForegroundColor Red
    Write-Host "******** You can seriously Break something *********" -ForegroundColor Red
    Write-Host ""
    
    Write-Host "1: Press '1' Deploy EvilCorp-MainMenu."
    Write-Host "2: Press '2' Deploy EvilCorp-ExchangeAdminSubMenu."
    Write-Host "3: Press '3' Deploy EvilCorp-Check-SkypeSettings."
    Write-Host "4: Press '4' Deploy EvilCorp-Enable-o365Mailbox."
    Write-Host "5: Press '5' Deploy EvilCorp-Enable-MultiGeo."
    Write-Host "6: Press '6' Deploy EvilCorp-Enable-Skypeo365."
    Write-Host "7: Press '7' Deploy EvilCorp-NewMailContact."
    Write-Host "8: Press '8' Deploy Function-ADSync."
    Write-Host "9: Press '9' Deploy EvilCorp-Deploy-Scripts (this script)."
    Write-Host "10: Press '10' Deploy EvilCorp-SharedMailboxPermissions."
    Write-Host "Q: Press 'Q' to quit."
}

# Script Body
Menu
