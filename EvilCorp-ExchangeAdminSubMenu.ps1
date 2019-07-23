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
                            : MUST USE EvilCorpsystem3.onmicrosoft.com account for Auth
                        
    Future Features     	: Check for Existing
                            : Add Creating DL
                            : Add Mailbox Permissions
                            : Add OOO?
                            : Look into Offboard Procedures
             
.FUNCTIONALITY
    xxxx
#>


#Playing around with a Help Style - Maybe I put instructions or something here, Bug reporting, Feature requests?
Function Help {

$IE=new-object -com internetexplorer.application
$IE.navigate2("https://EvilCorpsystems3.sharepoint.com/help/SitePages/Home.aspx")
$IE.visible=$true

}

# This is the main menu Case which waits for input and then acts
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
            .\EvilCorp-Deploy-Scripts.ps1
        } '3' {
            .\EvilCorp-ExchangeAdminSubMenu.ps1
        } '4' {
            .\EvilCorp-ExchangeAdminSubMenu.ps1
        } '5' {
            .\EvilCorp-ExchangeAdminSubMenu.ps1
        } '6' {
            .\EvilCorp-ExchangeAdminSubMenu.ps1
        } '7' {
            .\EvilCorp-ExchangeAdminSubMenu.ps1
        } '8' {
            Start-Process "chrome.exe" "portal.office.com"
        } '9' {
            .\Function-ADSync.ps1
        } 'H' {
            Help
        }

     }
     pause
 }
 until ($selection -eq 'q')
}

# This is the Show Menu on the screen function
function Show-Menu
{
    param (
        [string]$Title = 'EvilCorp Exchange Admin Sub Menu'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    Write-Host ""
    Write-Host "******* ONLY USED BY EXCHANGE ADMINS - PLEASE DONT USE *******" -ForegroundColor Red
    Write-Host "************* You can seriously Break something **************" -ForegroundColor Red
    Write-Host ""
    
    Write-Host "1: Press '1' for Updating EvilCorp-All Send Permissions."
    Write-Host "2: Press '2' for Deploy Scripts Menu."
    Write-Host "3: Press '3' for xxxxxx."
    Write-Host "4: Press '4' for xxxxxx."
    Write-Host "5: Press '5' for xxxxxx."
    Write-Host "6: Press '6' for xxxxxx."
    Write-Host "7: Press '7' for xxxxxx."
    Write-Host "8: Press '8' Launch o365 Portal"
    Write-Host "9: Press '9' for Azure AD Sync."
    Write-Host "H: Press 'H' for Help."
    Write-Host "Q: Press 'Q' to quit."
}

# Script Body
Menu
