<#  
.SYNOPSIS
   	Main Menu

.DESCRIPTION  
    This is the main menu

.NOTES  
    Current Version     	: 1.0
    
    History			        : 1.0 - Posted 12/04/2018 - Kbennett

        
    Rights Required		    : Permissions to Add/Edit Objects in Exchange
                        	: Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                            : MUST USE epiqsystem3.onmicrosoft.com account for Auth
                        
    Future Features     	: Better Error Checking
                            : Variables
                            : Check for existing
             
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
             .\Epiq-NewMailContact.ps1
         } '2' {
             .\Epiq-Enable-o365Mailbox.ps1
         } '3' {
             .\Check-SkypeSettings.ps1
         } '4' {
             .\Epiq-Enable-Skypeo365.ps1
         } '5' {
             .\Epiq-MainMenu.ps1
         }
     }
     pause
 }
 until ($selection -eq 'q')
}

function Show-Menu
{
    param (
        [string]$Title = 'Epiq Main Script'
    )
    Clear-Host
    Write-Host "================ $Title ================"
    
    Write-Host "1: Press '1' for Create New Mail Contact."
    Write-Host "2: Press '2' for Add User Email."
    Write-Host "3: Press '3' for Check Skype Settings."
    Write-Host "4: Press '4' for Add User to Skype."
    Write-Host "5: Press '5' for Main Menu."
    Write-Host "Q: Press 'Q' to quit."
}

# Script Body
Menu



# Function to deploy to Jump Boxes
# This is for kbennett to easily deploy script changes, do not run because it probably wont work for you
Function Deploy-Script {
   
    $LocalPath = 'c:\Scripts\Epiq-MainMenu.ps1'
    $UserCredential = Get-Credential

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