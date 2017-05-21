<#  
.SYNOPSIS
   Add or remove from Distro List

.DESCRIPTION  
    This script Can add or remove a user from a distribution List. It can be ran from anywhere not just the 
    Exchange servers

.NOTES  
    Current Version     : 1.0
    
    History				: 1.0 - Posted 4/26/2017 - First iteration - kbennett                      
    
    Rights Required		: Exchange Permissions
                        : Exchange is in OnPrem environment
                        : Requires PowerShell (or ISE) to 'Run as Administrator' to install the applications or modules
                        
    Future Features     : Error Checking 
                        : Run for more than 1 DL and User

.FUNCTIONALITY
    This script Can add or remove a user from a distribution List
#>

# Connects to Exchange - so you can run remotely
$UserCredential = Get-Credential
$Session = New-PSSession -ConfigurationName Microsoft.Exchange -ConnectionUri http://ET016-EQEXMBX01.amer.epiqcorp.com/PowerShell/ -Authentication Kerberos -Credential $UserCredential
Import-PSSession $Session

# Runs Menu
function Show-Menu
{
     param (
           [string]$Title = 'Add/Remove User from DL'
     )
     cls
     Write-Host "================ $Title ================"
     
     Write-Host "1: Press '1' for Add User."
     Write-Host "2: Press '2' for Remove User."
     Write-Host "Q: Press 'Q' to quit."
}

# Adds User to a Distribution List
function AddUser
{
    Write-Host "Enter Distribution Name:"
    $DLName = Read-Host (" ")
    Write-Host "Enter Users SamAccountName:"
    $user = Read-Host (" ")
    Add-DistributionGroupMember -Identity $DLName -Member $User 
    Write-Host "User "$User" added to Distribution List "$DLName
    Start-Sleep -s 5
<#
$DLlist = @() 
Write-Host "Enter Distribution Name:"
do 
{
    $DLline = (Read-Host " ")
    if ($DLline -ne '') 
        {
            $DLlist += $DLline
         }
} 
until ($DLline -eq '')

next need to add DO UNTIL for UserList and UserLine
add loop to add from DLList and UserList to add-distributionGroupMember
}#>

# Removes User from a Distribution List
function Removeuser
{
    Write-Host "Enter Distribution Name:"
    $DLName = Read-Host (" ")
    Write-Host "Enter Users Email address:"
    $user = Read-Host (" ")
    Remove-DistributionGroupMember -Identity $DLName -Member $User
    Write-Host "User "$User" Removed From Distribution List "$DLName
    Start-Sleep -s 5
}

# Runs menu and waits for Option
do
{
     Show-Menu
     $input = Read-Host "Please make a selection"
     switch ($input)
     {
           '1' {
                cls
                AddUser
           } '2' {
                cls
                RemoveUser
           } 'q' {
                return
           }
     }
     pause
}
until ($input -eq 'q')

Exit-PSSession $Session