<#  
.SYNOPSIS
   	Exchange Admin Sub Menu

.DESCRIPTION  
    This is the main menu

.NOTES  
    Current Version     	: 1.0
    
    History			        : 1.0 - Posted 12/04/2018 - Kbennett

        
    Rights Required		    : Permissions to Add/Edit Objects in Exchange
                        	: Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                            : MUST USE epiqsystem3.onmicrosoft.com account for Auth
                        
    Future Features     	: Check for Existing
                            : Add Creating DL
                            : Add Mailbox Permissions
                            : Add OOO?
                            : Look into Offboard Procedures
             
.FUNCTIONALITY
    xxxx
#>




Function Menu {
do
 {
     Show-Menu
     $selection = Read-Host "Please make a selection"
     switch ($selection)
     {
        '1' {
            .\Update-DLAllowSendPermissions.ps1
        } '2' {
            .\Epiq-ExchangeAdminSubMenu.ps1
        } '3' {
            .\Epiq-ExchangeAdminSubMenu.ps1
        } '4' {
            .\Epiq-ExchangeAdminSubMenu.ps1
        } '5' {
            .\Epiq-ExchangeAdminSubMenu.ps1
        } '6' {
            .\Epiq-ExchangeAdminSubMenu.ps1
        } '7' {
            .\Epiq-ExchangeAdminSubMenu.ps1
        } '8' {
            .\Epiq-ExchangeAdminSubMenu.ps1
        } '9' {
            .\Function-ADSync.ps1
        }
     }
     pause
 }
 until ($selection -eq 'q')
}

function Show-Menu
{
    param (
        [string]$Title = 'Epiq Exchange Admin Sub Menu'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    Write-Host ""
    Write-Host "******* ONLY USED BY EXCHANGE ADMINS - PLEASE DONT USE *******" -ForegroundColor Red
    Write-Host "************* You can seriously Break something **************" -ForegroundColor Red
    Write-Host ""
    
    Write-Host "1: Press '1' for Updating Epiq-All Send Permissions."
    Write-Host "2: Press '2' for xxxxxx."
    Write-Host "3: Press '3' for xxxxxx."
    Write-Host "4: Press '4' for xxxxxx."
    Write-Host "5: Press '5' for xxxxxx."
    Write-Host "6: Press '6' for xxxxxx."
    Write-Host "7: Press '7' for xxxxxx."
    Write-Host "8: Press '8' for xxxxxx."
    Write-Host "9: Press '9' for Azure AD Sync."
    Write-Host "Q: Press 'Q' to quit."
}

# Script Body
Menu



# Function to deploy to Jump Boxes
# This is for kbennett to easily deploy script changes, do not run because it probably wont work for you
Function Deploy-Script {
   
    $LocalPath = 'c:\Scripts\Epiq-ExchangeAdminSubMenu.ps1'
    $script:UserCredential = Get-Credential

    New-PSDrive -Name "Scripts0" -PSProvider "FileSystem" -root '\\TS016-EXTOOLS\C$\Scripts' -Credential $UserCredential
        Copy-Item -Path $LocalPath -Destination 'Scripts0:'
    Remove-PSDrive -Name "Scripts0"

    New-PSDrive -Name "Scripts1" -PSProvider "FileSystem" -root '\\P054CORUTIL01\C$\Scripts' -Credential $UserCredential
        Copy-Item -Path $LocalPath -Destination 'Scripts1:'
    Remove-PSDrive -Name "Scripts1"

    New-PSDrive -Name "Scripts4" -PSProvider "FileSystem" -root '\\P054CORUTIL02\C$\Scripts' -Credential $UserCredential
        Copy-Item -Path $LocalPath -Destination 'Scripts4:'
    Remove-PSDrive -Name "Scripts4"

    New-PSDrive -Name "Scripts2" -PSProvider "FileSystem" -root '\\P054EXGRELY01\C$\Scripts' -Credential $UserCredential
        Copy-Item -Path $LocalPath -Destination 'Scripts2:'
    Remove-PSDrive -Name "Scripts2"

    New-PSDrive -Name "Scripts3" -PSProvider "FileSystem" -root '\\P054EXGRELY02\C$\Scripts' -Credential $UserCredential
        Copy-Item -Path $LocalPath -Destination 'Scripts3:'
    Remove-PSDrive -Name "Scripts3"

}